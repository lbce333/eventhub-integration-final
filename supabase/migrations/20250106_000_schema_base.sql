/*
  # Schema Base Migration

  1. New Tables
    - `users` - System users with roles
    - `clients` - Client information
    - `events` - Event records
    - `event_expenses` - Event expense tracking
    - `event_incomes` - Event income tracking
    - `event_ingredients` - Ingredients used per event
    - `menu_dishes` - Menu catalog
    - `dish_ingredients` - Ingredients per dish recipe
    - `event_decoration` - Decoration items per event
    - `event_staff` - Staff assignments per event
    - `vegetables_catalog` - Vegetables catalog
    - `chilis_catalog` - Chilis catalog
    - `decoration_providers` - Decoration providers catalog
    - `decoration_packages` - Decoration packages catalog
    - `staff_roles_catalog` - Staff roles catalog
    - `audit_logs` - Audit trail

  2. Security
    - Tables created without RLS (will be enabled in later migrations)
    - Constraints and indexes included
*/

-- ============================================================================
-- USERS
-- ============================================================================
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  role text NOT NULL,
  full_name text,
  email text,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- ============================================================================
-- CLIENTS
-- ============================================================================
CREATE TABLE IF NOT EXISTS clients (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  phone text,
  email text,
  company text,
  address text,
  notes text,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_clients_name ON clients(name);

-- ============================================================================
-- EVENTS
-- ============================================================================
CREATE TABLE IF NOT EXISTS events (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name text NOT NULL,
  type text,
  status text DEFAULT 'pending',
  date date,
  location text,
  guest_count int,
  client_id uuid REFERENCES clients(id) ON DELETE SET NULL,
  created_by uuid REFERENCES users(id),
  notes text,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_events_date ON events(date DESC);
CREATE INDEX IF NOT EXISTS idx_events_client ON events(client_id);
CREATE INDEX IF NOT EXISTS idx_events_status ON events(status);

-- ============================================================================
-- EVENT_EXPENSES
-- ============================================================================
CREATE TABLE IF NOT EXISTS event_expenses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id bigint NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  category text NOT NULL,
  subcategory text,
  amount numeric(12,2) NOT NULL CHECK (amount >= 0),
  description text,
  receipt_url text,
  registered_by uuid REFERENCES users(id),
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_event_expenses_event ON event_expenses(event_id);
CREATE INDEX IF NOT EXISTS idx_event_expenses_category ON event_expenses(category);

-- ============================================================================
-- EVENT_INCOMES
-- ============================================================================
CREATE TABLE IF NOT EXISTS event_incomes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id bigint NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  source text NOT NULL,
  amount numeric(12,2) NOT NULL CHECK (amount >= 0),
  description text,
  registered_by uuid REFERENCES users(id),
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_event_incomes_event ON event_incomes(event_id);

-- ============================================================================
-- VEGETABLES_CATALOG
-- ============================================================================
CREATE TABLE IF NOT EXISTS vegetables_catalog (
  id text PRIMARY KEY,
  name text NOT NULL UNIQUE,
  suggested_price_per_kg numeric(10,2) DEFAULT 0,
  unit text DEFAULT 'kg',
  created_at timestamptz DEFAULT now()
);

-- ============================================================================
-- CHILIS_CATALOG
-- ============================================================================
CREATE TABLE IF NOT EXISTS chilis_catalog (
  id text PRIMARY KEY,
  name text NOT NULL UNIQUE,
  suggested_price_per_kg numeric(10,2) DEFAULT 0,
  unit text DEFAULT 'kg',
  is_spicy boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

-- ============================================================================
-- EVENT_INGREDIENTS
-- ============================================================================
CREATE TABLE IF NOT EXISTS event_ingredients (
  id bigserial PRIMARY KEY,
  event_id bigint NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  ingredient_type text NOT NULL CHECK (ingredient_type IN ('vegetable', 'chili', 'other')),
  ingredient_id text,
  ingredient_name text NOT NULL,
  quantity numeric NOT NULL CHECK (quantity > 0),
  unit text NOT NULL,
  cost_per_unit numeric(10,2),
  total_cost numeric(12,2) GENERATED ALWAYS AS (quantity * COALESCE(cost_per_unit, 0)) STORED,
  registered_by uuid REFERENCES users(id),
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_event_ingredients_event ON event_ingredients(event_id);
CREATE INDEX IF NOT EXISTS idx_event_ingredients_type ON event_ingredients(ingredient_type);

-- ============================================================================
-- MENU_DISHES
-- ============================================================================
CREATE TABLE IF NOT EXISTS menu_dishes (
  id text PRIMARY KEY,
  name text NOT NULL,
  category text NOT NULL,
  base_price numeric(10,2) NOT NULL DEFAULT 0,
  portions_per_recipe int DEFAULT 1,
  description text,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_menu_dishes_category ON menu_dishes(category);

-- ============================================================================
-- DISH_INGREDIENTS
-- ============================================================================
CREATE TABLE IF NOT EXISTS dish_ingredients (
  id bigserial PRIMARY KEY,
  dish_id text NOT NULL REFERENCES menu_dishes(id) ON DELETE CASCADE,
  ingredient_name text NOT NULL,
  base_quantity numeric NOT NULL CHECK (base_quantity > 0),
  unit text NOT NULL,
  is_vegetable boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_dish_ingredients_dish ON dish_ingredients(dish_id);

-- ============================================================================
-- DECORATION_PROVIDERS
-- ============================================================================
CREATE TABLE IF NOT EXISTS decoration_providers (
  id text PRIMARY KEY,
  name text NOT NULL UNIQUE,
  phone text,
  email text,
  notes text,
  created_at timestamptz DEFAULT now()
);

-- ============================================================================
-- DECORATION_PACKAGES
-- ============================================================================
CREATE TABLE IF NOT EXISTS decoration_packages (
  id text PRIMARY KEY,
  name text NOT NULL,
  provider_id text NOT NULL REFERENCES decoration_providers(id) ON DELETE CASCADE,
  provider_cost numeric(12,2) NOT NULL DEFAULT 0,
  client_cost numeric(12,2) NOT NULL DEFAULT 0,
  description text,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_decoration_packages_provider ON decoration_packages(provider_id);

-- ============================================================================
-- EVENT_DECORATION
-- ============================================================================
CREATE TABLE IF NOT EXISTS event_decoration (
  id bigserial PRIMARY KEY,
  event_id bigint NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  package_id text REFERENCES decoration_packages(id) ON DELETE SET NULL,
  provider_id text REFERENCES decoration_providers(id) ON DELETE SET NULL,
  item_description text NOT NULL,
  provider_cost numeric(12,2) NOT NULL DEFAULT 0,
  client_cost numeric(12,2) NOT NULL DEFAULT 0,
  advance_paid numeric(12,2) DEFAULT 0,
  advance_paid_at timestamptz,
  registered_by uuid REFERENCES users(id),
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_event_decoration_event ON event_decoration(event_id);

-- ============================================================================
-- STAFF_ROLES_CATALOG
-- ============================================================================
CREATE TABLE IF NOT EXISTS staff_roles_catalog (
  id text PRIMARY KEY,
  name text NOT NULL UNIQUE,
  default_rate numeric(10,2) NOT NULL DEFAULT 0,
  rate_type text NOT NULL CHECK (rate_type IN ('hourly', 'per_plate', 'fixed')),
  has_system_access boolean DEFAULT false,
  description text,
  created_at timestamptz DEFAULT now()
);

-- ============================================================================
-- EVENT_STAFF
-- ============================================================================
CREATE TABLE IF NOT EXISTS event_staff (
  id bigserial PRIMARY KEY,
  event_id bigint NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  user_id uuid REFERENCES users(id) ON DELETE SET NULL,
  staff_role_id text NOT NULL REFERENCES staff_roles_catalog(id),
  staff_name text NOT NULL,
  rate numeric(10,2) NOT NULL,
  rate_type text NOT NULL CHECK (rate_type IN ('hourly', 'per_plate', 'fixed')),
  hours_worked numeric(5,2),
  plates_served int,
  total_payment numeric(12,2),
  registered_by uuid REFERENCES users(id),
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_event_staff_event ON event_staff(event_id);
CREATE INDEX IF NOT EXISTS idx_event_staff_user ON event_staff(user_id);

-- ============================================================================
-- AUDIT_LOGS
-- ============================================================================
CREATE TABLE IF NOT EXISTS audit_logs (
  id bigserial PRIMARY KEY,
  user_id uuid REFERENCES users(id) ON DELETE SET NULL,
  role text,
  action text NOT NULL,
  table_name text,
  record_id text,
  old_values jsonb,
  new_values jsonb,
  ip_address text,
  user_agent text,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_audit_logs_user ON audit_logs(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_logs_table ON audit_logs(table_name, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON audit_logs(action);

-- ============================================================================
-- VALIDATION
-- ============================================================================
DO $$
DECLARE
  table_count int;
  expected_tables text[] := ARRAY[
    'users', 'clients', 'events', 'event_expenses', 'event_incomes',
    'event_ingredients', 'menu_dishes', 'dish_ingredients',
    'vegetables_catalog', 'chilis_catalog',
    'decoration_providers', 'decoration_packages', 'event_decoration',
    'staff_roles_catalog', 'event_staff', 'audit_logs'
  ];
  missing_tables text[];
BEGIN
  SELECT array_agg(t)
  INTO missing_tables
  FROM unnest(expected_tables) AS t
  WHERE NOT EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = t
  );

  IF missing_tables IS NOT NULL THEN
    RAISE EXCEPTION 'Schema base incomplete. Missing tables: %', array_to_string(missing_tables, ', ');
  END IF;

  SELECT COUNT(*)
  INTO table_count
  FROM information_schema.tables
  WHERE table_schema = 'public'
    AND table_name = ANY(expected_tables);

  RAISE NOTICE 'Schema base migration completed successfully: % tables created', table_count;
END $$;
