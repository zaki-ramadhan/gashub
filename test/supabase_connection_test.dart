// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:gashub/core/constants/supabase_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('Verify all Supabase queries used in Dashboard', () async {
    try {
      final client = SupabaseClient(
        SupabaseConstants.supabaseUrl,
        SupabaseConstants.supabasePublishableKey,
      );

      print('Testing query 1: cashflow metrics');
      final q1 = await client.from('cashflow_entries').select('amount, direction, business_date');
      print('Q1 count: ${q1.length}');

      print('Testing query 2: cashflow entries');
      final q2 = await client
          .from('cashflow_entries')
          .select('id, direction, category, source_type, source_id, business_date, created_at, amount, method, notes')
          .order('business_date', ascending: false)
          .order('created_at', ascending: false);
      print('Q2 count: ${q2.length}');

      print('Testing query 3: distributions with joins');
      final q3 = await client.from('distributions').select('''
          id, transaction_number, business_date, subtotal, discount, total, amount_paid, payment_status, notes, created_at,
          customers(id, name, phone, address),
          distribution_items(
            quantity, unit_price, subtotal,
            products(id, name, variant, purchase_price)
          )
        ''').order('business_date', ascending: false).order('created_at', ascending: false);
      print('Q3 count: ${q3.length}');

      print('Testing query 4: customers with joins');
      final q4 = await client.from('customers').select('''
          id, name, phone, address, type, notes, active,
          receivables(id, remaining_amount, status),
          distributions(
            id, transaction_number, business_date, total, amount_paid, payment_status,
            distribution_items(quantity, unit_price, subtotal, product_id)
          )
        ''').order('name', ascending: true);
      print('Q4 count: ${q4.length}');

      print('All 4 queries completed successfully!');
    } catch (e, st) {
      print('FAILED WITH ERROR: $e');
      print(st);
      rethrow;
    }
  }, timeout: const Timeout(Duration(seconds: 15)));
}
