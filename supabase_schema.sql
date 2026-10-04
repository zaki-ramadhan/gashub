-- ==============================================================================
-- GasHub Supabase PostgreSQL Schema (Clean & Warning-Free)
-- ==============================================================================

-- 1. PRODUCTS
create table if not exists products (
    id uuid primary key default gen_random_uuid(),
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
alter table products enable row level security;
create policy "Allow all on products" on products for all using (true) with check (true);

-- 2. CUSTOMERS (Pangkalan / Warung / Toko)
create table if not exists customers (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    phone text not null default '',
    address text not null default '',
    type text not null default 'warung',
    notes text not null default '',
    active boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);
alter table customers enable row level security;
create policy "Allow all on customers" on customers for all using (true) with check (true);

-- 3. SUPPLIERS (SPPBE / Agen Utama)
create table if not exists suppliers (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    phone text not null default '',
    address text not null default '',
    notes text not null default '',
    active boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);
alter table suppliers enable row level security;
create policy "Allow all on suppliers" on suppliers for all using (true) with check (true);

-- 4. DISTRIBUTIONS (Transaksi Penjualan ke Warung)
create table if not exists distributions (
    id uuid primary key default gen_random_uuid(),
    transaction_number text not null unique,
    customer_id uuid not null references customers(id) on delete restrict,
    business_date date not null default current_date,
    subtotal bigint not null check (subtotal >= 0),
    discount bigint not null default 0 check (discount >= 0),
    total bigint not null check (total >= 0),
    amount_paid bigint not null default 0 check (amount_paid >= 0),
    payment_status text not null default 'pending',
    notes text not null default '',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);
alter table distributions enable row level security;
create policy "Allow all on distributions" on distributions for all using (true) with check (true);

-- 5. DISTRIBUTION ITEMS
create table if not exists distribution_items (
    id uuid primary key default gen_random_uuid(),
    distribution_id uuid not null references distributions(id) on delete cascade,
    product_id uuid not null references products(id) on delete restrict,
    quantity int not null check (quantity > 0),
    unit_price bigint not null check (unit_price >= 0),
    subtotal bigint not null check (subtotal >= 0)
);
alter table distribution_items enable row level security;
create policy "Allow all on distribution_items" on distribution_items for all using (true) with check (true);

-- 6. RECEIVABLES (Piutang Usaha)
create table if not exists receivables (
    id uuid primary key default gen_random_uuid(),
    customer_id uuid not null references customers(id) on delete restrict,
    source_distribution_id uuid not null references distributions(id) on delete restrict,
    original_amount bigint not null check (original_amount >= 0),
    paid_amount bigint not null default 0 check (paid_amount >= 0),
    remaining_amount bigint not null check (remaining_amount >= 0),
    status text not null default 'unpaid',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);
alter table receivables enable row level security;
create policy "Allow all on receivables" on receivables for all using (true) with check (true);

-- 7. PAYMENTS (Pelunasan Piutang)
create table if not exists payments (
    id uuid primary key default gen_random_uuid(),
    payment_number text not null unique,
    customer_id uuid not null references customers(id) on delete restrict,
    receivable_id uuid not null references receivables(id) on delete restrict,
    business_date date not null default current_date,
    amount bigint not null check (amount > 0),
    method text not null default 'cash',
    notes text not null default '',
    created_at timestamptz not null default now()
);
alter table payments enable row level security;
create policy "Allow all on payments" on payments for all using (true) with check (true);

-- 8. RESTOCKS (Kulakan Riil Masuk)
create table if not exists restocks (
    id uuid primary key default gen_random_uuid(),
    transaction_number text not null unique,
    supplier_id uuid not null references suppliers(id) on delete restrict,
    business_date date not null default current_date,
    total bigint not null check (total >= 0),
    amount_paid bigint not null default 0 check (amount_paid >= 0),
    payment_status text not null default 'paid',
    notes text not null default '',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);
alter table restocks enable row level security;
create policy "Allow all on restocks" on restocks for all using (true) with check (true);

-- 9. RESTOCK ITEMS
create table if not exists restock_items (
    id uuid primary key default gen_random_uuid(),
    restock_id uuid not null references restocks(id) on delete cascade,
    product_id uuid not null references products(id) on delete restrict,
    quantity int not null check (quantity > 0),
    unit_cost bigint not null check (unit_cost >= 0),
    subtotal bigint not null check (subtotal >= 0)
);
alter table restock_items enable row level security;
create policy "Allow all on restock_items" on restock_items for all using (true) with check (true);

-- 10. RESTOCK SCHEDULES (Rencana Jadwal Pasokan)
create table if not exists restock_schedules (
    id uuid primary key default gen_random_uuid(),
    supplier_id uuid not null references suppliers(id) on delete restrict,
    scheduled_date date not null,
    status text not null default 'scheduled',
    notes text not null default '',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);
alter table restock_schedules enable row level security;
create policy "Allow all on restock_schedules" on restock_schedules for all using (true) with check (true);

create table if not exists restock_schedule_items (
    id uuid primary key default gen_random_uuid(),
    schedule_id uuid not null references restock_schedules(id) on delete cascade,
    product_id uuid not null references products(id) on delete restrict,
    planned_quantity int not null check (planned_quantity > 0)
);
alter table restock_schedule_items enable row level security;
create policy "Allow all on restock_schedule_items" on restock_schedule_items for all using (true) with check (true);

-- 11. STOCK MOVEMENTS (Buku Mutasi Fisik Tabung)
create table if not exists stock_movements (
    id uuid primary key default gen_random_uuid(),
    product_id uuid not null references products(id) on delete restrict,
    movement_type text not null,
    quantity int not null,
    source_type text not null,
    source_id uuid,
    reason text not null default '',
    business_date date not null default current_date,
    created_at timestamptz not null default now()
);
alter table stock_movements enable row level security;
create policy "Allow all on stock_movements" on stock_movements for all using (true) with check (true);

-- 12. CASHFLOW ENTRIES (Buku Kas Masuk / Keluar)
create table if not exists cashflow_entries (
    id uuid primary key default gen_random_uuid(),
    direction text not null check (direction in ('in', 'out')),
    category text not null,
    source_type text not null,
    source_id uuid,
    business_date date not null default current_date,
    amount bigint not null check (amount > 0),
    method text not null default 'cash',
    notes text not null default '',
    created_at timestamptz not null default now()
);
alter table cashflow_entries enable row level security;
create policy "Allow all on cashflow_entries" on cashflow_entries for all using (true) with check (true);

-- 13. AUDIT EVENTS (Audit Trail)
create table if not exists audit_events (
    id uuid primary key default gen_random_uuid(),
    entity_type text not null,
    entity_id uuid not null,
    action text not null,
    before_snapshot jsonb,
    after_snapshot jsonb,
    reason text not null default '',
    created_at timestamptz not null default now()
);
alter table audit_events enable row level security;
create policy "Allow all on audit_events" on audit_events for all using (true) with check (true);

-- INDEXING
create index if not exists idx_distributions_customer_date on distributions(customer_id, business_date);
create index if not exists idx_receivables_customer_status on receivables(customer_id, status);
create index if not exists idx_payments_receivable on payments(receivable_id);
create index if not exists idx_stock_movements_product_date on stock_movements(product_id, business_date);
create index if not exists idx_cashflow_direction_date on cashflow_entries(direction, business_date);
