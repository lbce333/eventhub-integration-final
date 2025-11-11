/*
  # Enable Row Level Security and Create Policies
  
  Implements RLS policies for all tables according to role permissions:
  - Admin: full access to everything
  - Coordinador: assigned events only, limited expense/income creation
  - Encargado Compras: assigned events only, food expenses only
*/

-- =====================================================
-- EVENTS TABLE POLICIES
-- =====================================================
ALTER TABLE events ENABLE ROW LEVEL SECURITY;

-- Admin sees all events
CREATE POLICY "Admins can view all events" ON events
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND users.role_id = 1
    )
  );

-- Coordinador and Encargado only see assigned events
CREATE POLICY "Users see assigned events" ON events
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND (users.role_id IN (2, 3))
      AND events.assigned_to = users.id
    )
  );

-- Only admin can modify events
CREATE POLICY "Only admins can modify events" ON events
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND users.role_id = 1
    )
  );

-- =====================================================
-- EXPENSES TABLE POLICIES
-- =====================================================
ALTER TABLE event_expenses ENABLE ROW LEVEL SECURITY;

-- Admin sees all
CREATE POLICY "Admins can view all expenses" ON event_expenses
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND users.role_id = 1
    )
  );

-- Admin can do everything
CREATE POLICY "Admins can manage all expenses" ON event_expenses
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND users.role_id = 1
    )
  );

-- Encargado compras can manage food expenses on assigned events
CREATE POLICY "Encargado can manage food expenses" ON event_expenses
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM users u
      JOIN events e ON e.assigned_to = u.id
      WHERE u.id = auth.uid()
      AND u.role_id = 3
      AND e.id = event_expenses.event_id
      AND event_expenses.category IN ('pollo', 'verduras', 'salchichas', 'papas')
    )
  );

-- Coordinador can manage additional expenses on assigned events
CREATE POLICY "Coordinador can manage additional expenses" ON event_expenses
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM users u
      JOIN events e ON e.assigned_to = u.id
      WHERE u.id = auth.uid()
      AND u.role_id = 2
      AND e.id = event_expenses.event_id
      AND event_expenses.category = 'otros'
    )
  );

-- =====================================================
-- INCOMES TABLE POLICIES
-- =====================================================
ALTER TABLE event_incomes ENABLE ROW LEVEL SECURITY;

-- Admin can do everything
CREATE POLICY "Admins can manage all incomes" ON event_incomes
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND users.role_id = 1
    )
  );

-- Coordinador can manage limited incomes on assigned events
CREATE POLICY "Coordinador can manage limited incomes" ON event_incomes
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM users u
      JOIN events e ON e.assigned_to = u.id
      WHERE u.id = auth.uid()
      AND u.role_id = 2
      AND e.id = event_incomes.event_id
      AND event_incomes.income_type IN ('kiosco', 'horas_extras')
    )
  );

-- =====================================================
-- WAREHOUSE TABLE POLICIES
-- =====================================================
ALTER TABLE warehouse_movements ENABLE ROW LEVEL SECURITY;

-- Admin sees all
CREATE POLICY "Admins can view all warehouse" ON warehouse_movements
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND users.role_id = 1
    )
  );

-- Admin can manage all
CREATE POLICY "Admins can manage all warehouse" ON warehouse_movements
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND users.role_id = 1
    )
  );

-- Coordinador sees own movements
CREATE POLICY "Coordinador sees own movements" ON warehouse_movements
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND users.role_id = 2
      AND warehouse_movements.registered_by = users.id
    )
  );

-- Coordinador can create movements
CREATE POLICY "Coordinador can create movements" ON warehouse_movements
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND users.role_id = 2
    )
  );

-- =====================================================
-- RELATED TABLES (Allow access based on event access)
-- =====================================================
ALTER TABLE event_contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_food_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_beverages ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_decoration ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_staff ENABLE ROW LEVEL SECURITY;

-- Admin can access all related tables
CREATE POLICY "Admins can manage all contracts" ON event_contracts FOR ALL
  USING (EXISTS (SELECT 1 FROM users WHERE users.id = auth.uid() AND users.role_id = 1));

CREATE POLICY "Admins can manage all food" ON event_food_details FOR ALL
  USING (EXISTS (SELECT 1 FROM users WHERE users.id = auth.uid() AND users.role_id = 1));

CREATE POLICY "Admins can manage all beverages" ON event_beverages FOR ALL
  USING (EXISTS (SELECT 1 FROM users WHERE users.id = auth.uid() AND users.role_id = 1));

CREATE POLICY "Admins can manage all decoration" ON event_decoration FOR ALL
  USING (EXISTS (SELECT 1 FROM users WHERE users.id = auth.uid() AND users.role_id = 1));

CREATE POLICY "Admins can manage all staff" ON event_staff FOR ALL
  USING (EXISTS (SELECT 1 FROM users WHERE users.id = auth.uid() AND users.role_id = 1));

-- Users can view related data for their assigned events
CREATE POLICY "Users see own event contracts" ON event_contracts FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM users u
    JOIN events e ON e.assigned_to = u.id
    WHERE u.id = auth.uid() AND e.id = event_contracts.event_id
  ));

CREATE POLICY "Users see own event food" ON event_food_details FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM users u
    JOIN events e ON e.assigned_to = u.id
    WHERE u.id = auth.uid() AND e.id = event_food_details.event_id
  ));

CREATE POLICY "Users see own event beverages" ON event_beverages FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM users u
    JOIN events e ON e.assigned_to = u.id
    WHERE u.id = auth.uid() AND e.id = event_beverages.event_id
  ));

CREATE POLICY "Users see own event decoration" ON event_decoration FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM users u
    JOIN events e ON e.assigned_to = u.id
    WHERE u.id = auth.uid() AND e.id = event_decoration.event_id
  ));

CREATE POLICY "Users see own event staff" ON event_staff FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM users u
    JOIN events e ON e.assigned_to = u.id
    WHERE u.id = auth.uid() AND e.id = event_staff.event_id
  ));

-- =====================================================
-- CLIENTS AND USERS (Admin only for modifications)
-- =====================================================
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view clients" ON clients FOR SELECT USING (true);
CREATE POLICY "Only admins can modify clients" ON clients FOR ALL
  USING (EXISTS (SELECT 1 FROM users WHERE users.id = auth.uid() AND users.role_id = 1));

CREATE POLICY "Users can view own profile" ON users FOR SELECT
  USING (auth.uid() = id OR EXISTS (SELECT 1 FROM users WHERE users.id = auth.uid() AND users.role_id = 1));

CREATE POLICY "Only admins can modify users" ON users FOR ALL
  USING (EXISTS (SELECT 1 FROM users WHERE users.id = auth.uid() AND users.role_id = 1));

-- =====================================================
-- AUDIT LOG (Everyone can insert, admin can view all)
-- =====================================================
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone authenticated can insert audit" ON audit_log FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Admins can view all audit" ON audit_log FOR SELECT
  USING (EXISTS (SELECT 1 FROM users WHERE users.id = auth.uid() AND users.role_id = 1));

CREATE POLICY "Users can view own audit" ON audit_log FOR SELECT
  USING (user_id = auth.uid());
