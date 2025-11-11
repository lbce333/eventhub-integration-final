-- Migration: 20250106_013_rls_complete_policies.sql
-- Description: Enable RLS and create policies for all tables
-- Rollback: Disable RLS and drop policies (see end)

-- ============================================================================
-- EVENTS
-- ============================================================================
ALTER TABLE events ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS events_select ON events;
CREATE POLICY events_select ON events
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM me
    WHERE role IN (SELECT id FROM roles WHERE id IN ('admin','socio','coordinador'))
  )
  OR (
    EXISTS (SELECT 1 FROM me WHERE role = 'servicio')
    AND id IN (SELECT event_id FROM event_staff WHERE user_id = auth.uid())
  )
);

DROP POLICY IF EXISTS events_insert ON events;
CREATE POLICY events_insert ON events
FOR INSERT TO authenticated
WITH CHECK (
  EXISTS (SELECT 1 FROM me WHERE role IN (SELECT id FROM roles WHERE id IN ('admin','socio')))
);

DROP POLICY IF EXISTS events_update ON events;
CREATE POLICY events_update ON events
FOR UPDATE TO authenticated
USING (
  EXISTS (SELECT 1 FROM me WHERE role IN (SELECT id FROM roles WHERE id IN ('admin','socio')))
);

DROP POLICY IF EXISTS events_delete ON events;
CREATE POLICY events_delete ON events
FOR DELETE TO authenticated
USING (
  EXISTS (SELECT 1 FROM me WHERE role = 'admin')
);

-- ============================================================================
-- CLIENTS
-- ============================================================================
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS clients_select ON clients;
CREATE POLICY clients_select ON clients
FOR SELECT TO authenticated
USING (
  EXISTS (SELECT 1 FROM me WHERE role IN (SELECT id FROM roles WHERE id IN ('admin','socio')))
);

DROP POLICY IF EXISTS clients_insert ON clients;
CREATE POLICY clients_insert ON clients
FOR INSERT TO authenticated
WITH CHECK (
  EXISTS (SELECT 1 FROM me WHERE role IN (SELECT id FROM roles WHERE id IN ('admin','socio')))
);

DROP POLICY IF EXISTS clients_update ON clients;
CREATE POLICY clients_update ON clients
FOR UPDATE TO authenticated
USING (
  EXISTS (SELECT 1 FROM me WHERE role IN (SELECT id FROM roles WHERE id IN ('admin','socio')))
);

-- ============================================================================
-- EVENT_EXPENSES
-- ============================================================================
ALTER TABLE event_expenses ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS expenses_select ON event_expenses;
CREATE POLICY expenses_select ON event_expenses
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM me
    WHERE role IN (SELECT id FROM roles WHERE id IN ('admin','socio','coordinador','encargado_compras'))
  )
  OR (
    EXISTS (SELECT 1 FROM me WHERE role = 'servicio')
    AND event_id IN (SELECT event_id FROM event_staff WHERE user_id = auth.uid())
  )
);

DROP POLICY IF EXISTS expenses_insert ON event_expenses;
CREATE POLICY expenses_insert ON event_expenses
FOR INSERT TO authenticated
WITH CHECK (
  (
    EXISTS (SELECT 1 FROM me WHERE role IN (SELECT id FROM roles WHERE id = 'coordinador'))
    AND category = 'adicional'
  )
  OR EXISTS (
    SELECT 1 FROM me
    WHERE role IN (SELECT id FROM roles WHERE id IN ('admin','socio','encargado_compras'))
  )
);

DROP POLICY IF EXISTS expenses_update ON event_expenses;
CREATE POLICY expenses_update ON event_expenses
FOR UPDATE TO authenticated
USING (
  EXISTS (SELECT 1 FROM me WHERE role IN (SELECT id FROM roles WHERE id IN ('admin','socio')))
);

DROP POLICY IF EXISTS expenses_delete ON event_expenses;
CREATE POLICY expenses_delete ON event_expenses
FOR DELETE TO authenticated
USING (
  EXISTS (SELECT 1 FROM me WHERE role IN (SELECT id FROM roles WHERE id IN ('admin','socio')))
);

-- ============================================================================
-- EVENT_INCOMES
-- ============================================================================
ALTER TABLE event_incomes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS incomes_select ON event_incomes;
CREATE POLICY incomes_select ON event_incomes
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM me
    WHERE role IN (SELECT id FROM roles WHERE id IN ('admin','socio','coordinador'))
  )
);

DROP POLICY IF EXISTS incomes_insert ON event_incomes;
CREATE POLICY incomes_insert ON event_incomes
FOR INSERT TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM me
    WHERE role IN (SELECT id FROM roles WHERE id IN ('admin','socio','coordinador'))
  )
);

DROP POLICY IF EXISTS incomes_update ON event_incomes;
CREATE POLICY incomes_update ON event_incomes
FOR UPDATE TO authenticated
USING (
  EXISTS (SELECT 1 FROM me WHERE role IN (SELECT id FROM roles WHERE id IN ('admin','socio')))
);

-- ============================================================================
-- EVENT_INGREDIENTS
-- ============================================================================
ALTER TABLE event_ingredients ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS ingredients_select ON event_ingredients;
CREATE POLICY ingredients_select ON event_ingredients
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM me
    WHERE role IN (SELECT id FROM roles WHERE id IN ('admin','socio','encargado_compras'))
  )
);

DROP POLICY IF EXISTS ingredients_insert ON event_ingredients;
CREATE POLICY ingredients_insert ON event_ingredients
FOR INSERT TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM me
    WHERE role IN (SELECT id FROM roles WHERE id IN ('admin','socio','encargado_compras'))
  )
);

DROP POLICY IF EXISTS ingredients_update ON event_ingredients;
CREATE POLICY ingredients_update ON event_ingredients
FOR UPDATE TO authenticated
USING (
  EXISTS (SELECT 1 FROM me WHERE role IN (SELECT id FROM roles WHERE id IN ('admin','socio')))
);

DROP POLICY IF EXISTS ingredients_delete ON event_ingredients;
CREATE POLICY ingredients_delete ON event_ingredients
FOR DELETE TO authenticated
USING (
  EXISTS (SELECT 1 FROM me WHERE role IN (SELECT id FROM roles WHERE id IN ('admin','socio')))
);

-- ============================================================================
-- MENU_DISHES
-- ============================================================================
ALTER TABLE menu_dishes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS menu_dishes_select ON menu_dishes;
CREATE POLICY menu_dishes_select ON menu_dishes
FOR SELECT TO authenticated
USING (true);

DROP POLICY IF EXISTS menu_dishes_modify ON menu_dishes;
CREATE POLICY menu_dishes_modify ON menu_dishes
FOR ALL TO authenticated
USING (
  EXISTS (SELECT 1 FROM me WHERE role IN (SELECT id FROM roles WHERE id IN ('admin','socio')))
);

-- ============================================================================
-- DISH_INGREDIENTS
-- ============================================================================
ALTER TABLE dish_ingredients ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS dish_ingredients_select ON dish_ingredients;
CREATE POLICY dish_ingredients_select ON dish_ingredients
FOR SELECT TO authenticated
USING (true);

DROP POLICY IF EXISTS dish_ingredients_modify ON dish_ingredients;
CREATE POLICY dish_ingredients_modify ON dish_ingredients
FOR ALL TO authenticated
USING (
  EXISTS (SELECT 1 FROM me WHERE role IN (SELECT id FROM roles WHERE id IN ('admin','socio')))
);

-- ============================================================================
-- EVENT_DECORATION
-- ============================================================================
ALTER TABLE event_decoration ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS decoration_select ON event_decoration;
CREATE POLICY decoration_select ON event_decoration
FOR SELECT TO authenticated
USING (
  EXISTS (SELECT 1 FROM me WHERE role IN (SELECT id FROM roles WHERE id IN ('admin','socio','coordinador')))
);

DROP POLICY IF EXISTS decoration_insert ON event_decoration;
CREATE POLICY decoration_insert ON event_decoration
FOR INSERT TO authenticated
WITH CHECK (
  EXISTS (SELECT 1 FROM me WHERE role IN (SELECT id FROM roles WHERE id IN ('admin','socio')))
);

DROP POLICY IF EXISTS decoration_update ON event_decoration;
CREATE POLICY decoration_update ON event_decoration
FOR UPDATE TO authenticated
USING (
  EXISTS (SELECT 1 FROM me WHERE role IN (SELECT id FROM roles WHERE id IN ('admin','socio')))
);

DROP POLICY IF EXISTS decoration_delete ON event_decoration;
CREATE POLICY decoration_delete ON event_decoration
FOR DELETE TO authenticated
USING (
  EXISTS (SELECT 1 FROM me WHERE role IN (SELECT id FROM roles WHERE id IN ('admin','socio')))
);

-- ============================================================================
-- EVENT_STAFF
-- ============================================================================
ALTER TABLE event_staff ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS staff_select ON event_staff;
CREATE POLICY staff_select ON event_staff
FOR SELECT TO authenticated
USING (
  EXISTS (SELECT 1 FROM me WHERE role IN (SELECT id FROM roles WHERE id IN ('admin','socio')))
);

DROP POLICY IF EXISTS staff_insert ON event_staff;
CREATE POLICY staff_insert ON event_staff
FOR INSERT TO authenticated
WITH CHECK (
  EXISTS (SELECT 1 FROM me WHERE role IN (SELECT id FROM roles WHERE id IN ('admin','socio')))
);

DROP POLICY IF EXISTS staff_update ON event_staff;
CREATE POLICY staff_update ON event_staff
FOR UPDATE TO authenticated
USING (
  EXISTS (SELECT 1 FROM me WHERE role IN (SELECT id FROM roles WHERE id IN ('admin','socio')))
);

DROP POLICY IF EXISTS staff_delete ON event_staff;
CREATE POLICY staff_delete ON event_staff
FOR DELETE TO authenticated
USING (
  EXISTS (SELECT 1 FROM me WHERE role IN (SELECT id FROM roles WHERE id IN ('admin','socio')))
);

-- ============================================================================
-- AUDIT_LOGS
-- ============================================================================
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS audit_logs_select ON audit_logs;
CREATE POLICY audit_logs_select ON audit_logs
FOR SELECT TO authenticated
USING (
  EXISTS (SELECT 1 FROM me WHERE role IN (SELECT id FROM roles WHERE id IN ('admin','socio')))
);

DROP POLICY IF EXISTS audit_logs_insert ON audit_logs;
CREATE POLICY audit_logs_insert ON audit_logs
FOR INSERT TO authenticated
WITH CHECK (true);

-- ============================================================================
-- USERS
-- ============================================================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS users_select ON users;
CREATE POLICY users_select ON users
FOR SELECT TO authenticated
USING (
  id = auth.uid()
  OR EXISTS (SELECT 1 FROM me WHERE role IN (SELECT id FROM roles WHERE id IN ('admin','socio')))
);

DROP POLICY IF EXISTS users_update ON users;
CREATE POLICY users_update ON users
FOR UPDATE TO authenticated
USING (
  id = auth.uid()
  OR EXISTS (SELECT 1 FROM me WHERE role = 'admin')
);

-- Validación
DO $$
BEGIN
  RAISE NOTICE 'RLS policies created successfully for all tables';
END $$;

-- ROLLBACK
/*
-- Disable RLS on all tables
ALTER TABLE events DISABLE ROW LEVEL SECURITY;
ALTER TABLE clients DISABLE ROW LEVEL SECURITY;
ALTER TABLE event_expenses DISABLE ROW LEVEL SECURITY;
ALTER TABLE event_incomes DISABLE ROW LEVEL SECURITY;
ALTER TABLE event_ingredients DISABLE ROW LEVEL SECURITY;
ALTER TABLE menu_dishes DISABLE ROW LEVEL SECURITY;
ALTER TABLE dish_ingredients DISABLE ROW LEVEL SECURITY;
ALTER TABLE event_decoration DISABLE ROW LEVEL SECURITY;
ALTER TABLE event_staff DISABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs DISABLE ROW LEVEL SECURITY;
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
*/
