import 'package:flutter_test/flutter_test.dart';
import 'package:gashub/core/constants/supabase_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('Verify Supabase connection and tables', () async {
    final client = SupabaseClient(
      SupabaseConstants.supabaseUrl,
      SupabaseConstants.supabasePublishableKey,
    );

    final products = await client.from('products').select();
    final customers = await client.from('customers').select();
    final distributions = await client.from('distributions').select();
    final cashflow = await client.from('cashflow_entries').select();
    int cashIn = 0;
    int cashOut = 0;
    for (final row in cashflow as List<dynamic>) {
      final m = row as Map<String, dynamic>;
      final amt = (m['amount'] as num?)?.toInt() ?? 0;
      if (m['direction'] == 'in') {
        cashIn += amt;
      } else {
        cashOut += amt;
      }
    }
    print('Cash In: $cashIn, Cash Out: $cashOut, Net: ${cashIn - cashOut}');
  });
}
