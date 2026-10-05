import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/distribution_model.dart';

/// Repository managing LPG distribution transactions via Supabase PostgreSQL.
class DistributionRepository {
  DistributionRepository._() {
    fetchDistributions();
  }
  static final DistributionRepository instance = DistributionRepository._();

  final ValueNotifier<List<DistributionModel>> distributionsNotifier =
      ValueNotifier<List<DistributionModel>>([]);

  Future<List<DistributionModel>> fetchDistributions() async {
    try {
      final client = Supabase.instance.client;
      final res = await client.from('distributions').select('''
        id, transaction_number, business_date, subtotal, discount, total, amount_paid, payment_status, notes, created_at,
        customers(id, name, phone, address),
        distribution_items(quantity, unit_price, subtotal, products(id, name, variant))
      ''').order('business_date', ascending: false).order('created_at', ascending: false);

      final List<DistributionModel> mapped = [];

      for (final row in res as List<dynamic>) {
        final d = row as Map<String, dynamic>;
        final customer = d['customers'] as Map<String, dynamic>?;
        final customerName = customer?['name'] as String? ?? 'Pelanggan';

        final items = (d['distribution_items'] as List<dynamic>?) ?? [];
        int totalQty = 0;
        for (final item in items) {
          if (item is Map<String, dynamic>) {
            totalQty += (item['quantity'] as num?)?.toInt() ?? 0;
          }
        }

        final status = d['payment_status']?.toString() ?? 'unpaid';
        final date = DateTime.tryParse(d['business_date']?.toString() ?? '') ?? DateTime.now();
        final createdAt = DateTime.tryParse(d['created_at']?.toString() ?? '');
        final timeStr = createdAt != null
            ? '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')} WIB'
            : '12:00 WIB';

        mapped.add(DistributionModel(
          id: d['id'] as String,
          transactionNumber: d['transaction_number'] as String? ?? '',
          customerName: customerName,
          customerId: customer?['id'] as String?,
          qty: totalQty,
          date: date,
          time: timeStr,
          amount: (d['total'] as num?)?.toInt() ?? 0,
          amountPaid: (d['amount_paid'] as num?)?.toInt() ?? 0,
          status: status,
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

      // 2. Insert items
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

        // 3. Stock movement out
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

      // 4. If unpaid / partial -> record receivable
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

      // 5. If amountPaid > 0 -> record cashflow
      if (amountPaid > 0) {
        await client.from('cashflow_entries').insert({
          'direction': 'in',
          'category': 'sales',
          'source_type': 'distribution',
          'source_id': distId,
          'business_date': today,
          'amount': amountPaid,
          'method': 'cash',
          'notes': 'Penjualan $txNumber',
        });
      }

      await fetchDistributions();
    } catch (e) {
      debugPrint('Error creating distribution in Supabase: $e');
      rethrow;
    }
  }
}
