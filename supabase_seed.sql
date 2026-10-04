-- ==============================================================================
-- GasHub Supabase Real Seed Data
-- Pangkalan Resmi LPG: Pangkalan Berkah (PKG-BRK-001)
-- Jalankan skrip SQL ini di Supabase SQL Editor untuk mengisi database dengan data riil
-- ==============================================================================

-- 1. BERSIHKAN DATA LAMA (Opsional / Idempoten)
truncate table audit_events, cashflow_entries, stock_movements, payments, receivables, 
               distribution_items, distributions, restock_schedule_items, restock_schedules, 
               restock_items, restocks, suppliers, customers, products cascade;

-- 2. MASTER PRODUK TABUNG GAS (HET & Modal Resmi Pertamina)
insert into products (id, name, variant, unit, purchase_price, selling_price, minimum_stock, active) values
('11111111-1111-1111-1111-111111111111', 'LPG 3kg Melon (Subsidi)', 'Subsidi 3kg', 'tabung', 16000, 19000, 50, true),
('22222222-2222-2222-2222-222222222222', 'LPG 12kg Biru (Non-Subsidi)', 'Non-Subsidi 12kg', 'tabung', 185000, 215000, 10, true),
('33333333-3333-3333-3333-333333333333', 'Bright Gas 5.5kg Pink', 'Non-Subsidi 5.5kg', 'tabung', 90000, 105000, 15, true);

-- 3. MASTER SUPPLIER (SPPBE Resmi Penyuplai Pasokan)
insert into suppliers (id, name, phone, address, notes, active) values
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'SPPBE PT Gas Perkasa Utama', '021-43901122', 'Kawasan Industri Tanjung Priok Blok B No. 4, Jakarta Utara', 'Agen & Pengisian Resmi Pertamina', true);

-- 4. MASTER PELANGGAN / MITRA WARUNG & PANGKALAN SEKITAR
insert into customers (id, name, phone, address, type, notes, active) values
('c1111111-1111-1111-1111-111111111111', 'Warung Madura Pak Joko', '0812-3456-7890', 'Jl. Melati Raya No. 12', 'warung', 'Langganan tetap, bayar tunai', true),
('c2222222-2222-2222-2222-222222222222', 'Toko Berkah Ibu', '0813-9876-5432', 'Jl. Mawar No. 45', 'toko', 'Pembayaran via Transfer BCA, tempo 7 hari', true),
('c3333333-3333-3333-3333-333333333333', 'Pangkalan Barokah H. Slamet', '0811-2233-4455', 'Jl. Kenanga No. 8', 'pangkalan', 'Pengambilan kuota besar, sering tempo', true),
('c4444444-4444-4444-4444-444444444444', 'Warung Kelontong Bu Siti', '0857-1122-3344', 'Jl. Anggrek No. 3', 'warung', 'Toko kelontong sembako & gas', true),
('c5555555-5555-5555-5555-555555555555', 'RM Padang Sederhana', '0821-4455-6677', 'Jl. Raya Pasar Minggu No. 99', 'warung', 'Restoran masakan padang pengguna 12kg', true);

-- 5. STOK AWAL & MUTASI KULAKAN PERDANA DARI SPPBE
insert into restocks (id, transaction_number, supplier_id, business_date, total, amount_paid, payment_status, notes) values
('r1111111-1111-1111-1111-111111111111', 'RST-202610-001', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', current_date - 1, 15150000, 15150000, 'paid', 'Restock DO Resmi Pertamina No. DO-77821');

insert into restock_items (id, restock_id, product_id, quantity, unit_cost, subtotal) values
(gen_random_uuid(), 'r1111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 500, 16000, 8000000),
(gen_random_uuid(), 'r1111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', 30, 185000, 5550000),
(gen_random_uuid(), 'r1111111-1111-1111-1111-111111111111', '33333333-3333-3333-3333-333333333333', 18, 90000, 1600000);

-- Catatan mutasi fisik stok tabung masuk
insert into stock_movements (product_id, movement_type, quantity, source_type, source_id, reason, business_date) values
('11111111-1111-1111-1111-111111111111', 'in', 500, 'restock', 'r1111111-1111-1111-1111-111111111111', 'Penerimaan pasokan SPPBE', current_date - 1),
('22222222-2222-2222-2222-222222222222', 'in', 30, 'restock', 'r1111111-1111-1111-1111-111111111111', 'Penerimaan pasokan SPPBE', current_date - 1),
('33333333-3333-3333-3333-333333333333', 'in', 18, 'restock', 'r1111111-1111-1111-1111-111111111111', 'Penerimaan pasokan SPPBE', current_date - 1);

-- 6. TRANSAKSI DISTRIBUSI PENJUALAN KE WARUNG MITRA
-- Transaksi 1: Warung Madura (Lunas Tunai)
insert into distributions (id, transaction_number, customer_id, business_date, subtotal, discount, total, amount_paid, payment_status, notes) values
('d1111111-1111-1111-1111-111111111111', 'DST-202610-001', 'c1111111-1111-1111-1111-111111111111', current_date, 715000, 0, 715000, 715000, 'paid', 'Tunai diterima langsung');
insert into distribution_items (distribution_id, product_id, quantity, unit_price, subtotal) values
('d1111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 15, 19000, 285000),
('d1111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', 2, 215000, 430000);

-- Transaksi 2: Toko Berkah Ibu (Sebagian / Tempo 7 hari)
insert into distributions (id, transaction_number, customer_id, business_date, subtotal, discount, total, amount_paid, payment_status, notes) values
('d2222222-2222-2222-2222-222222222222', 'DST-202610-002', 'c2222222-2222-2222-2222-222222222222', current_date, 760000, 0, 760000, 380000, 'partial', 'Bayar separuh via Transfer, sisa tempo 3 hari lagi');
insert into distribution_items (distribution_id, product_id, quantity, unit_price, subtotal) values
('d2222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 40, 19000, 760000);

-- Catatan Piutang Toko Berkah Ibu
insert into receivables (id, customer_id, source_distribution_id, original_amount, paid_amount, remaining_amount, status) values
(gen_random_uuid(), 'c2222222-2222-2222-2222-222222222222', 'd2222222-2222-2222-2222-222222222222', 760000, 380000, 380000, 'partial');

-- Transaksi 3: Pangkalan Barokah H. Slamet (Belum Bayar)
insert into distributions (id, transaction_number, customer_id, business_date, subtotal, discount, total, amount_paid, payment_status, notes) values
('d3333333-3333-3333-3333-333333333333', 'DST-202610-003', 'c3333333-3333-3333-3333-333333333333', current_date - 4, 1645000, 0, 1645000, 0, 'unpaid', 'Belum lunas, transaksi 4 hari lalu');
insert into distribution_items (distribution_id, product_id, quantity, unit_price, subtotal) values
('d3333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', 30, 19000, 570000),
('d3333333-3333-3333-3333-333333333333', '22222222-2222-2222-2222-222222222222', 5, 215000, 1075000);

-- Catatan Piutang Pangkalan Barokah H. Slamet
insert into receivables (id, customer_id, source_distribution_id, original_amount, paid_amount, remaining_amount, status) values
(gen_random_uuid(), 'c3333333-3333-3333-3333-333333333333', 'd3333333-3333-3333-3333-333333333333', 1645000, 0, 1645000, 'unpaid');

-- Transaksi 4: Warung Kelontong Bu Siti (Lunas Tunai)
insert into distributions (id, transaction_number, customer_id, business_date, subtotal, discount, total, amount_paid, payment_status, notes) values
('d4444444-4444-4444-4444-444444444444', 'DST-202610-004', 'c4444444-4444-4444-4444-444444444444', current_date, 190000, 0, 190000, 190000, 'paid', 'Lunas tunai');
insert into distribution_items (distribution_id, product_id, quantity, unit_price, subtotal) values
('d4444444-4444-4444-4444-444444444444', '11111111-1111-1111-1111-111111111111', 10, 19000, 190000);

-- Transaksi 5: RM Padang Sederhana (Lunas Tunai)
insert into distributions (id, transaction_number, customer_id, business_date, subtotal, discount, total, amount_paid, payment_status, notes) values
('d5555555-5555-5555-5555-555555555555', 'DST-202610-005', 'c5555555-5555-5555-5555-555555555555', current_date, 860000, 0, 860000, 860000, 'paid', 'Tabung 12kg untuk dapur resto');
insert into distribution_items (distribution_id, product_id, quantity, unit_price, subtotal) values
('d5555555-5555-5555-5555-555555555555', '22222222-2222-2222-2222-222222222222', 4, 215000, 860000);

-- 7. CATATAN ARUS KAS (CASHFLOW ENTRIES)
-- Kas Masuk
insert into cashflow_entries (direction, category, source_type, source_id, business_date, amount, method, notes) values
('in', 'sales', 'distribution', 'd1111111-1111-1111-1111-111111111111', current_date, 715000, 'cash', 'Penjualan DST-202610-001'),
('in', 'sales', 'distribution', 'd2222222-2222-2222-2222-222222222222', current_date, 380000, 'transfer', 'DP Penjualan DST-202610-002'),
('in', 'sales', 'distribution', 'd4444444-4444-4444-4444-444444444444', current_date, 190000, 'cash', 'Penjualan DST-202610-004'),
('in', 'sales', 'distribution', 'd5555555-5555-5555-5555-555555555555', current_date, 860000, 'cash', 'Penjualan DST-202610-005');

-- Kas Keluar (Operasional Harian)
insert into cashflow_entries (direction, category, source_type, source_id, business_date, amount, method, notes) values
('out', 'operations', 'expense', null, current_date, 35000, 'cash', 'Bensin pikap antar gas ke warung'),
('out', 'operations', 'expense', null, current_date, 40000, 'cash', 'Upah bongkar muat 2 pekerja harian');

-- SELESAI
select 'Seed Data GasHub Berhasil Dijalankan!' as status, 
       (select count(*) from products) as total_produk,
       (select count(*) from customers) as total_pelanggan,
       (select count(*) from distributions) as total_distribusi,
       (select count(*) from receivables) as total_piutang,
       (select count(*) from cashflow_entries) as total_arus_kas;
