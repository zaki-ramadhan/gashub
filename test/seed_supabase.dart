import 'package:flutter_test/flutter_test.dart';
import 'package:gashub/core/constants/supabase_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('Seed Supabase database with real operational dataset', () async {
    final client = SupabaseClient(
      SupabaseConstants.supabaseUrl,
      SupabaseConstants.supabasePublishableKey,
    );

    final today = DateTime.now().toIso8601String().split('T')[0];
    final yesterday = DateTime.now().subtract(const Duration(days: 1)).toIso8601String().split('T')[0];
    final fourDaysAgo = DateTime.now().subtract(const Duration(days: 4)).toIso8601String().split('T')[0];

    // 1. Products
    print('Seeding products...');
    await client.from('products').upsert([
      {
        'id': '11111111-1111-1111-1111-111111111111',
        'name': 'LPG 3kg Melon (Subsidi)',
        'variant': 'Subsidi 3kg',
        'unit': 'tabung',
        'purchase_price': 16000,
        'selling_price': 19000,
        'minimum_stock': 50,
        'active': true,
      },
      {
        'id': '22222222-2222-2222-2222-222222222222',
        'name': 'LPG 12kg Biru (Non-Subsidi)',
        'variant': 'Non-Subsidi 12kg',
        'unit': 'tabung',
        'purchase_price': 185000,
        'selling_price': 215000,
        'minimum_stock': 10,
        'active': true,
      },
      {
        'id': '33333333-3333-3333-3333-333333333333',
        'name': 'Bright Gas 5.5kg Pink',
        'variant': 'Non-Subsidi 5.5kg',
        'unit': 'tabung',
        'purchase_price': 90000,
        'selling_price': 105000,
        'minimum_stock': 15,
        'active': true,
      },
    ]);

    // 2. Suppliers
    print('Seeding suppliers...');
    await client.from('suppliers').upsert([
      {
        'id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        'name': 'SPPBE PT Gas Perkasa Utama',
        'phone': '021-43901122',
        'address': 'Kawasan Industri Tanjung Priok Blok B No. 4, Jakarta Utara',
        'notes': 'Agen & Pengisian Resmi Pertamina',
        'active': true,
      }
    ]);

    // 3. Customers
    print('Seeding customers...');
    await client.from('customers').upsert([
      {
        'id': 'c1111111-1111-1111-1111-111111111111',
        'name': 'Warung Madura Pak Joko',
        'phone': '0812-3456-7890',
        'address': 'Jl. Melati Raya No. 12',
        'type': 'warung',
        'notes': 'Langganan tetap, bayar tunai',
        'active': true,
      },
      {
        'id': 'c2222222-2222-2222-2222-222222222222',
        'name': 'Toko Berkah Ibu',
        'phone': '0813-9876-5432',
        'address': 'Jl. Mawar No. 45',
        'type': 'toko',
        'notes': 'Pembayaran via Transfer BCA, tempo 7 hari',
        'active': true,
      },
      {
        'id': 'c3333333-3333-3333-3333-333333333333',
        'name': 'Pangkalan Barokah H. Slamet',
        'phone': '0811-2233-4455',
        'address': 'Jl. Kenanga No. 8',
        'type': 'pangkalan',
        'notes': 'Pengambilan kuota besar, sering tempo',
        'active': true,
      },
      {
        'id': 'c4444444-4444-4444-4444-444444444444',
        'name': 'Warung Kelontong Bu Siti',
        'phone': '0857-1122-3344',
        'address': 'Jl. Anggrek No. 3',
        'type': 'warung',
        'notes': 'Toko kelontong sembako & gas',
        'active': true,
      },
      {
        'id': 'c5555555-5555-5555-5555-555555555555',
        'name': 'RM Padang Sederhana',
        'phone': '0821-4455-6677',
        'address': 'Jl. Raya Pasar Minggu No. 99',
        'type': 'warung',
        'notes': 'Restoran masakan padang pengguna 12kg',
        'active': true,
      },
    ]);

    // 4. Restocks
    print('Seeding restocks...');
    await client.from('restocks').upsert([
      {
        'id': 'b1111111-1111-1111-1111-111111111111',
        'transaction_number': 'RST-202610-001',
        'supplier_id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        'business_date': yesterday,
        'total': 15150000,
        'amount_paid': 15150000,
        'payment_status': 'paid',
        'notes': 'Restock DO Resmi Pertamina No. DO-77821',
      }
    ]);

    // 5. Stock movements
    print('Seeding stock movements...');
    await client.from('stock_movements').upsert([
      {
        'product_id': '11111111-1111-1111-1111-111111111111',
        'movement_type': 'in',
        'quantity': 500,
        'source_type': 'restock',
        'source_id': 'b1111111-1111-1111-1111-111111111111',
        'reason': 'Penerimaan pasokan SPPBE',
        'business_date': yesterday,
      },
      {
        'product_id': '22222222-2222-2222-2222-222222222222',
        'movement_type': 'in',
        'quantity': 30,
        'source_type': 'restock',
        'source_id': 'b1111111-1111-1111-1111-111111111111',
        'reason': 'Penerimaan pasokan SPPBE',
        'business_date': yesterday,
      },
      {
        'product_id': '33333333-3333-3333-3333-333333333333',
        'movement_type': 'in',
        'quantity': 18,
        'source_type': 'restock',
        'source_id': 'b1111111-1111-1111-1111-111111111111',
        'reason': 'Penerimaan pasokan SPPBE',
        'business_date': yesterday,
      },
      {
        'product_id': '11111111-1111-1111-1111-111111111111',
        'movement_type': 'out',
        'quantity': 15,
        'source_type': 'distribution',
        'source_id': 'd1111111-1111-1111-1111-111111111111',
        'reason': 'Kirim ke Warung Madura Pak Joko',
        'business_date': today,
      },
      {
        'product_id': '11111111-1111-1111-1111-111111111111',
        'movement_type': 'out',
        'quantity': 40,
        'source_type': 'distribution',
        'source_id': 'd2222222-2222-2222-2222-222222222222',
        'reason': 'Kirim ke Toko Berkah Ibu',
        'business_date': today,
      },
      {
        'product_id': '11111111-1111-1111-1111-111111111111',
        'movement_type': 'out',
        'quantity': 30,
        'source_type': 'distribution',
        'source_id': 'd3333333-3333-3333-3333-333333333333',
        'reason': 'Kirim ke Pangkalan Barokah H. Slamet',
        'business_date': fourDaysAgo,
      },
      {
        'product_id': '11111111-1111-1111-1111-111111111111',
        'movement_type': 'out',
        'quantity': 10,
        'source_type': 'distribution',
        'source_id': 'd4444444-4444-4444-4444-444444444444',
        'reason': 'Kirim ke Warung Kelontong Bu Siti',
        'business_date': today,
      },
    ]);

    // 6. Distributions
    print('Seeding distributions...');
    await client.from('distributions').upsert([
      {
        'id': 'd1111111-1111-1111-1111-111111111111',
        'transaction_number': 'DST-202610-001',
        'customer_id': 'c1111111-1111-1111-1111-111111111111',
        'business_date': today,
        'subtotal': 715000,
        'discount': 0,
        'total': 715000,
        'amount_paid': 715000,
        'payment_status': 'paid',
        'notes': 'Tunai diterima langsung',
      },
      {
        'id': 'd2222222-2222-2222-2222-222222222222',
        'transaction_number': 'DST-202610-002',
        'customer_id': 'c2222222-2222-2222-2222-222222222222',
        'business_date': today,
        'subtotal': 760000,
        'discount': 0,
        'total': 760000,
        'amount_paid': 380000,
        'payment_status': 'partial',
        'notes': 'Bayar separuh via Transfer, sisa tempo 3 hari lagi',
      },
      {
        'id': 'd3333333-3333-3333-3333-333333333333',
        'transaction_number': 'DST-202610-003',
        'customer_id': 'c3333333-3333-3333-3333-333333333333',
        'business_date': fourDaysAgo,
        'subtotal': 1645000,
        'discount': 0,
        'total': 1645000,
        'amount_paid': 0,
        'payment_status': 'unpaid',
        'notes': 'Belum lunas, transaksi 4 hari lalu',
      },
      {
        'id': 'd4444444-4444-4444-4444-444444444444',
        'transaction_number': 'DST-202610-004',
        'customer_id': 'c4444444-4444-4444-4444-444444444444',
        'business_date': today,
        'subtotal': 190000,
        'discount': 0,
        'total': 190000,
        'amount_paid': 190000,
        'payment_status': 'paid',
        'notes': 'Lunas tunai',
      },
      {
        'id': 'd5555555-5555-5555-5555-555555555555',
        'transaction_number': 'DST-202610-005',
        'customer_id': 'c5555555-5555-5555-5555-555555555555',
        'business_date': today,
        'subtotal': 860000,
        'discount': 0,
        'total': 860000,
        'amount_paid': 860000,
        'payment_status': 'paid',
        'notes': 'Tabung 12kg untuk dapur resto',
      },
    ]);

    // 7. Distribution Items
    print('Seeding distribution items...');
    await client.from('distribution_items').upsert([
      {
        'distribution_id': 'd1111111-1111-1111-1111-111111111111',
        'product_id': '11111111-1111-1111-1111-111111111111',
        'quantity': 15,
        'unit_price': 19000,
        'subtotal': 285000,
      },
      {
        'distribution_id': 'd1111111-1111-1111-1111-111111111111',
        'product_id': '22222222-2222-2222-2222-222222222222',
        'quantity': 2,
        'unit_price': 215000,
        'subtotal': 430000,
      },
      {
        'distribution_id': 'd2222222-2222-2222-2222-222222222222',
        'product_id': '11111111-1111-1111-1111-111111111111',
        'quantity': 40,
        'unit_price': 19000,
        'subtotal': 760000,
      },
      {
        'distribution_id': 'd3333333-3333-3333-3333-333333333333',
        'product_id': '11111111-1111-1111-1111-111111111111',
        'quantity': 30,
        'unit_price': 19000,
        'subtotal': 570000,
      },
      {
        'distribution_id': 'd3333333-3333-3333-3333-333333333333',
        'product_id': '22222222-2222-2222-2222-222222222222',
        'quantity': 5,
        'unit_price': 215000,
        'subtotal': 1075000,
      },
      {
        'distribution_id': 'd4444444-4444-4444-4444-444444444444',
        'product_id': '11111111-1111-1111-1111-111111111111',
        'quantity': 10,
        'unit_price': 19000,
        'subtotal': 190000,
      },
      {
        'distribution_id': 'd5555555-5555-5555-5555-555555555555',
        'product_id': '22222222-2222-2222-2222-222222222222',
        'quantity': 4,
        'unit_price': 215000,
        'subtotal': 860000,
      },
    ]);

    // 8. Receivables
    print('Seeding receivables...');
    await client.from('receivables').upsert([
      {
        'id': 'e1111111-1111-1111-1111-111111111111',
        'customer_id': 'c2222222-2222-2222-2222-222222222222',
        'source_distribution_id': 'd2222222-2222-2222-2222-222222222222',
        'original_amount': 760000,
        'paid_amount': 380000,
        'remaining_amount': 380000,
        'status': 'partial',
      },
      {
        'id': 'e2222222-2222-2222-2222-222222222222',
        'customer_id': 'c3333333-3333-3333-3333-333333333333',
        'source_distribution_id': 'd3333333-3333-3333-3333-333333333333',
        'original_amount': 1645000,
        'paid_amount': 0,
        'remaining_amount': 1645000,
        'status': 'unpaid',
      },
    ]);

    // 9. Cashflow
    print('Seeding cashflow entries...');
    await client.from('cashflow_entries').upsert([
      {
        'direction': 'in',
        'category': 'sales',
        'source_type': 'distribution',
        'source_id': 'd1111111-1111-1111-1111-111111111111',
        'business_date': today,
        'amount': 715000,
        'method': 'cash',
        'notes': 'Penjualan DST-202610-001',
      },
      {
        'direction': 'in',
        'category': 'sales',
        'source_type': 'distribution',
        'source_id': 'd2222222-2222-2222-2222-222222222222',
        'business_date': today,
        'amount': 380000,
        'method': 'transfer',
        'notes': 'DP Penjualan DST-202610-002',
      },
      {
        'direction': 'in',
        'category': 'sales',
        'source_type': 'distribution',
        'source_id': 'd4444444-4444-4444-4444-444444444444',
        'business_date': today,
        'amount': 190000,
        'method': 'cash',
        'notes': 'Penjualan DST-202610-004',
      },
      {
        'direction': 'in',
        'category': 'sales',
        'source_type': 'distribution',
        'source_id': 'd5555555-5555-5555-5555-555555555555',
        'business_date': today,
        'amount': 860000,
        'method': 'cash',
        'notes': 'Penjualan DST-202610-005',
      },
      {
        'direction': 'out',
        'category': 'operations',
        'source_type': 'expense',
        'source_id': null,
        'business_date': today,
        'amount': 35000,
        'method': 'cash',
        'notes': 'Bensin pikap antar gas ke warung',
      },
      {
        'direction': 'out',
        'category': 'operations',
        'source_type': 'expense',
        'source_id': null,
        'business_date': today,
        'amount': 40000,
        'method': 'cash',
        'notes': 'Upah bongkar muat 2 pekerja harian',
      },
    ]);

    // 10. Restock Schedule (Jadwal Muat Pasokan)
    print('Seeding restock schedule for tomorrow...');
    final tomorrow = DateTime.now().add(const Duration(days: 1)).toIso8601String().split('T')[0];
    await client.from('restock_schedules').upsert([
      {
        'id': '61111111-1111-1111-1111-111111111111',
        'supplier_id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        'scheduled_date': tomorrow,
        'status': 'scheduled',
        'notes': 'Muat pagi kuota DO Pertamina 100 tabung 3kg',
      },
    ]);

    print('Seeding completed successfully!');
  });
}
