-- Migration: 20250106_012_update_me_view.sql
-- Description: Actualizar view 'me' para validar contra tabla roles
-- Rollback: DROP VIEW IF EXISTS public.me;

DROP VIEW IF EXISTS public.me;

CREATE OR REPLACE VIEW public.me AS
  SELECT
    u.id as user_id,
    u.role,
    r.name as role_name,
    r.display_name as role_display_name
  FROM public.users u
  JOIN public.roles r ON r.id = u.role
  WHERE u.id = auth.uid();

-- Validación
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.views WHERE table_schema = 'public' AND table_name = 'me') THEN
    RAISE EXCEPTION 'View me was not created';
  END IF;
  RAISE NOTICE 'Helper view "me" updated with roles validation';
END $$;
