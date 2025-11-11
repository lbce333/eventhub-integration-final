-- Migration: 20250106_004_add_decoration_advance.sql
-- Description: Añadir campo decoration_advance en events
-- Rollback: ALTER TABLE events DROP COLUMN IF EXISTS decoration_advance;

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'events') THEN
    ALTER TABLE events
      ADD COLUMN IF NOT EXISTS decoration_advance numeric DEFAULT 0;

    COMMENT ON COLUMN events.decoration_advance IS 'Avance/anticipo de decoración registrado en creación del evento';

    RAISE NOTICE 'Added decoration_advance column to events';
  ELSE
    RAISE NOTICE 'Table events does not exist, skipping decoration_advance addition';
  END IF;
END $$;

-- ROLLBACK
/*
ALTER TABLE events DROP COLUMN IF EXISTS decoration_advance;
*/
