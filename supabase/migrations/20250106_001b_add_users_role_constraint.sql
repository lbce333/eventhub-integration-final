-- Migration: 20250106_001b_add_users_role_constraint.sql
-- Description: Añadir FK constraint de users.role a roles.id
-- Rollback: ALTER TABLE users DROP CONSTRAINT IF EXISTS fk_users_role;

-- STOP CONDITION: Validar que no hay roles inválidos en users
DO $$
DECLARE
  invalid_roles_count int;
  invalid_roles_list text;
BEGIN
  -- Verificar tabla users existe
  IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'users') THEN
    RAISE NOTICE 'Table users does not exist yet. Skipping constraint creation.';
    RETURN;
  END IF;

  -- Verificar roles inválidos
  SELECT COUNT(*), string_agg(DISTINCT role, ', ')
  INTO invalid_roles_count, invalid_roles_list
  FROM users u
  WHERE u.role IS NOT NULL
    AND u.role NOT IN (SELECT id FROM roles);

  IF invalid_roles_count > 0 THEN
    RAISE EXCEPTION 'Cannot add constraint: % users have invalid roles: %', invalid_roles_count, invalid_roles_list;
  END IF;

  RAISE NOTICE 'Validation passed: All user roles are valid';
END $$;

-- Añadir constraint
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'users') THEN
    ALTER TABLE users
      DROP CONSTRAINT IF EXISTS fk_users_role;

    ALTER TABLE users
      ADD CONSTRAINT fk_users_role
      FOREIGN KEY (role) REFERENCES roles(id)
      ON DELETE RESTRICT
      ON UPDATE CASCADE;

    RAISE NOTICE 'Constraint fk_users_role created successfully';
  END IF;
END $$;

-- Validación post
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'users') THEN
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.table_constraints
      WHERE constraint_name = 'fk_users_role' AND table_name = 'users'
    ) THEN
      RAISE EXCEPTION 'Constraint fk_users_role was not created';
    END IF;
    RAISE NOTICE 'Post-validation passed: Constraint exists';
  END IF;
END $$;
