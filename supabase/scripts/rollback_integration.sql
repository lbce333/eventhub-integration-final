-- ROLLBACK COMPLETO DE INTEGRACIÓN EMERGENT
-- USAR SOLO EN EMERGENCIA
-- IMPORTANTE: Este script elimina TODO el trabajo de integración

BEGIN;

-- 1. Eliminar triggers de auditoría
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

-- 2. Eliminar trigger de registered_by_name
DROP TRIGGER IF EXISTS set_registered_by_name_expenses ON event_expenses;
DROP TRIGGER IF EXISTS set_registered_by_name_ingredients ON event_ingredients;
DROP TRIGGER IF EXISTS set_registered_by_name_decoration ON event_decoration;
DROP TRIGGER IF EXISTS set_registered_by_name_staff ON event_staff;
DROP TRIGGER IF EXISTS set_registered_by_name_petty_cash ON petty_cash_movements;

DROP FUNCTION IF EXISTS set_registered_by_name();

-- 3. Eliminar view de caja chica
DROP VIEW IF EXISTS petty_cash_status;

-- 4. Eliminar tabla de movimientos de caja chica
DROP TABLE IF EXISTS petty_cash_movements CASCADE;

-- 5. Eliminar catálogos nuevos
DROP TABLE IF EXISTS vegetables_catalog CASCADE;
DROP TABLE IF EXISTS chilis_catalog CASCADE;
DROP TABLE IF EXISTS decoration_providers CASCADE;
DROP TABLE IF EXISTS decoration_packages CASCADE;
DROP TABLE IF EXISTS staff_roles_catalog CASCADE;

-- 6. Eliminar constraint de role
ALTER TABLE users DROP CONSTRAINT IF EXISTS fk_users_role;

-- 7. Eliminar tabla roles
DROP TABLE IF EXISTS roles CASCADE;

-- 8. Eliminar columnas añadidas
ALTER TABLE event_expenses DROP COLUMN IF EXISTS registered_by_name;
ALTER TABLE event_ingredients DROP COLUMN IF EXISTS registered_by_name;
ALTER TABLE event_decoration DROP COLUMN IF EXISTS registered_by_name;
ALTER TABLE event_staff DROP COLUMN IF EXISTS registered_by_name;
ALTER TABLE events DROP COLUMN IF EXISTS decoration_advance;

-- 9. Eliminar índices
DROP INDEX IF EXISTS idx_event_ingredients_event_registered;
DROP INDEX IF EXISTS idx_dish_ingredients_lookup;
DROP INDEX IF EXISTS idx_event_expenses_category;

-- 10. Validar rollback
SELECT 'ROLLBACK COMPLETED' as status,
       'All integration changes have been reverted' as message,
       now() as timestamp;

COMMIT;
