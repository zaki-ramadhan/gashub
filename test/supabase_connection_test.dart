import 'package:flutter_test/flutter_test.dart';
import 'package:gashub/core/constants/supabase_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('Verify Supabase connection and tables', () async {
    final client = SupabaseClient(
      SupabaseConstants.supabaseUrl,
      SupabaseConstants.supabasePublishableKey,
    );

    // Cek koneksi ke tabel products
    final products = await client.from('products').select();
    expect(products, isA<List>());

    // Cek koneksi ke tabel customers
    final customers = await client.from('customers').select();
    expect(customers, isA<List>());

    // Cek koneksi ke tabel distributions
    final distributions = await client.from('distributions').select();
    expect(distributions, isA<List>());
  });
}
