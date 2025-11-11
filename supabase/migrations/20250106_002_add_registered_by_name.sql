-- Migration: 20250106_002_add_registered_by_name.sql
-- Description: Añadir columnas registered_by_name (serán pobladas por trigger)
-- Rollback: Ver sección final

-- event_expenses
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'event_expenses') THEN
    ALTER TABLE event_expenses
      ADD COLUMN IF NOT EXISTS registered_by_name text;
    COMMENT ON COLUMN event_expenses.registered_by_name IS 'Nombre completo del usuario (snapshot automático via trigger)';
    RAISE NOTICE 'Added registered_by_name to event_expenses';
  END IF;
END $$;

-- event_ingredients
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'event_ingredients') THEN
    ALTER TABLE event_ingredients
      ADD COLUMN IF NOT EXISTS registered_by_name text;
    COMMENT ON COLUMN event_ingredients.registered_by_name IS 'Nombre completo del usuario (snapshot automático via trigger)';
    RAISE NOTICE 'Added registered_by_name to event_ingredients';
  END IF;
END $$;

-- event_decoration
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'event_decoration') THEN
    ALTER TABLE event_decoration
      ADD COLUMN IF NOT EXISTS registered_by_name text;
    COMMENT ON COLUMN event_decoration.registered_by_name IS 'Nombre completo del usuario (snapshot automático via trigger)';
    RAISE NOTICE 'Added registered_by_name to event_decoration';
  END IF;
END $$;

-- event_staff
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'event_staff') THEN
    ALTER TABLE event_staff
      ADD COLUMN IF NOT EXISTS registered_by_name text;
    COMMENT ON COLUMN event_staff.registered_by_name IS 'Nombre completo del usuario (snapshot automático via trigger)';
    RAISE NOTICE 'Added registered_by_name to event_staff';
  END IF;
END $$;

-- Validación
DO $$
BEGIN
  RAISE NOTICE 'registered_by_name columns added. Will be populated by trigger in next migration.';
END $$;

-- ROLLBACK
/*
ALTER TABLE event_expenses DROP COLUMN IF EXISTS registered_by_name;
ALTER TABLE event_ingredients DROP COLUMN IF EXISTS registered_by_name;
ALTER TABLE event_decoration DROP COLUMN IF EXISTS registered_by_name;
ALTER TABLE event_staff DROP COLUMN IF EXISTS registered_by_name;
*/
