-- Migration: 20250106_003_add_petty_cash_system.sql
-- Description: Sistema de caja chica con tabla de movimientos y view agregada
-- Rollback: Ver sección final

-- STOP CONDITION: Validar tabla events existe
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'events') THEN
    RAISE EXCEPTION 'Table events must exist before creating petty cash system';
  END IF;
END $$;

-- Crear tabla de movimientos
CREATE TABLE IF NOT EXISTS petty_cash_movements (
  id bigserial PRIMARY KEY,
  event_id bigint NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  movement_type text NOT NULL CHECK (movement_type IN ('budget_assignment', 'expense', 'adjustment', 'refund')),
  amount numeric NOT NULL CHECK (amount >= 0),
  description text,
  category text,
  receipt_url text,
  registered_by uuid,
  registered_by_name text NOT NULL,
  registered_at timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_petty_cash_movements_event
  ON petty_cash_movements(event_id, registered_at DESC);

-- View agregada
CREATE OR REPLACE VIEW petty_cash_status AS
SELECT
  event_id,
  SUM(CASE WHEN movement_type = 'budget_assignment' THEN amount ELSE 0 END) as budget,
  SUM(CASE WHEN movement_type IN ('expense', 'adjustment') THEN amount ELSE 0 END) as spent,
  SUM(CASE WHEN movement_type = 'refund' THEN amount ELSE 0 END) as refunds,
  SUM(CASE WHEN movement_type = 'budget_assignment' THEN amount ELSE 0 END)
    - SUM(CASE WHEN movement_type IN ('expense', 'adjustment') THEN amount ELSE 0 END)
    + SUM(CASE WHEN movement_type = 'refund' THEN amount ELSE 0 END) as remaining,
  COUNT(*) as total_movements,
  MAX(registered_at) as last_movement_at
FROM petty_cash_movements
GROUP BY event_id;

-- RLS
ALTER TABLE petty_cash_movements ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS petty_cash_select ON petty_cash_movements;
CREATE POLICY petty_cash_select ON petty_cash_movements
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid()
      AND role IN (SELECT id FROM roles WHERE id IN ('admin','socio','coordinador'))
  )
);

DROP POLICY IF EXISTS petty_cash_insert ON petty_cash_movements;
CREATE POLICY petty_cash_insert ON petty_cash_movements
FOR INSERT TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid()
      AND role IN (SELECT id FROM roles WHERE id IN ('admin','socio','coordinador'))
  )
);

DROP POLICY IF EXISTS petty_cash_delete ON petty_cash_movements;
CREATE POLICY petty_cash_delete ON petty_cash_movements
FOR DELETE TO authenticated
USING (
  EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);

-- STOP CONDITION: Validación post
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'petty_cash_movements') THEN
    RAISE EXCEPTION 'Table petty_cash_movements was not created';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.views WHERE table_schema = 'public' AND table_name = 'petty_cash_status') THEN
    RAISE EXCEPTION 'View petty_cash_status was not created';
  END IF;

  RAISE NOTICE 'Petty cash system created successfully';
END $$;

-- ROLLBACK
/*
DROP VIEW IF EXISTS petty_cash_status;
DROP TABLE IF EXISTS petty_cash_movements CASCADE;
*/
