-- Migration: 20250106_001_create_roles_table.sql
-- Description: Crear tabla roles con catálogo inicial
-- Rollback: Ver sección final del archivo

-- STOP CONDITION: Validación pre-ejecución
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'users') THEN
    RAISE NOTICE 'Warning: Table users does not exist yet. This migration should run after user management setup.';
  END IF;
END $$;

-- Crear tabla
CREATE TABLE IF NOT EXISTS roles (
  id text PRIMARY KEY,
  name text NOT NULL UNIQUE,
  display_name text NOT NULL,
  description text,
  created_at timestamptz DEFAULT now()
);

-- Seed inicial (idempotente con ON CONFLICT)
INSERT INTO roles (id, name, display_name, description) VALUES
  ('admin', 'admin', 'Administrador', 'Acceso total al sistema'),
  ('socio', 'socio', 'Socio', 'Acceso total (similar a admin)'),
  ('coordinador', 'coordinador', 'Coordinador', 'Gestión de eventos y gastos adicionales'),
  ('encargado_compras', 'encargado_compras', 'Encargado de Compras', 'Registro de ingredientes y gastos'),
  ('servicio', 'servicio', 'Servicio', 'Acceso limitado a eventos asignados')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description;

-- RLS
ALTER TABLE roles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS roles_read ON roles;
CREATE POLICY roles_read ON roles
  FOR SELECT
  TO authenticated
  USING (true);

-- STOP CONDITION: Validación post-ejecución
DO $$
DECLARE
  role_count int;
BEGIN
  SELECT COUNT(*) INTO role_count FROM roles;
  IF role_count < 5 THEN
    RAISE EXCEPTION 'Seed failed: Expected 5 roles, got %', role_count;
  END IF;
  RAISE NOTICE 'Migration completed: % roles inserted', role_count;
END $$;

-- ROLLBACK SCRIPT
/*
ALTER TABLE users DROP CONSTRAINT IF EXISTS fk_users_role;
DROP TABLE IF EXISTS roles CASCADE;
*/
