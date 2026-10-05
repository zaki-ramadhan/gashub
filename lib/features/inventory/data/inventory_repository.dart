import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/stock_models.dart';

/// Repository managing LPG cylinder inventory and stock movements via Supabase PostgreSQL.
class InventoryRepository {
  InventoryRepository._() {
    fetchInventory();
  }
  static final InventoryRepository instance = InventoryRepository._();

  final ValueNotifier<StockSummary> stockSummaryNotifier =
      ValueNotifier<StockSummary>(const StockSummary.zero());

  final ValueNotifier<List<StockLogItem>> stockLogsNotifier =
      ValueNotifier<List<StockLogItem>>([]);

  int get sellingPrice => stockSummaryNotifier.value.sellingPrice;

  Future<void> fetchInventory() async {
    try {
      final client = Supabase.instance.client;

      // 1. Fetch 3kg Product Price
      int sellingPrice = 19000;
      final productsRes = await client
          .from('products')
          .select('id, selling_price')
          .eq('variant', 'Subsidi 3kg')
          .maybeSingle();
      if (productsRes != null) {
        sellingPrice = (productsRes['selling_price'] as num?)?.toInt() ?? 19000;
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
      final loaned = totalOut;
      final empty = (totalIn - filled - loaned).clamp(0, 10000);

      stockSummaryNotifier.value = StockSummary(
        filled: filled,
        empty: empty,
        loaned: loaned,
        sellingPrice: sellingPrice,
      );

      stockLogsNotifier.value = logs;
    } catch (e) {
      debugPrint('Error fetching inventory from Supabase: $e');
    }
  }

  Future<void> updateSellingPrice(int newPrice) async {
    try {
      final client = Supabase.instance.client;
      await client
          .from('products')
          .update({'selling_price': newPrice})
          .eq('variant', 'Subsidi 3kg');
      await fetchInventory();
    } catch (e) {
      debugPrint('Error updating selling price: $e');
    }
  }

  Future<void> recordRestock({
    required int quantity,
    required String reason,
  }) async {
    try {
      final client = Supabase.instance.client;
      final today = DateTime.now().toIso8601String().split('T')[0];
      await client.from('stock_movements').insert({
        'product_id': '11111111-1111-1111-1111-111111111111',
        'movement_type': 'in',
        'quantity': quantity,
        'source_type': 'restock',
        'reason': reason,
        'business_date': today,
      });
      await fetchInventory();
    } catch (e) {
      debugPrint('Error recording restock: $e');
    }
  }
}
