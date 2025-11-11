-- Migration: 20250106_015_audit_triggers.sql
-- Description: Triggers automáticos de auditoría para expenses, incomes, staff, decoration, petty_cash
-- Rollback: Ver sección final

-- TRIGGER 1: event_expenses
CREATE OR REPLACE FUNCTION audit_event_expenses_trigger()
RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    INSERT INTO audit_logs (user_id, action, table_name, record_id, new_values)
    VALUES (
      NEW.registered_by,
      'INSERT',
      'event_expenses',
      NEW.id::text,
      jsonb_build_object('category', NEW.category, 'amount', NEW.amount, 'event_id', NEW.event_id)
    );
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO audit_logs (user_id, action, table_name, record_id, old_values, new_values)
    VALUES (
      auth.uid(),
      'UPDATE',
      'event_expenses',
      NEW.id::text,
      jsonb_build_object('amount', OLD.amount),
      jsonb_build_object('amount', NEW.amount)
    );
  ELSIF (TG_OP = 'DELETE') THEN
    INSERT INTO audit_logs (user_id, action, table_name, record_id, old_values)
    VALUES (
      auth.uid(),
      'DELETE',
      'event_expenses',
      OLD.id::text,
      jsonb_build_object('category', OLD.category, 'amount', OLD.amount, 'event_id', OLD.event_id)
    );
  END IF;
  RETURN COALESCE(NEW, OLD);
EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING 'Audit log failed for event_expenses: %', SQLERRM;
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS audit_event_expenses_trigger ON event_expenses;
CREATE TRIGGER audit_event_expenses_trigger
AFTER INSERT OR UPDATE OR DELETE ON event_expenses
FOR EACH ROW EXECUTE FUNCTION audit_event_expenses_trigger();

-- TRIGGER 2: event_incomes
CREATE OR REPLACE FUNCTION audit_event_incomes_trigger()
RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    INSERT INTO audit_logs (user_id, action, table_name, record_id, new_values)
    VALUES (
      NEW.registered_by,
      'INSERT',
      'event_incomes',
      NEW.id::text,
      jsonb_build_object('source', NEW.source, 'amount', NEW.amount, 'event_id', NEW.event_id)
    );
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO audit_logs (user_id, action, table_name, record_id, old_values, new_values)
    VALUES (
      auth.uid(),
      'UPDATE',
      'event_incomes',
      NEW.id::text,
      jsonb_build_object('amount', OLD.amount),
      jsonb_build_object('amount', NEW.amount)
    );
  ELSIF (TG_OP = 'DELETE') THEN
    INSERT INTO audit_logs (user_id, action, table_name, record_id, old_values)
    VALUES (
      auth.uid(),
      'DELETE',
      'event_incomes',
      OLD.id::text,
      jsonb_build_object('source', OLD.source, 'amount', OLD.amount, 'event_id', OLD.event_id)
    );
  END IF;
  RETURN COALESCE(NEW, OLD);
EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING 'Audit log failed for event_incomes: %', SQLERRM;
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS audit_event_incomes_trigger ON event_incomes;
CREATE TRIGGER audit_event_incomes_trigger
AFTER INSERT OR UPDATE OR DELETE ON event_incomes
FOR EACH ROW EXECUTE FUNCTION audit_event_incomes_trigger();

-- TRIGGER 3: event_staff
CREATE OR REPLACE FUNCTION audit_event_staff_trigger()
RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    INSERT INTO audit_logs (user_id, action, table_name, record_id, new_values)
    VALUES (
      NEW.registered_by,
      'INSERT',
      'event_staff',
      NEW.id::text,
      jsonb_build_object('staff_name', NEW.staff_name, 'staff_role_id', NEW.staff_role_id, 'event_id', NEW.event_id)
    );
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO audit_logs (user_id, action, table_name, record_id, old_values, new_values)
    VALUES (
      auth.uid(),
      'UPDATE',
      'event_staff',
      NEW.id::text,
      jsonb_build_object('rate', OLD.rate),
      jsonb_build_object('rate', NEW.rate)
    );
  ELSIF (TG_OP = 'DELETE') THEN
    INSERT INTO audit_logs (user_id, action, table_name, record_id, old_values)
    VALUES (
      auth.uid(),
      'DELETE',
      'event_staff',
      OLD.id::text,
      jsonb_build_object('staff_name', OLD.staff_name, 'event_id', OLD.event_id)
    );
  END IF;
  RETURN COALESCE(NEW, OLD);
EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING 'Audit log failed for event_staff: %', SQLERRM;
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS audit_event_staff_trigger ON event_staff;
CREATE TRIGGER audit_event_staff_trigger
AFTER INSERT OR UPDATE OR DELETE ON event_staff
FOR EACH ROW EXECUTE FUNCTION audit_event_staff_trigger();

-- TRIGGER 4: event_decoration
CREATE OR REPLACE FUNCTION audit_event_decoration_trigger()
RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    INSERT INTO audit_logs (user_id, action, table_name, record_id, new_values)
    VALUES (
      NEW.registered_by,
      'INSERT',
      'event_decoration',
      NEW.id::text,
      jsonb_build_object('item_description', NEW.item_description, 'provider_cost', NEW.provider_cost, 'event_id', NEW.event_id)
    );
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO audit_logs (user_id, action, table_name, record_id, old_values, new_values)
    VALUES (
      auth.uid(),
      'UPDATE',
      'event_decoration',
      NEW.id::text,
      jsonb_build_object('provider_cost', OLD.provider_cost),
      jsonb_build_object('provider_cost', NEW.provider_cost)
    );
  ELSIF (TG_OP = 'DELETE') THEN
    INSERT INTO audit_logs (user_id, action, table_name, record_id, old_values)
    VALUES (
      auth.uid(),
      'DELETE',
      'event_decoration',
      OLD.id::text,
      jsonb_build_object('item_description', OLD.item_description, 'event_id', OLD.event_id)
    );
  END IF;
  RETURN COALESCE(NEW, OLD);
EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING 'Audit log failed for event_decoration: %', SQLERRM;
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS audit_event_decoration_trigger ON event_decoration;
CREATE TRIGGER audit_event_decoration_trigger
AFTER INSERT OR UPDATE OR DELETE ON event_decoration
FOR EACH ROW EXECUTE FUNCTION audit_event_decoration_trigger();

-- TRIGGER 5: petty_cash_movements
CREATE OR REPLACE FUNCTION audit_petty_cash_trigger()
RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    INSERT INTO audit_logs (user_id, action, table_name, record_id, new_values)
    VALUES (
      NEW.registered_by,
      'INSERT',
      'petty_cash_movements',
      NEW.id::text,
      jsonb_build_object('movement_type', NEW.movement_type, 'amount', NEW.amount, 'event_id', NEW.event_id)
    );
  ELSIF (TG_OP = 'DELETE') THEN
    INSERT INTO audit_logs (user_id, action, table_name, record_id, old_values)
    VALUES (
      auth.uid(),
      'DELETE',
      'petty_cash_movements',
      OLD.id::text,
      jsonb_build_object('movement_type', OLD.movement_type, 'amount', OLD.amount, 'event_id', OLD.event_id)
    );
  END IF;
  RETURN COALESCE(NEW, OLD);
EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING 'Audit log failed for petty_cash_movements: %', SQLERRM;
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS audit_petty_cash_trigger ON petty_cash_movements;
CREATE TRIGGER audit_petty_cash_trigger
AFTER INSERT OR DELETE ON petty_cash_movements
FOR EACH ROW EXECUTE FUNCTION audit_petty_cash_trigger();

-- Validación
DO $$
DECLARE
  trigger_count int;
BEGIN
  SELECT COUNT(*) INTO trigger_count
  FROM information_schema.triggers
  WHERE trigger_name LIKE 'audit_%_trigger';

  IF trigger_count < 5 THEN
    RAISE WARNING 'Expected 5 audit triggers, found %', trigger_count;
  ELSE
    RAISE NOTICE 'Audit triggers created: % triggers active', trigger_count;
  END IF;
END $$;

-- ROLLBACK
/*
DROP TRIGGER IF EXISTS audit_event_expenses_trigger ON event_expenses;
DROP TRIGGER IF EXISTS audit_event_incomes_trigger ON event_incomes;
DROP TRIGGER IF EXISTS audit_event_staff_trigger ON event_staff;
DROP TRIGGER IF EXISTS audit_event_decoration_trigger ON event_decoration;
DROP TRIGGER IF EXISTS audit_petty_cash_trigger ON petty_cash_movements;

DROP FUNCTION IF EXISTS audit_event_expenses_trigger();
DROP FUNCTION IF EXISTS audit_event_incomes_trigger();
DROP FUNCTION IF EXISTS audit_event_staff_trigger();
DROP FUNCTION IF EXISTS audit_event_decoration_trigger();
DROP FUNCTION IF EXISTS audit_petty_cash_trigger();
*/
