-- Migration: 20250106_016_trigger_registered_by_name.sql
-- Description: Trigger para snapshot automático de registered_by_name
-- Rollback: Ver sección final

-- Función trigger
CREATE OR REPLACE FUNCTION set_registered_by_name()
RETURNS TRIGGER AS $$
BEGIN
  -- Obtener nombre completo del usuario autenticado
  SELECT full_name INTO NEW.registered_by_name
  FROM users
  WHERE id = auth.uid();

  -- Si no se encuentra o está vacío, usar email
  IF NEW.registered_by_name IS NULL OR NEW.registered_by_name = '' THEN
    SELECT email INTO NEW.registered_by_name
    FROM users
    WHERE id = auth.uid();
  END IF;

  -- Fallback final
  IF NEW.registered_by_name IS NULL THEN
    NEW.registered_by_name := 'Sistema';
  END IF;

  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    NEW.registered_by_name := 'Sistema';
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Aplicar trigger a event_expenses
DROP TRIGGER IF EXISTS set_registered_by_name_expenses ON event_expenses;
CREATE TRIGGER set_registered_by_name_expenses
BEFORE INSERT ON event_expenses
FOR EACH ROW EXECUTE FUNCTION set_registered_by_name();

-- Aplicar trigger a event_ingredients
DROP TRIGGER IF EXISTS set_registered_by_name_ingredients ON event_ingredients;
CREATE TRIGGER set_registered_by_name_ingredients
BEFORE INSERT ON event_ingredients
FOR EACH ROW EXECUTE FUNCTION set_registered_by_name();

-- Aplicar trigger a event_decoration
DROP TRIGGER IF EXISTS set_registered_by_name_decoration ON event_decoration;
CREATE TRIGGER set_registered_by_name_decoration
BEFORE INSERT ON event_decoration
FOR EACH ROW EXECUTE FUNCTION set_registered_by_name();

-- Aplicar trigger a event_staff
DROP TRIGGER IF EXISTS set_registered_by_name_staff ON event_staff;
CREATE TRIGGER set_registered_by_name_staff
BEFORE INSERT ON event_staff
FOR EACH ROW EXECUTE FUNCTION set_registered_by_name();

-- Aplicar trigger a petty_cash_movements
DROP TRIGGER IF EXISTS set_registered_by_name_petty_cash ON petty_cash_movements;
CREATE TRIGGER set_registered_by_name_petty_cash
BEFORE INSERT ON petty_cash_movements
FOR EACH ROW EXECUTE FUNCTION set_registered_by_name();

-- Validación
DO $$
DECLARE
  trigger_count int;
BEGIN
  SELECT COUNT(*) INTO trigger_count
  FROM information_schema.triggers
  WHERE trigger_name LIKE 'set_registered_by_name%';

  IF trigger_count < 5 THEN
    RAISE WARNING 'Expected 5 triggers, found %', trigger_count;
  ELSE
    RAISE NOTICE 'registered_by_name triggers created: % triggers active', trigger_count;
  END IF;
END $$;

-- ROLLBACK
/*
DROP TRIGGER IF EXISTS set_registered_by_name_expenses ON event_expenses;
DROP TRIGGER IF EXISTS set_registered_by_name_ingredients ON event_ingredients;
DROP TRIGGER IF EXISTS set_registered_by_name_decoration ON event_decoration;
DROP TRIGGER IF EXISTS set_registered_by_name_staff ON event_staff;
DROP TRIGGER IF EXISTS set_registered_by_name_petty_cash ON petty_cash_movements;
DROP FUNCTION IF EXISTS set_registered_by_name();
*/
