-- Talon™ POS — Supabase schema
-- Run this in your Supabase SQL Editor to create the tables.

-- Stores
create table if not exists stores (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  address text not null,
  created_at timestamptz default now()
);

alter table stores enable row level security;
create policy "Users can read their stores" on stores
  for select using (true);

-- Products
create table if not exists products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  sku text not null,
  price double precision not null,
  currency_code text not null default 'USD',
  category text not null,
  store_id uuid not null references stores(id),
  created_at timestamptz default now()
);

create index idx_products_store_id on products(store_id);
alter table products enable row level security;
create policy "Users can read products for their store" on products
  for select using (true);

-- Transactions
create table if not exists transactions (
  id uuid primary key,
  store_id uuid not null references stores(id),
  cashier_id uuid not null,
  cashier_name text not null,
  subtotal double precision not null,
  tax_rate double precision not null,
  tax_amount double precision not null,
  total double precision not null,
  amount_tendered double precision not null,
  change double precision not null,
  currency_code text not null default 'USD',
  created_at timestamptz not null
);

create index idx_transactions_store_id on transactions(store_id);
create index idx_transactions_created_at on transactions(created_at);
alter table transactions enable row level security;
create policy "Users can insert transactions" on transactions
  for insert with check (true);
create policy "Users can read transactions for their store" on transactions
  for select using (true);

-- Transaction items
create table if not exists transaction_items (
  id bigint generated always as identity primary key,
  transaction_id uuid not null references transactions(id),
  product_id text not null,
  product_name text not null,
  sku text not null,
  unit_price double precision not null,
  quantity integer not null,
  line_total double precision not null
);

create index idx_transaction_items_txn on transaction_items(transaction_id);
alter table transaction_items enable row level security;
create policy "Users can insert transaction items" on transaction_items
  for insert with check (true);
create policy "Users can read transaction items" on transaction_items
  for select using (true);
