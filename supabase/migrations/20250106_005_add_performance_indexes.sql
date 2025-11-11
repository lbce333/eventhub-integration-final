-- Migration: 20250106_005_add_performance_indexes.sql
-- Description: Crear índices para queries frecuentes
-- Rollback: Ver sección final

-- Ingredientes por evento (ordenados por fecha)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'event_ingredients') THEN
    CREATE INDEX IF NOT EXISTS idx_event_ingredients_event_registered
      ON event_ingredients(event_id, registered_at DESC);
    RAISE NOTICE 'Created index idx_event_ingredients_event_registered';
  END IF;
END $$;

-- Ingredientes de plato
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'dish_ingredients') THEN
    CREATE INDEX IF NOT EXISTS idx_dish_ingredients_lookup
      ON dish_ingredients(dish_id, ingredient_name);
    RAISE NOTICE 'Created index idx_dish_ingredients_lookup';
  END IF;
END $$;

-- Gastos por categoría
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'event_expenses') THEN
    CREATE INDEX IF NOT EXISTS idx_event_expenses_category
      ON event_expenses(event_id, category);
    RAISE NOTICE 'Created index idx_event_expenses_category';
  END IF;
END $$;

-- Validación
DO $$
BEGIN
  RAISE NOTICE 'Performance indexes creation completed';
END $$;

-- ROLLBACK
/*
DROP INDEX IF EXISTS idx_event_ingredients_event_registered;
DROP INDEX IF EXISTS idx_dish_ingredients_lookup;
DROP INDEX IF EXISTS idx_event_expenses_category;
*/
