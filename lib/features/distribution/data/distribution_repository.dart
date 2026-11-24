import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../customers/data/customers_repository.dart';
import '../../dashboard/data/dashboard_repository.dart';
import '../../inventory/data/inventory_repository.dart';
import '../../receivables/data/receivables_repository.dart';
import '../../reports/data/reports_repository.dart';
import '../domain/distribution_model.dart';

/// Repository managing LPG sales and distribution transactions via Supabase PostgreSQL.
class DistributionRepository {
  DistributionRepository._();
  static final DistributionRepository instance = DistributionRepository._();

  final ValueNotifier<List<DistributionModel>> distributionsNotifier =
      ValueNotifier<List<DistributionModel>>([]);

  Future<List<DistributionModel>> fetchDistributions() async {
    try {
      final client = Supabase.instance.client;
      final res = await client.from('distributions').select('''
        id, transaction_number, business_date, subtotal, discount, total, amount_paid, payment_status, notes, created_at,
        customers(id, name, phone, address),
        distribution_items(
          quantity, unit_price, subtotal,
          products(id, name, variant, purchase_price)
        )
      ''').order('business_date', ascending: false).order('created_at', ascending: false);

      final List<DistributionModel> mapped = [];

      for (final row in res as List<dynamic>) {
        final d = row as Map<String, dynamic>;
        final customer = d['customers'] as Map<String, dynamic>?;
        final customerName = customer?['name'] as String? ?? 'Pelanggan';

        final rawItems = (d['distribution_items'] as List<dynamic>?) ?? [];
        int totalQty = 0;
        int totalCost = 0;
        final List<DistributionItemDetail> itemDetails = [];

        for (final item in rawItems) {
          if (item is Map<String, dynamic>) {
            final qty = (item['quantity'] as num?)?.toInt() ?? 0;
            final unitPrice = (item['unit_price'] as num?)?.toInt() ?? 0;
            final product = item['products'] as Map<String, dynamic>?;
            final prodId = product?['id']?.toString() ?? '';
            final prodName = product?['name']?.toString() ?? 'Tabung LPG';
            final prodVariant = product?['variant']?.toString() ?? '';
            final unitCost = (product?['purchase_price'] as num?)?.toInt() ?? 16000;

            totalQty += qty;
            totalCost += (qty * unitCost);

            itemDetails.add(DistributionItemDetail(
              productId: prodId,
              productName: prodName,
              variant: prodVariant,
              quantity: qty,
              unitPrice: unitPrice,
              unitCost: unitCost,
              subtotalSales: qty * unitPrice,
              subtotalCost: qty * unitCost,
            ));
          }
        }

        final date = DateTime.tryParse(d['business_date']?.toString() ?? '') ?? DateTime.now();
        final createdAt = DateTime.tryParse(d['created_at']?.toString() ?? '');
        final timeStr = createdAt != null
            ? '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')} WIB'
            : '12:00 WIB';

        final totalSales = (d['total'] as num?)?.toInt() ?? 0;
        final amountPaid = (d['amount_paid'] as num?)?.toInt() ?? totalSales;
        final paymentStatus = d['payment_status']?.toString() ?? 'paid';

        mapped.add(DistributionModel(
          id: d['id'] as String,
          transactionNumber: d['transaction_number'] as String? ?? '',
          customerName: customerName,
          customerId: customer?['id'] as String?,
          qty: totalQty,
          date: date,
          time: timeStr,
          amount: totalSales,
          amountPaid: amountPaid,
          status: paymentStatus,
          totalCost: totalCost > 0 ? totalCost : (totalQty * 16000),
          paymentMethod: 'Tunai',
          items: itemDetails,
          notes: d['notes']?.toString() ?? '',
        ));
      }

      distributionsNotifier.value = mapped;
      return mapped;
    } catch (e) {
      debugPrint('Error fetching distributions from Supabase: $e');
      return distributionsNotifier.value;
    }
  }

  Future<void> createDistribution({
    required String customerId,
    required List<Map<String, dynamic>> items, // product_id, quantity, unit_price
    required int amountPaid,
    String paymentMethod = 'Tunai',
    String? notes,
  }) async {
    try {
      final client = Supabase.instance.client;
      final today = DateTime.now().toIso8601String().split('T')[0];
      final txNumber = 'DST-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

      int subtotal = 0;
      for (final it in items) {
        final qty = (it['quantity'] as num).toInt();
        final price = (it['unit_price'] as num).toInt();
        subtotal += qty * price;
      }
      final total = subtotal;

      final paymentStatus = amountPaid >= total
          ? 'paid'
          : (amountPaid > 0 ? 'partial' : 'unpaid');

      // 1. Insert distribution
      final distRes = await client.from('distributions').insert({
        'transaction_number': txNumber,
        'customer_id': customerId,
        'business_date': today,
        'subtotal': subtotal,
        'discount': 0,
        'total': total,
        'amount_paid': amountPaid,
        'payment_status': paymentStatus,
        'notes': notes,
      }).select('id').single();

      final distId = distRes['id'] as String;

      // 2. Insert items & stock movements out
      for (final it in items) {
        final qty = (it['quantity'] as num).toInt();
        final price = (it['unit_price'] as num).toInt();
        await client.from('distribution_items').insert({
          'distribution_id': distId,
          'product_id': it['product_id'],
          'quantity': qty,
          'unit_price': price,
          'subtotal': qty * price,
        });

        await client.from('stock_movements').insert({
          'product_id': it['product_id'],
          'movement_type': 'out',
          'quantity': qty,
          'source_type': 'distribution',
          'source_id': distId,
          'reason': 'Penjualan ke pelanggan',
          'business_date': today,
        });
      }

      // 3. Catat Piutang jika belum lunas / tempo
      if (amountPaid < total) {
        final remaining = total - amountPaid;
        await client.from('receivables').insert({
          'customer_id': customerId,
          'source_distribution_id': distId,
          'original_amount': total,
          'paid_amount': amountPaid,
          'remaining_amount': remaining,
          'status': paymentStatus,
        });
      }

      final totalQty = items.fold<int>(0, (sum, it) => sum + ((it['quantity'] as num?)?.toInt() ?? 0));
      // 4. Catat pemasukan kas riil ke cashflow_entries jika ada pembayaran
      if (amountPaid > 0) {
        await client.from('cashflow_entries').insert({
          'direction': 'in',
          'category': 'sales',
          'source_type': 'distribution',
          'source_id': distId,
          'business_date': today,
          'amount': amountPaid,
          'method': paymentMethod.toLowerCase(),
          'notes': notes?.isNotEmpty == true
              ? notes!
              : 'Penjualan gas ($totalQty tabung)',
        });
      }

      await fetchDistributions();
    } catch (e) {
      debugPrint('Error creating distribution in Supabase: $e');
      rethrow;
    }
  }

  /// Cancels an existing distribution transaction, restoring stock movements,
  /// removing associated cashflow entries and receivables.
  Future<void> cancelDistribution(String distributionId) async {
    try {
      final client = Supabase.instance.client;

      // 1. Delete associated cashflow entries
      await client.from('cashflow_entries').delete().eq('source_id', distributionId);

      // 2. Delete associated stock movements
      await client.from('stock_movements').delete().eq('source_id', distributionId);

      // 3. Delete associated receivables
      await client.from('receivables').delete().eq('source_distribution_id', distributionId);

      // 4. Delete associated items
      await client.from('distribution_items').delete().eq('distribution_id', distributionId);

      // 5. Delete distribution record
      await client.from('distributions').delete().eq('id', distributionId);

      await Future.wait([
        fetchDistributions(),
        InventoryRepository.instance.fetchInventory(),
        ReportsRepository.instance.fetchLiveReport(),
        DashboardRepository.instance.fetchDashboardMetrics(),
        DashboardRepository.instance.fetchCashflowEntries(),
        ReceivablesRepository.instance.fetchReceivables(),
        CustomersRepository.instance.fetchCustomers(),
      ]);
    } catch (e) {
      debugPrint('Error cancelling distribution in Supabase: $e');
      rethrow;
    }
  }
}
