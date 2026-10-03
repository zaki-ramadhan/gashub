-- GasHub Supabase PostgreSQL Schema
-- Sesuai spesifikasi GasHub_Final_Specification_FINAL/05_DATA/DATA_MODEL.md

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- 1. PRODUCTS
create table if not exists products (
    id uuid primary key default uuid_generate_v4(),
    name text not null,
    variant text not null default '',
    unit text not null default 'tabung',
    purchase_price bigint not null check (purchase_price >= 0),
    selling_price bigint not null check (selling_price >= 0),
    minimum_stock int not null default 0 check (minimum_stock >= 0),
    active boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- 2. CUSTOMERS (Pangkalan / Warung / Toko)
create table if not exists customers (
    id uuid primary key default uuid_generate_v4(),
    name text not null,
    phone text not null default '',
    address text not null default '',
    type text not null default 'warung',
    notes text not null default '',
    active boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- 3. SUPPLIERS (SPPBE / Agen Utama)
create table if not exists suppliers (
    id uuid primary key default uuid_generate_v4(),
    name text not null,
    phone text not null default '',
    address text not null default '',
    notes text not null default '',
    active boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- 4. DISTRIBUTIONS (Transaksi Penjualan ke Warung)
create table if not exists distributions (
    id uuid primary key default uuid_generate_v4(),
    transaction_number text not null unique,
    customer_id uuid not null references customers(id) on delete restrict,
    business_date date not null default current_date,
    subtotal bigint not null check (subtotal >= 0),
    discount bigint not null default 0 check (discount >= 0),
    total bigint not null check (total >= 0),
    amount_paid bigint not null default 0 check (amount_paid >= 0),
    payment_status text not null default 'pending', -- pending, partial, paid
    notes text not null default '',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- 5. DISTRIBUTION ITEMS
create table if not exists distribution_items (
    id uuid primary key default uuid_generate_v4(),
    distribution_id uuid not null references distributions(id) on delete cascade,
    product_id uuid not null references products(id) on delete restrict,
    quantity int not null check (quantity > 0),
    unit_price bigint not null check (unit_price >= 0),
    subtotal bigint not null check (subtotal >= 0)
);

-- 6. RECEIVABLES (Piutang Usaha)
create table if not exists receivables (
    id uuid primary key default uuid_generate_v4(),
    customer_id uuid not null references customers(id) on delete restrict,
    source_distribution_id uuid not null references distributions(id) on delete restrict,
    original_amount bigint not null check (original_amount >= 0),
    paid_amount bigint not null default 0 check (paid_amount >= 0),
    remaining_amount bigint not null check (remaining_amount >= 0),
    due_date date,
    status text not null default 'unpaid', -- unpaid, partial, paid
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- 7. PAYMENTS (Pelunasan Piutang)
create table if not exists payments (
    id uuid primary key default uuid_generate_v4(),
    payment_number text not null unique,
    customer_id uuid not null references customers(id) on delete restrict,
    receivable_id uuid not null references receivables(id) on delete restrict,
    business_date date not null default current_date,
    amount bigint not null check (amount > 0),
    method text not null default 'cash', -- cash, transfer
    notes text not null default '',
    created_at timestamptz not null default now()
);

-- 8. RESTOCKS (Kulakan Riil Masuk)
create table if not exists restocks (
    id uuid primary key default uuid_generate_v4(),
    transaction_number text not null unique,
    supplier_id uuid not null references suppliers(id) on delete restrict,
    business_date date not null default current_date,
    total bigint not null check (total >= 0),
    amount_paid bigint not null default 0 check (amount_paid >= 0),
    payment_status text not null default 'paid', -- paid, partial, debt
    notes text not null default '',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- 9. RESTOCK ITEMS
create table if not exists restock_items (
    id uuid primary key default uuid_generate_v4(),
    restock_id uuid not null references restocks(id) on delete cascade,
    product_id uuid not null references products(id) on delete restrict,
    quantity int not null check (quantity > 0),
    unit_cost bigint not null check (unit_cost >= 0),
    subtotal bigint not null check (subtotal >= 0)
);

-- 10. RESTOCK SCHEDULES (Rencana Restock - TIDAK memotong stok/kas sebelum riil)
create table if not exists restock_schedules (
    id uuid primary key default uuid_generate_v4(),
    supplier_id uuid not null references suppliers(id) on delete restrict,
    scheduled_date date not null,
    status text not null default 'scheduled', -- scheduled, confirmed, completed, cancelled
    notes text not null default '',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists restock_schedule_items (
    id uuid primary key default uuid_generate_v4(),
    schedule_id uuid not null references restock_schedules(id) on delete cascade,
    product_id uuid not null references products(id) on delete restrict,
    planned_quantity int not null check (planned_quantity > 0)
);

-- 11. STOCK MOVEMENTS (Buku Kas & Mutasi Stok Fisik)
create table if not exists stock_movements (
    id uuid primary key default uuid_generate_v4(),
    product_id uuid not null references products(id) on delete restrict,
    movement_type text not null, -- in, out, adjustment, return
    quantity int not null,
    source_type text not null, -- distribution, restock, manual_adjustment
    source_id uuid,
    reason text not null default '',
    business_date date not null default current_date,
    created_at timestamptz not null default now()
);

-- 12. CASHFLOW ENTRIES (Arus Kas Masuk / Keluar)
create table if not exists cashflow_entries (
    id uuid primary key default uuid_generate_v4(),
    direction text not null check (direction in ('in', 'out')),
    category text not null, -- sales_payment, debt_collection, restock_payment, operational_expense
    source_type text not null, -- distribution, payment, restock, operational
    source_id uuid,
    business_date date not null default current_date,
    amount bigint not null check (amount > 0),
    method text not null default 'cash', -- cash, transfer
    notes text not null default '',
    created_at timestamptz not null default now()
);

-- 13. AUDIT EVENTS (Audit Trail)
create table if not exists audit_events (
    id uuid primary key default uuid_generate_v4(),
    entity_type text not null,
    entity_id uuid not null,
    action text not null, -- create, update, reverse
    before_snapshot jsonb,
    after_snapshot jsonb,
    reason text not null default '',
    created_at timestamptz not null default now()
);

-- INDEXING
create index if not exists idx_distributions_customer_date on distributions(customer_id, business_date);
create index if not exists idx_receivables_customer_status on receivables(customer_id, status);
create index if not exists idx_payments_receivable on payments(receivable_id);
create index if not exists idx_stock_movements_product_date on stock_movements(product_id, business_date);
create index if not exists idx_cashflow_direction_date on cashflow_entries(direction, business_date);
