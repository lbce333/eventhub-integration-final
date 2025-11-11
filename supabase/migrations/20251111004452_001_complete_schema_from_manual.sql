/*
  # Complete Schema Implementation from Technical Manual
  
  Creates the full database structure including:
  - roles (user roles system)
  - users (system users with role FK)
  - clients (event clients)
  - events (main events table)
  - event_contracts (financial contracts)
  - event_food_details (food service details)
  - event_beverages (beverage tracking)
  - event_decoration (decoration items with payment tracking)
  - event_staff (staff assignments)
  - event_expenses (expenses with tracking)
  - event_incomes (incomes with tracking)
  - warehouse_movements (inventory tracking)
  - audit_log (complete audit trail)
*/

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- TABLE 1: roles
-- =====================================================
CREATE TABLE IF NOT EXISTS roles (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) UNIQUE NOT NULL,
  display_name VARCHAR(100) NOT NULL,
  description TEXT,
  permissions JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default roles
INSERT INTO roles (id, name, display_name, permissions) VALUES
  (1, 'admin', 'Administrador', '{
    "events": {"create": true, "read": true, "update": true, "delete": true},
    "expenses": {"create": true, "read": true, "update": true, "delete": true},
    "incomes": {"create": true, "read": true, "update": true, "delete": true},
    "warehouse": {"create": true, "read": true, "update": true, "delete": true},
    "statistics": {"read": true},
    "clients": {"create": true, "read": true, "update": true, "delete": true}
  }'::jsonb),
  (2, 'coordinador', 'Coordinador', '{
    "events": {"read": "assigned_only"},
    "expenses": {"create": "additional_only", "read": "assigned_only"},
    "incomes": {"create": "kiosko_horas_only", "read": "assigned_only"},
    "warehouse": {"read": "own_only", "create": true}
  }'::jsonb),
  (3, 'encargado_compras', 'Encargado de Compras', '{
    "events": {"read": "assigned_only"},
    "expenses": {"create": "food_only", "read": "assigned_only"}
  }'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- TABLE 2: users
-- =====================================================
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  auth_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  role_id INTEGER REFERENCES roles(id) NOT NULL,
  is_active BOOLEAN DEFAULT true,
  phone VARCHAR(20),
  profile_picture_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_login TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role_id);
CREATE INDEX IF NOT EXISTS idx_users_auth ON users(auth_user_id);

-- =====================================================
-- TABLE 3: clients
-- =====================================================
CREATE TABLE IF NOT EXISTS clients (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100),
  email VARCHAR(255),
  phone VARCHAR(20) NOT NULL,
  tipo_cliente VARCHAR(20) CHECK (tipo_cliente IN ('individual', 'corporativo')),
  company VARCHAR(200),
  address TEXT,
  document_type VARCHAR(20),
  document_number VARCHAR(50),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES users(id)
);

CREATE INDEX IF NOT EXISTS idx_clients_email ON clients(email);
CREATE INDEX IF NOT EXISTS idx_clients_phone ON clients(phone);
CREATE INDEX IF NOT EXISTS idx_clients_document ON clients(document_number);

-- =====================================================
-- TABLE 4: events
-- =====================================================
CREATE TABLE IF NOT EXISTS events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  client_id UUID REFERENCES clients(id) ON DELETE RESTRICT,
  assigned_to UUID REFERENCES users(id),
  event_name VARCHAR(200) NOT NULL,
  event_type VARCHAR(50) CHECK (event_type IN (
    'quince_años', 'boda', 'cumpleaños', 'corporativo', 'otro'
  )),
  status VARCHAR(50) DEFAULT 'draft' CHECK (status IN (
    'draft', 'confirmed', 'in_progress', 'completed', 'cancelled'
  )),
  is_reservation BOOLEAN DEFAULT false,
  event_date DATE NOT NULL,
  event_time TIME,
  location TEXT,
  num_guests INTEGER,
  service_type VARCHAR(50) CHECK (service_type IN ('con_comida', 'solo_alquiler')),
  notes TEXT,
  special_requirements TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id)
);

CREATE INDEX IF NOT EXISTS idx_events_client ON events(client_id);
CREATE INDEX IF NOT EXISTS idx_events_assigned ON events(assigned_to);
CREATE INDEX IF NOT EXISTS idx_events_date ON events(event_date);
CREATE INDEX IF NOT EXISTS idx_events_status ON events(status);
CREATE INDEX IF NOT EXISTS idx_events_type ON events(is_reservation);

-- =====================================================
-- TABLE 5: event_contracts
-- =====================================================
CREATE TABLE IF NOT EXISTS event_contracts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event_id UUID REFERENCES events(id) ON DELETE CASCADE UNIQUE,
  precio_total DECIMAL(10, 2) NOT NULL DEFAULT 0,
  pago_adelantado DECIMAL(10, 2) DEFAULT 0,
  saldo_pendiente DECIMAL(10, 2) GENERATED ALWAYS AS (precio_total - pago_adelantado) STORED,
  presupuesto_asignado DECIMAL(10, 2) DEFAULT 0,
  garantia DECIMAL(10, 2) DEFAULT 0,
  contrato_foto_url TEXT,
  caja_chica_history JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_contracts_event ON event_contracts(event_id);

-- =====================================================
-- TABLE 6: event_food_details
-- =====================================================
CREATE TABLE IF NOT EXISTS event_food_details (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event_id UUID REFERENCES events(id) ON DELETE CASCADE UNIQUE,
  tipo_de_plato VARCHAR(100) NOT NULL,
  cantidad_de_platos INTEGER NOT NULL,
  precio_por_plato DECIMAL(10, 2) NOT NULL,
  incluye_cerveza BOOLEAN DEFAULT false,
  numero_cajas_cerveza INTEGER,
  costo_por_caja DECIMAL(10, 2),
  tipo_de_pago VARCHAR(50) CHECK (tipo_de_pago IN ('cover', 'compra_local')),
  selected_dish_id VARCHAR(100),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_food_event ON event_food_details(event_id);

-- =====================================================
-- TABLE 7: event_beverages
-- =====================================================
CREATE TABLE IF NOT EXISTS event_beverages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event_id UUID REFERENCES events(id) ON DELETE CASCADE,
  tipo VARCHAR(50) NOT NULL CHECK (tipo IN (
    'gaseosa', 'agua', 'champan', 'vino', 'cerveza', 'coctel'
  )),
  cantidad INTEGER,
  litros DECIMAL(10, 2),
  precio_unitario DECIMAL(10, 2),
  numero_cajas INTEGER,
  modalidad VARCHAR(50) CHECK (modalidad IN ('cover', 'compra_local')),
  costo_por_caja DECIMAL(10, 2),
  costo_caja_local DECIMAL(10, 2),
  costo_caja_cliente DECIMAL(10, 2),
  costo_coctel_local DECIMAL(10, 2),
  costo_coctel_cliente DECIMAL(10, 2),
  utilidad DECIMAL(10, 2),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES users(id)
);

CREATE INDEX IF NOT EXISTS idx_beverages_event ON event_beverages(event_id);

-- =====================================================
-- TABLE 8: event_decoration
-- =====================================================
CREATE TABLE IF NOT EXISTS event_decoration (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event_id UUID REFERENCES events(id) ON DELETE CASCADE,
  item VARCHAR(200) NOT NULL,
  quantity INTEGER DEFAULT 1,
  unit_price DECIMAL(10, 2) NOT NULL,
  total_price DECIMAL(10, 2) NOT NULL,
  supplier VARCHAR(200),
  provider_cost DECIMAL(10, 2),
  profit DECIMAL(10, 2) GENERATED ALWAYS AS (total_price - COALESCE(provider_cost, 0)) STORED,
  estado VARCHAR(50) DEFAULT 'pendiente' CHECK (estado IN (
    'pendiente', 'comprado', 'instalado'
  )),
  estado_pago VARCHAR(50) DEFAULT 'pendiente' CHECK (estado_pago IN (
    'pendiente', 'adelanto', 'pagado'
  )),
  monto_pagado DECIMAL(10, 2) DEFAULT 0,
  payment_history JSONB DEFAULT '[]'::jsonb,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES users(id),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_decoration_event ON event_decoration(event_id);

-- =====================================================
-- TABLE 9: event_staff
-- =====================================================
CREATE TABLE IF NOT EXISTS event_staff (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event_id UUID REFERENCES events(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  role VARCHAR(100) NOT NULL,
  hours_worked DECIMAL(5, 2) NOT NULL,
  cost_per_hour DECIMAL(10, 2) NOT NULL,
  total_cost DECIMAL(10, 2) GENERATED ALWAYS AS (hours_worked * cost_per_hour) STORED,
  payment_status VARCHAR(50) DEFAULT 'pendiente' CHECK (payment_status IN (
    'pendiente', 'adelanto', 'pagado'
  )),
  amount_paid DECIMAL(10, 2) DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES users(id)
);

CREATE INDEX IF NOT EXISTS idx_staff_event ON event_staff(event_id);

-- =====================================================
-- TABLE 10: event_expenses
-- =====================================================
CREATE TABLE IF NOT EXISTS event_expenses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event_id UUID REFERENCES events(id) ON DELETE CASCADE,
  category VARCHAR(50) NOT NULL CHECK (category IN (
    'kiosco', 'pollo', 'verduras', 'decoracion', 'mobiliario', 
    'personal', 'salchichas', 'papas', 'cerveza', 'vigilancia', 
    'limpieza', 'otros'
  )),
  description TEXT NOT NULL,
  cantidad DECIMAL(10, 2) NOT NULL,
  costo_unitario DECIMAL(10, 2) NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  unit VARCHAR(50),
  is_predetermined BOOLEAN DEFAULT false,
  payment_method VARCHAR(50) CHECK (payment_method IN (
    'efectivo', 'tarjeta', 'transferencia', 'yape'
  )),
  registered_by UUID REFERENCES users(id) NOT NULL,
  registered_by_name VARCHAR(200) NOT NULL,
  registered_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  receipt_url TEXT,
  expense_date DATE DEFAULT CURRENT_DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_expenses_event ON event_expenses(event_id);
CREATE INDEX IF NOT EXISTS idx_expenses_category ON event_expenses(category);
CREATE INDEX IF NOT EXISTS idx_expenses_user ON event_expenses(registered_by);
CREATE INDEX IF NOT EXISTS idx_expenses_date ON event_expenses(expense_date);

-- =====================================================
-- TABLE 11: event_incomes
-- =====================================================
CREATE TABLE IF NOT EXISTS event_incomes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event_id UUID REFERENCES events(id) ON DELETE CASCADE,
  income_type VARCHAR(50) NOT NULL CHECK (income_type IN (
    'pago_comida', 'pago_alquiler', 'kiosco', 'horas_extras', 'adicional'
  )),
  description TEXT,
  amount DECIMAL(10, 2) NOT NULL,
  payment_method VARCHAR(50) CHECK (payment_method IN (
    'efectivo', 'tarjeta', 'transferencia', 'yape'
  )),
  registered_by UUID REFERENCES users(id) NOT NULL,
  registered_by_name VARCHAR(200) NOT NULL,
  registered_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  income_date DATE DEFAULT CURRENT_DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_incomes_event ON event_incomes(event_id);
CREATE INDEX IF NOT EXISTS idx_incomes_type ON event_incomes(income_type);
CREATE INDEX IF NOT EXISTS idx_incomes_user ON event_incomes(registered_by);

-- =====================================================
-- TABLE 12: warehouse_movements
-- =====================================================
CREATE TABLE IF NOT EXISTS warehouse_movements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_name VARCHAR(200) NOT NULL,
  category VARCHAR(50),
  movement_type VARCHAR(50) NOT NULL CHECK (movement_type IN (
    'entrada', 'salida', 'ajuste'
  )),
  quantity DECIMAL(10, 2) NOT NULL,
  unit VARCHAR(50),
  event_id UUID REFERENCES events(id) ON DELETE SET NULL,
  registered_by UUID REFERENCES users(id) NOT NULL,
  registered_by_name VARCHAR(200) NOT NULL,
  registered_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_warehouse_product ON warehouse_movements(product_name);
CREATE INDEX IF NOT EXISTS idx_warehouse_user ON warehouse_movements(registered_by);
CREATE INDEX IF NOT EXISTS idx_warehouse_event ON warehouse_movements(event_id);
CREATE INDEX IF NOT EXISTS idx_warehouse_date ON warehouse_movements(created_at);

-- =====================================================
-- TABLE 13: audit_log
-- =====================================================
CREATE TABLE IF NOT EXISTS audit_log (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event_id UUID REFERENCES events(id) ON DELETE SET NULL,
  user_id UUID REFERENCES users(id) NOT NULL,
  user_name VARCHAR(200) NOT NULL,
  user_role VARCHAR(50) NOT NULL,
  action VARCHAR(50) NOT NULL CHECK (action IN (
    'created', 'updated', 'deleted', 'added', 'removed'
  )),
  section VARCHAR(100) NOT NULL,
  description TEXT NOT NULL,
  metadata JSONB DEFAULT '{}'::jsonb,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_audit_event ON audit_log(event_id);
CREATE INDEX IF NOT EXISTS idx_audit_user ON audit_log(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_timestamp ON audit_log(timestamp);
CREATE INDEX IF NOT EXISTS idx_audit_action ON audit_log(action);

-- =====================================================
-- TRIGGERS: Auto-update updated_at
-- =====================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON events
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_clients_updated_at BEFORE UPDATE ON clients
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_contracts_updated_at BEFORE UPDATE ON event_contracts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_food_updated_at BEFORE UPDATE ON event_food_details
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_decoration_updated_at BEFORE UPDATE ON event_decoration
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
