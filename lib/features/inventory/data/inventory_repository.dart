import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../dashboard/data/dashboard_repository.dart';
import '../../reports/data/reports_repository.dart';
import '../domain/stock_models.dart';

/// Repository managing LPG cylinder inventory and stock movements via Supabase PostgreSQL.
class InventoryRepository {
  InventoryRepository._();
  static final InventoryRepository instance = InventoryRepository._();

  final ValueNotifier<StockSummary> stockSummaryNotifier =
      ValueNotifier<StockSummary>(const StockSummary.zero());

  final ValueNotifier<List<StockLogItem>> stockLogsNotifier =
      ValueNotifier<List<StockLogItem>>([]);

  String _productId = '11111111-1111-1111-1111-111111111111';
  String get defaultProductId => _productId;

  int get sellingPrice {
    try {
      final dynamic val = stockSummaryNotifier.value.sellingPrice;
      if (val is int && val > 0) return val;
      return 19000;
    } catch (_) {
      return 19000;
    }
  }

  int get purchasePrice {
    try {
      final dynamic val = stockSummaryNotifier.value.purchasePrice;
      if (val is int && val > 0) return val;
      return 16000;
    } catch (_) {
      return 16000;
    }
  }

  Future<void> fetchInventory() async {
    try {
      final client = Supabase.instance.client;

      // 1. Fetch 3kg Product Prices
      int sellingPrice = 19000;
      int purchasePrice = 16000;
      final productsRes = await client
          .from('products')
          .select('id, selling_price, purchase_price')
          .eq('variant', 'Subsidi 3kg')
          .maybeSingle();
      if (productsRes != null) {
        if (productsRes['id'] != null) {
          _productId = productsRes['id'] as String;
        }
        sellingPrice = (productsRes['selling_price'] as num?)?.toInt() ?? 19000;
        purchasePrice = (productsRes['purchase_price'] as num?)?.toInt() ?? 16000;
      }

      // 2. Fetch Stock Movements
      final movementsRes = await client.from('stock_movements').select('''
        id, product_id, movement_type, quantity, source_type, reason, business_date, created_at,
        products(id, name, variant)
      ''').order('business_date', ascending: false).order('created_at', ascending: false);

      final List<StockLogItem> logs = [];
      int totalIn = 0;
      int totalOut = 0;

      for (final row in movementsRes as List<dynamic>) {
        final m = row as Map<String, dynamic>;
        final isMasuk = m['movement_type'] == 'in';
        final qty = (m['quantity'] as num?)?.toInt() ?? 0;

        if (isMasuk) {
          totalIn += qty;
        } else {
          totalOut += qty;
        }

        final date = DateTime.tryParse(m['business_date']?.toString() ?? '') ?? DateTime.now();
        final createdAt = DateTime.tryParse(m['created_at']?.toString() ?? '');
        final timeStr = createdAt != null
            ? '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')} WIB'
            : '10:00 WIB';

        logs.add(StockLogItem(
          id: m['id'] as String,
          title: m['reason']?.toString() ?? (isMasuk ? 'Pasokan Masuk SPPBE' : 'Kirim ke Pelanggan'),
          qty: qty,
          isMasuk: isMasuk,
          date: date,
          time: timeStr,
        ));
      }

      final filled = (totalIn - totalOut).clamp(0, 10000);
      final empty = totalOut.clamp(0, 10000);
      const loaned = 0;

      stockSummaryNotifier.value = StockSummary(
        filled: filled,
        empty: empty,
        loaned: loaned,
        sellingPrice: sellingPrice,
        purchasePrice: purchasePrice,
      );

      stockLogsNotifier.value = logs;
    } catch (e) {
      debugPrint('Error fetching inventory from Supabase: $e');
    }
  }

  Future<void> updatePrices({
    required int sellingPrice,
    required int purchasePrice,
  }) async {
    try {
      final client = Supabase.instance.client;
      await client
          .from('products')
          .update({
            'selling_price': sellingPrice,
            'purchase_price': purchasePrice,
          })
          .eq('variant', 'Subsidi 3kg');
      await fetchInventory();
    } catch (e) {
      debugPrint('Error updating prices: $e');
    }
  }

  Future<void> updateSellingPrice(int newPrice) async {
    return updatePrices(
      sellingPrice: newPrice,
      purchasePrice: purchasePrice,
    );
  }

  Future<void> recordRestock({
    required int quantity,
    required String reason,
  }) async {
    try {
      final client = Supabase.instance.client;
      final today = DateTime.now().toIso8601String().split('T')[0];
      final txNumber = 'RST-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

      final unitCost = purchasePrice > 0 ? purchasePrice : 16000;
      final totalCost = quantity * unitCost;

      // 1. Resolve supplier
      String supplierId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
      try {
        final suppRes = await client.from('suppliers').select('id').limit(1).maybeSingle();
        if (suppRes != null && suppRes['id'] != null) {
          supplierId = suppRes['id'] as String;
        }
      } catch (_) {}

      // 2. Insert restock record
      final restockRes = await client.from('restocks').insert({
        'transaction_number': txNumber,
        'supplier_id': supplierId,
        'business_date': today,
        'total': totalCost,
        'amount_paid': totalCost,
        'payment_status': 'paid',
        'notes': reason,
      }).select('id').single();
      final restockId = restockRes['id'] as String;

      // 3. Insert restock items
      await client.from('restock_items').insert({
        'restock_id': restockId,
        'product_id': defaultProductId,
        'quantity': quantity,
        'unit_cost': unitCost,
        'subtotal': totalCost,
      });

      // 4. Record stock movement
      await client.from('stock_movements').insert({
        'product_id': defaultProductId,
        'movement_type': 'in',
        'quantity': quantity,
        'source_type': 'restock',
        'source_id': restockId,
        'reason': reason,
        'business_date': today,
      });

      // 5. Record cashflow out for purchase
      await client.from('cashflow_entries').insert({
        'direction': 'out',
        'category': 'restock',
        'source_type': 'restock',
        'source_id': restockId,
        'business_date': today,
        'amount': totalCost,
        'method': 'cash',
        'notes': 'Kulakan pasokan tabung ($quantity tabung)',
      });

      await Future.wait([
        fetchInventory(),
        DashboardRepository.instance.fetchDashboardMetrics(),
        DashboardRepository.instance.fetchCashflowEntries(),
        ReportsRepository.instance.fetchLiveReport(),
      ]);
    } catch (e) {
      debugPrint('Error recording restock: $e');
      rethrow;
    }
  }
}
