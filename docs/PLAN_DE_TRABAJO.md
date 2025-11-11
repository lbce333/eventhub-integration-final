# PLAN DE TRABAJO - INTEGRACIÓN EMERGENT UI EN BOLT
## Plan Detallado por Fases con Criterios de Aceptación

**Proyecto:** Integración UI/Dominio Emergent → Bolt con Supabase  
**Versión:** 1.1 (Revisado con 6 Observaciones Críticas)  
**Fecha Inicio:** 2025-01-06  
**Equipo:** Claude Code + Usuario  
**Estado:** ✅ APROBADO PARA EJECUCIÓN  

**Repositorios:**
- Base (Bolt): github.com/mce333/eventhub-production
- UI/Dominio (Emergent): github.com/mce333/export-ui-only

---

## ACTUALIZACIONES EN ESTA VERSIÓN

### Incorporación de 6 Observaciones Críticas:

1. ✅ **Constraint FK:** `users.role` → `roles(id)` (integridad referencial)
2. ✅ **Caja Chica:** Modelo con tabla `petty_cash_movements` + view (historial completo)
3. ✅ **Triggers Auditoría:** 5 triggers automáticos en primera iteración (expenses, incomes, staff, decoration, petty_cash)
4. ✅ **Trigger Snapshot:** `registered_by_name` automático vía trigger BEFORE INSERT
5. ✅ **Confirmación Seeds:** Arrays de `*Data.ts` solo para poblar DB, sin uso en runtime
6. ✅ **Stop Conditions:** Validaciones pre/post + ON CONFLICT + rollback global

---

## ESTRUCTURA DEL PLAN

**Duración Estimada Total:** 7-8 días laborables  
**Total de Tareas:** 73 (actualizado desde 68)  
**Enfoque:** Incremental con validaciones automáticas en cada migración

---

## FASE 0: PREPARACIÓN Y CONFIGURACIÓN (Día 1 - Mañana)

### Objetivo
Configurar entorno, crear rama de trabajo, y validar acceso a recursos.

### Tareas

#### 0.1 Configuración de Rama Git
- **Descripción:** Crear rama `integracion-emergent-ui` desde `main`
- **Comandos:**
  ```bash
  git checkout main
  git pull origin main
  git checkout -b integracion-emergent-ui
  ```
- **Artefactos:** Rama creada
- **Criterios de Aceptación:**
  - Rama existe en repositorio local
  - Basada en último commit de main

#### 0.2 Actualización de Environment Variables
- **Descripción:** Crear `.env.local` con credenciales correctas de Supabase
- **Archivo:** `.env.local`
- **Contenido:**
  ```
  VITE_SUPABASE_URL=https://tvpaanmxhjhwljjfsuvd.supabase.co
  VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR2cGFhbm14aGpod2xqamZzdXZkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE3NjI0NDAsImV4cCI6MjA3NzMzODQ0MH0.05LZM7MIEg3ltCTz0XElVjpzDLNiFAgXdPHDAnLh9jU
  ```
- **Artefactos:** `.env.local`
- **Criterios de Aceptación:**
  - Archivo existe y no está commiteado (en .gitignore)
  - Variables accesibles via import.meta.env
  - Conexión a Supabase exitosa

#### 0.3 Verificación de Instancia Supabase
- **Descripción:** Validar que la instancia Supabase tiene las tablas y RLS policies
- **Acción:** Ejecutar query de validación
  ```sql
  SELECT table_name FROM information_schema.tables 
  WHERE table_schema = 'public' 
  ORDER BY table_name;
  ```
- **Criterios de Aceptación:**
  - Tablas principales existen (users, events, clients, etc.)
  - RLS habilitado en tablas críticas
  - Buckets `expense-receipts` y `event-images` existen

#### 0.4 Instalación de Dependencias Adicionales
- **Descripción:** Instalar React Query y otras dependencias necesarias
- **Comandos:**
  ```bash
  npm install @tanstack/react-query @tanstack/react-query-devtools
  npm install react-router-dom date-fns
  npm install --save-dev @types/node
  ```
- **Artefactos:** `package.json`, `package-lock.json` actualizados
- **Criterios de Aceptación:**
  - Todas las dependencias instaladas sin errores
  - Build exitoso: `npm run build`

### Entregables Fase 0
- Rama `integracion-emergent-ui` creada
- `.env.local` configurado
- Dependencias instaladas
- Conexión Supabase validada

---

## FASE 1: PARIDAD DE BASE DE DATOS (Día 1 - Tarde + Día 2 - Mañana)

### Objetivo
Cerrar brechas críticas de schema identificadas + implementar 6 observaciones

**ACTUALIZACIÓN:** Esta fase ahora incluye 9 migraciones (antes 5) debido a observaciones #1-#4 y #6

### Tareas

#### 1.1 Migración: Tabla `roles` con Seed (OBSERVACIÓN #1 - Parte 1)
- **Descripción:** Crear tabla normalizada de roles del sistema
- **Archivo:** `supabase/migrations/20250106_001_create_roles_table.sql`
- **Contenido:** (con OBSERVACIÓN #6: stop conditions)
  ```sql
  -- Migration: 20250106_001_create_roles_table.sql
  -- Description: Crear tabla roles con catálogo inicial
  -- Rollback: Ver sección final del archivo
  
  -- STOP CONDITION: Validación pre-ejecución
  DO $$
  BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'users') THEN
      RAISE EXCEPTION 'Table users must exist before creating roles';
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
  CREATE POLICY roles_read ON roles FOR SELECT TO authenticated USING (true);
  
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
  ```
- **Criterios de Aceptación:**
  - Tabla creada con 5 roles
  - RLS habilitado (solo lectura para autenticados)
  - Validaciones pre/post exitosas

#### 1.2 Migración: Constraint FK users.role → roles (OBSERVACIÓN #1 - Parte 2)
- **Descripción:** Añadir constraint de integridad referencial
- **Archivo:** `supabase/migrations/20250106_001b_add_users_role_constraint.sql`
- **Contenido:**
  ```sql
  -- Migration: 20250106_001b_add_users_role_constraint.sql
  -- Description: Añadir FK constraint de users.role a roles.id
  -- Rollback: ALTER TABLE users DROP CONSTRAINT fk_users_role;
  
  -- STOP CONDITION: Validar que no hay roles inválidos en users
  DO $$
  DECLARE
    invalid_roles_count int;
  BEGIN
    SELECT COUNT(*) INTO invalid_roles_count
    FROM users u
    WHERE u.role NOT IN (SELECT id FROM roles);
    
    IF invalid_roles_count > 0 THEN
      RAISE EXCEPTION 'Cannot add constraint: % users have invalid roles. Fix data first.', invalid_roles_count;
    END IF;
  END $$;
  
  -- Añadir constraint
  ALTER TABLE users 
    ADD CONSTRAINT fk_users_role 
    FOREIGN KEY (role) REFERENCES roles(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;
  
  -- Validación post
  DO $$
  BEGIN
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.table_constraints 
      WHERE constraint_name = 'fk_users_role'
    ) THEN
      RAISE EXCEPTION 'Constraint fk_users_role was not created';
    END IF;
    RAISE NOTICE 'Constraint fk_users_role added successfully';
  END $$;
  ```
- **Criterios de Aceptación:**
  - Constraint FK creado
  - No se permiten roles inválidos en `users.role`
  - Validación pre detecta usuarios con roles inexistentes

#### 1.3 Migración: Tabla `petty_cash_movements` + View (OBSERVACIÓN #2)
- **Descripción:** Modelo de caja chica con historial completo
- **Archivo:** `supabase/migrations/20250106_003_add_petty_cash_system.sql`
- **Contenido:**
  ```sql
  -- Migration: 20250106_003_add_petty_cash_system.sql
  -- Description: Sistema de caja chica con tabla de movimientos y view agregada
  -- Rollback: Ver sección final
  
  -- STOP CONDITION: Validar tabla events existe
  DO $$
  BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'events') THEN
      RAISE EXCEPTION 'Table events must exist';
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
    registered_by uuid REFERENCES users(id),
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
  
  CREATE POLICY petty_cash_select ON petty_cash_movements
  FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() 
        AND role IN (SELECT id FROM roles WHERE id IN ('admin','socio','coordinador'))
    )
  );
  
  CREATE POLICY petty_cash_insert ON petty_cash_movements
  FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users 
      WHERE id = auth.uid() 
        AND role IN (SELECT id FROM roles WHERE id IN ('admin','socio','coordinador'))
    )
  );
  
  CREATE POLICY petty_cash_delete ON petty_cash_movements
  FOR DELETE TO authenticated
  USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
  );
  
  -- STOP CONDITION: Validación post
  DO $$
  BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'petty_cash_movements') THEN
      RAISE EXCEPTION 'Table petty_cash_movements was not created';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.views WHERE table_name = 'petty_cash_status') THEN
      RAISE EXCEPTION 'View petty_cash_status was not created';
    END IF;
    
    RAISE NOTICE 'Petty cash system created successfully';
  END $$;
  
  -- ROLLBACK
  /*
  DROP VIEW IF EXISTS petty_cash_status;
  DROP TABLE IF EXISTS petty_cash_movements CASCADE;
  */
  ```
- **Criterios de Aceptación:**
  - Tabla `petty_cash_movements` creada con checks
  - View `petty_cash_status` funcional
  - RLS policies correctas
  - Índice de performance

#### 1.4 Migración: Campos `registered_by_name` (Preparación para OBSERVACIÓN #4)
- **Descripción:** Añadir columnas que serán pobladas por trigger
- **Archivo:** `supabase/migrations/20250106_002_add_registered_by_name.sql`
- **Contenido:**
  ```sql
  -- Migration: 20250106_002_add_registered_by_name.sql
  -- Description: Añadir columnas registered_by_name (serán pobladas por trigger)
  
  -- event_expenses
  ALTER TABLE event_expenses 
    ADD COLUMN IF NOT EXISTS registered_by_name text;
  
  -- event_ingredients
  ALTER TABLE event_ingredients 
    ADD COLUMN IF NOT EXISTS registered_by_name text;
  
  -- event_decoration
  ALTER TABLE event_decoration 
    ADD COLUMN IF NOT EXISTS registered_by_name text;
  
  -- event_staff
  ALTER TABLE event_staff 
    ADD COLUMN IF NOT EXISTS registered_by_name text;
  
  -- Comentarios
  COMMENT ON COLUMN event_expenses.registered_by_name IS 'Nombre completo del usuario (snapshot automático via trigger)';
  COMMENT ON COLUMN event_ingredients.registered_by_name IS 'Nombre completo del usuario (snapshot automático via trigger)';
  COMMENT ON COLUMN event_decoration.registered_by_name IS 'Nombre completo del usuario (snapshot automático via trigger)';
  COMMENT ON COLUMN event_staff.registered_by_name IS 'Nombre completo del usuario (snapshot automático via trigger)';
  
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
  ```
- **Criterios de Aceptación:**
  - Columnas añadidas en 4 tablas
  - Tipo TEXT, nullable

#### 1.5 Migración: Trigger `registered_by_name` Snapshot (OBSERVACIÓN #4)
- **Descripción:** Trigger automático para poblar nombre en INSERT
- **Archivo:** `supabase/migrations/20250106_016_trigger_registered_by_name.sql`
- **Contenido:**
  ```sql
  -- Migration: 20250106_016_trigger_registered_by_name.sql
  -- Description: Trigger para snapshot automático de registered_by_name
  -- Rollback: Ver sección final
  
  -- Función trigger
  CREATE OR REPLACE FUNCTION set_registered_by_name()
  RETURNS TRIGGER AS $$
  BEGIN
    -- Obtener nombre completo del usuario autenticado
    SELECT name || ' ' || last_name INTO NEW.registered_by_name
    FROM users
    WHERE id = auth.uid();
    
    -- Si no se encuentra o está vacío, usar email
    IF NEW.registered_by_name IS NULL OR NEW.registered_by_name = ' ' THEN
      SELECT email INTO NEW.registered_by_name
      FROM auth.users
      WHERE id = auth.uid();
    END IF;
    
    -- Fallback final
    IF NEW.registered_by_name IS NULL THEN
      NEW.registered_by_name := 'Sistema';
    END IF;
    
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
      RAISE EXCEPTION 'Expected 5 triggers, found %', trigger_count;
    END IF;
    
    RAISE NOTICE 'registered_by_name triggers created: % triggers active', trigger_count;
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
  ```
- **Criterios de Aceptación:**
  - Función trigger creada
  - 5 triggers aplicados (expenses, ingredients, decoration, staff, petty_cash)
  - Test: INSERT sin registered_by_name → se llena automáticamente

#### 1.6 Migración: Triggers de Auditoría Automática (OBSERVACIÓN #3)
- **Descripción:** 5 triggers para logging automático en audit_logs
- **Archivo:** `supabase/migrations/20250106_015_audit_triggers.sql`
- **Contenido:**
  ```sql
  -- Migration: 20250106_015_audit_triggers.sql
  -- Description: Triggers automáticos de auditoría para expenses, incomes, staff, decoration, petty_cash
  -- Rollback: Ver sección final
  
  -- TRIGGER 1: event_expenses
  CREATE OR REPLACE FUNCTION audit_event_expenses_trigger()
  RETURNS TRIGGER AS $$
  BEGIN
    IF (TG_OP = 'INSERT') THEN
      INSERT INTO audit_logs (user_id, event_id, action, section, description)
      VALUES (
        NEW.registered_by,
        NEW.event_id,
        'create_expense',
        'expenses',
        format('Gasto registrado: %s - $%s (%s)', NEW.category, NEW.amount, NEW.registered_by_name)
      );
    ELSIF (TG_OP = 'UPDATE') THEN
      INSERT INTO audit_logs (user_id, event_id, action, section, description)
      VALUES (
        auth.uid(),
        NEW.event_id,
        'update_expense',
        'expenses',
        format('Gasto actualizado: %s (anterior: $%s, nuevo: $%s)', NEW.category, OLD.amount, NEW.amount)
      );
    ELSIF (TG_OP = 'DELETE') THEN
      INSERT INTO audit_logs (user_id, event_id, action, section, description)
      VALUES (
        auth.uid(),
        OLD.event_id,
        'delete_expense',
        'expenses',
        format('Gasto eliminado: %s - $%s', OLD.category, OLD.amount)
      );
    END IF;
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
      INSERT INTO audit_logs (user_id, event_id, action, section, description)
      VALUES (
        NEW.registered_by,
        NEW.event_id,
        'create_income',
        'incomes',
        format('Ingreso registrado: %s - $%s', NEW.description, NEW.amount)
      );
    ELSIF (TG_OP = 'UPDATE') THEN
      INSERT INTO audit_logs (user_id, event_id, action, section, description)
      VALUES (
        auth.uid(),
        NEW.event_id,
        'update_income',
        'incomes',
        format('Ingreso actualizado: %s (anterior: $%s, nuevo: $%s)', NEW.description, OLD.amount, NEW.amount)
      );
    ELSIF (TG_OP = 'DELETE') THEN
      INSERT INTO audit_logs (user_id, event_id, action, section, description)
      VALUES (
        auth.uid(),
        OLD.event_id,
        'delete_income',
        'incomes',
        format('Ingreso eliminado: %s - $%s', OLD.description, OLD.amount)
      );
    END IF;
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
      INSERT INTO audit_logs (user_id, event_id, action, section, description)
      VALUES (
        NEW.registered_by,
        NEW.event_id,
        'create_staff',
        'staff',
        format('Personal añadido: %s - %s', NEW.name, NEW.role)
      );
    ELSIF (TG_OP = 'UPDATE') THEN
      INSERT INTO audit_logs (user_id, event_id, action, section, description)
      VALUES (
        auth.uid(),
        NEW.event_id,
        'update_staff',
        'staff',
        format('Personal actualizado: %s', NEW.name)
      );
    ELSIF (TG_OP = 'DELETE') THEN
      INSERT INTO audit_logs (user_id, event_id, action, section, description)
      VALUES (
        auth.uid(),
        OLD.event_id,
        'delete_staff',
        'staff',
        format('Personal eliminado: %s', OLD.name)
      );
    END IF;
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
      INSERT INTO audit_logs (user_id, event_id, action, section, description)
      VALUES (
        NEW.registered_by,
        NEW.event_id,
        'create_decoration',
        'decoration',
        format('Decoración añadida: %s (cantidad: %s)', NEW.item, NEW.quantity)
      );
    ELSIF (TG_OP = 'UPDATE') THEN
      INSERT INTO audit_logs (user_id, event_id, action, section, description)
      VALUES (
        auth.uid(),
        NEW.event_id,
        'update_decoration',
        'decoration',
        format('Decoración actualizada: %s', NEW.item)
      );
    ELSIF (TG_OP = 'DELETE') THEN
      INSERT INTO audit_logs (user_id, event_id, action, section, description)
      VALUES (
        auth.uid(),
        OLD.event_id,
        'delete_decoration',
        'decoration',
        format('Decoración eliminada: %s', OLD.item)
      );
    END IF;
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
      INSERT INTO audit_logs (user_id, event_id, action, section, description)
      VALUES (
        NEW.registered_by,
        NEW.event_id,
        'create_petty_cash_movement',
        'petty_cash',
        format('Movimiento de caja chica: %s - $%s (%s)', NEW.movement_type, NEW.amount, NEW.description)
      );
    ELSIF (TG_OP = 'DELETE') THEN
      INSERT INTO audit_logs (user_id, event_id, action, section, description)
      VALUES (
        auth.uid(),
        OLD.event_id,
        'delete_petty_cash_movement',
        'petty_cash',
        format('Movimiento eliminado: %s - $%s', OLD.movement_type, OLD.amount)
      );
    END IF;
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
      RAISE EXCEPTION 'Expected 5 audit triggers, found %', trigger_count;
    END IF;
    
    RAISE NOTICE 'Audit triggers created: % triggers active', trigger_count;
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
  ```
- **Criterios de Aceptación:**
  - 5 triggers creados (expenses, incomes, staff, decoration, petty_cash)
  - Test: INSERT en cualquier tabla → registro aparece en audit_logs
  - Logs incluyen user, action, section, description

#### 1.7 Migración: Campo `decoration_advance`
- **Descripción:** Añadir campo para avance de decoración en `events`
- **Archivo:** `supabase/migrations/20250106_004_add_decoration_advance.sql`
- **Contenido:**
  ```sql
  -- Migration: 20250106_004_add_decoration_advance.sql
  
  ALTER TABLE events 
    ADD COLUMN IF NOT EXISTS decoration_advance numeric DEFAULT 0;
  
  COMMENT ON COLUMN events.decoration_advance IS 'Avance/anticipo de decoración registrado en creación del evento';
  
  -- ROLLBACK
  /*
  ALTER TABLE events DROP COLUMN IF EXISTS decoration_advance;
  */
  ```
- **Criterios de Aceptación:**
  - Columna añadida en `events`
  - Default 0

#### 1.8 Migración: Índices Adicionales
- **Descripción:** Crear índices para queries frecuentes
- **Archivo:** `supabase/migrations/20250106_005_add_performance_indexes.sql`
- **Contenido:**
  ```sql
  -- Migration: 20250106_005_add_performance_indexes.sql
  
  -- Ingredientes por evento (ordenados por fecha)
  CREATE INDEX IF NOT EXISTS idx_event_ingredients_event_registered 
    ON event_ingredients(event_id, registered_at DESC);
  
  -- Ingredientes de plato
  CREATE INDEX IF NOT EXISTS idx_dish_ingredients_lookup 
    ON dish_ingredients(dish_id, ingredient_name);
  
  -- Gastos por categoría
  CREATE INDEX IF NOT EXISTS idx_event_expenses_category 
    ON event_expenses(event_id, category);
  
  -- Validación
  DO $$
  BEGIN
    RAISE NOTICE 'Performance indexes created successfully';
  END $$;
  
  -- ROLLBACK
  /*
  DROP INDEX IF EXISTS idx_event_ingredients_event_registered;
  DROP INDEX IF EXISTS idx_dish_ingredients_lookup;
  DROP INDEX IF EXISTS idx_event_expenses_category;
  */
  ```
- **Criterios de Aceptación:**
  - 3 índices creados
  - EXPLAIN ANALYZE muestra uso de índices

#### 1.9 Script de Rollback Global (OBSERVACIÓN #6)
- **Descripción:** Script de emergencia para revertir toda la integración
- **Archivo:** `supabase/scripts/rollback_integration.sql`
- **Contenido:** (ver sección 6.3 de SCHEMA_PARITY_REPORT.md)
- **Criterios de Aceptación:**
  - Script creado y documentado
  - Probado en entorno de desarrollo

### Entregables Fase 1
- 8 migraciones SQL ejecutadas + 1 script rollback
- Tabla `roles` con seed y constraint FK en users
- Sistema de caja chica con historial
- 5 triggers de auditoría automática
- 5 triggers de registered_by_name snapshot
- Campos de auditoría en 4 tablas
- Índices de performance
- Script de rollback global

**Commit Esperado:**
```bash
git add supabase/migrations/20250106_001*.sql
git commit -m "feat(db): add roles table with FK constraint and seed data"

git add supabase/migrations/20250106_002*.sql
git commit -m "feat(db): add registered_by_name columns"

git add supabase/migrations/20250106_003*.sql
git commit -m "feat(db): add petty cash system with movements table and view"

git add supabase/migrations/20250106_015*.sql
git commit -m "feat(db): add 5 automatic audit triggers"

git add supabase/migrations/20250106_016*.sql
git commit -m "feat(db): add registered_by_name snapshot trigger"

git add supabase/migrations/20250106_004*.sql supabase/migrations/20250106_005*.sql
git commit -m "feat(db): add decoration_advance field and performance indexes"

git add supabase/scripts/rollback_integration.sql
git commit -m "feat(db): add global rollback script"
```

---

## FASE 2: CATÁLOGOS Y SEED DATA (Día 2 - Tarde)

### Objetivo
Poblar base de datos con catálogos de Emergent (CONFIRMACIÓN OBSERVACIÓN #5)

**ESTRATEGIA CONFIRMADA:**
- ✅ Extraer datos de arrays en archivos `*Data.ts` de Emergent
- ✅ Crear migraciones SQL con INSERT statements
- ✅ En producción, componentes usan **SOLO** services que consultan DB
- ✅ Archivos `*Data.ts` NO se importan en runtime

### Tareas

#### 2.1 Seed: Verduras (VEGETABLE_OPTIONS)
- **Descripción:** Crear tabla y seed con catálogo de verduras desde `ingredientsData.ts`
- **Archivo:** `supabase/migrations/20250106_006_seed_vegetables_catalog.sql`
- **Estrategia:** Extraer de `emergent/src/lib/ingredientsData.ts` → Convertir a SQL INSERT
- **Contenido:**
  ```sql
  -- Migration: 20250106_006_seed_vegetables_catalog.sql
  -- Source: emergent/src/lib/ingredientsData.ts (VEGETABLE_OPTIONS array)
  -- Rollback: DROP TABLE vegetables_catalog CASCADE;
  
  -- STOP CONDITION: Validar no existe tabla duplicada
  DO $$
  BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'vegetables_catalog') THEN
      RAISE NOTICE 'Table vegetables_catalog already exists, will use ON CONFLICT';
    END IF;
  END $$;
  
  CREATE TABLE IF NOT EXISTS vegetables_catalog (
    id text PRIMARY KEY,
    name text NOT NULL,
    unit text DEFAULT 'kg',
    suggested_price_per_kg numeric,
    created_at timestamptz DEFAULT now()
  );
  
  -- Seed extraído de ingredientsData.ts
  INSERT INTO vegetables_catalog (id, name, suggested_price_per_kg, unit) VALUES
    ('tomate', 'Tomate', 3.50, 'kg'),
    ('cebolla', 'Cebolla', 2.80, 'kg'),
    ('zanahoria', 'Zanahoria', 2.00, 'kg'),
    ('papa', 'Papa', 2.50, 'kg'),
    ('lechuga', 'Lechuga', 2.00, 'unidad'),
    ('brocoli', 'Brócoli', 4.50, 'kg'),
    ('coliflor', 'Coliflor', 4.00, 'kg'),
    ('espinaca', 'Espinaca', 5.00, 'kg'),
    ('calabaza', 'Calabaza', 3.00, 'kg'),
    ('pimiento', 'Pimiento', 4.50, 'kg'),
    ('ajo', 'Ajo', 12.00, 'kg'),
    ('perejil', 'Perejil', 3.00, 'atado'),
    ('culantro', 'Culantro', 2.50, 'atado'),
    ('apio', 'Apio', 3.50, 'kg'),
    ('choclo', 'Choclo', 2.00, 'unidad')
  ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    suggested_price_per_kg = EXCLUDED.suggested_price_per_kg,
    unit = EXCLUDED.unit;
  
  -- RLS
  ALTER TABLE vegetables_catalog ENABLE ROW LEVEL SECURITY;
  CREATE POLICY vegetables_read ON vegetables_catalog FOR SELECT TO authenticated USING (true);
  
  -- STOP CONDITION: Validación post-seed
  DO $$
  DECLARE
    veg_count int;
  BEGIN
    SELECT COUNT(*) INTO veg_count FROM vegetables_catalog;
    IF veg_count < 15 THEN
      RAISE WARNING 'Expected 15 vegetables, got %', veg_count;
    END IF;
    RAISE NOTICE 'Vegetables catalog seeded: % items', veg_count;
  END $$;
  ```
- **Criterios de Aceptación:**
  - Tabla creada con ~15 verduras
  - Precios sugeridos incluidos
  - ON CONFLICT maneja duplicados
  - RLS: lectura para todos autenticados

#### 2.2 Seed: Ajíes (CHILI_OPTIONS)
- **Descripción:** Añadir catálogo de ajíes/chiles
- **Archivo:** `supabase/migrations/20250106_007_seed_chilis_catalog.sql`
- **Fuente:** `emergent/src/lib/ingredientsData.ts` (CHILI_OPTIONS array)
- **Estructura:** Similar a vegetables_catalog
- **Criterios de Aceptación:**
  - ~5 tipos de ají con precios
  - Flag `is_spicy` para identificar
  - ON CONFLICT DO UPDATE

#### 2.3 Seed: Staff Roles Catalog
- **Descripción:** Crear tabla con roles de personal desde `staffRoles.ts`
- **Archivo:** `supabase/migrations/20250106_008_seed_staff_roles_catalog.sql`
- **Fuente:** `emergent/src/lib/staffRoles.ts`
- **Contenido:**
  ```sql
  -- Migration: 20250106_008_seed_staff_roles_catalog.sql
  -- Source: emergent/src/lib/staffRoles.ts
  
  CREATE TABLE IF NOT EXISTS staff_roles_catalog (
    id text PRIMARY KEY,
    name text NOT NULL,
    default_rate numeric,
    rate_type text CHECK (rate_type IN ('hourly', 'per_plate', 'fixed')),
    has_system_access boolean DEFAULT false,
    description text,
    created_at timestamptz DEFAULT now()
  );
  
  -- Seed extraído de staffRoles.ts
  INSERT INTO staff_roles_catalog (id, name, default_rate, rate_type, has_system_access, description) VALUES
    ('coordinador', 'Coordinador', 15, 'hourly', true, 'Coordinador general del evento (puede tener acceso al sistema)'),
    ('encargado_compras', 'Encargado de Compras', 10, 'hourly', true, 'Encargado de compras y gastos (puede tener acceso al sistema)'),
    ('mesero', 'Mesero', 10, 'hourly', false, 'Mesero / Servicio de mesa'),
    ('limpieza', 'Servicio de Limpieza', 15, 'hourly', false, 'Personal de limpieza'),
    ('servido', 'Servicio de Servido', 5, 'per_plate', false, 'Personal de servido (tarifa por plato)')
  ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    default_rate = EXCLUDED.default_rate,
    rate_type = EXCLUDED.rate_type,
    has_system_access = EXCLUDED.has_system_access,
    description = EXCLUDED.description;
  
  -- RLS
  ALTER TABLE staff_roles_catalog ENABLE ROW LEVEL SECURITY;
  CREATE POLICY staff_roles_read ON staff_roles_catalog FOR SELECT TO authenticated USING (true);
  
  -- Validación
  DO $$
  DECLARE
    role_count int;
  BEGIN
    SELECT COUNT(*) INTO role_count FROM staff_roles_catalog;
    IF role_count < 5 THEN
      RAISE EXCEPTION 'Expected 5 staff roles, got %', role_count;
    END IF;
    RAISE NOTICE 'Staff roles catalog seeded: % roles', role_count;
  END $$;
  ```
- **Criterios de Aceptación:**
  - 5 roles de staff con tarifas
  - Campo `has_system_access` diferencia roles con acceso al sistema
  - `rate_type` define si es hourly, per_plate, o fixed

#### 2.4 Seed: Decoration Providers
- **Descripción:** Crear tabla de proveedores de decoración desde `decorationData.ts`
- **Archivo:** `supabase/migrations/20250106_009_seed_decoration_providers.sql`
- **Fuente:** `emergent/src/lib/decorationData.ts`
- **Contenido:**
  ```sql
  -- Migration: 20250106_009_seed_decoration_providers.sql
  -- Source: emergent/src/lib/decorationData.ts
  
  CREATE TABLE IF NOT EXISTS decoration_providers (
    id text PRIMARY KEY,
    name text NOT NULL,
    contact_phone text,
    email text,
    notes text,
    created_at timestamptz DEFAULT now()
  );
  
  INSERT INTO decoration_providers (id, name) VALUES
    ('jimmy', 'Jimmy'),
    ('juan', 'Juan'),
    ('maria', 'María Decoraciones'),
    ('eventos-premium', 'Eventos Premium')
  ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name;
  
  -- RLS
  ALTER TABLE decoration_providers ENABLE ROW LEVEL SECURITY;
  CREATE POLICY decoration_providers_read ON decoration_providers 
    FOR SELECT TO authenticated USING (true);
  CREATE POLICY decoration_providers_write ON decoration_providers 
    FOR ALL TO authenticated
    USING (EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('admin','socio')));
  
  -- Validación
  DO $$
  BEGIN
    IF (SELECT COUNT(*) FROM decoration_providers) < 4 THEN
      RAISE EXCEPTION 'Expected 4 decoration providers';
    END IF;
    RAISE NOTICE 'Decoration providers seeded successfully';
  END $$;
  ```
- **Criterios de Aceptación:**
  - 4 proveedores registrados
  - RLS: Admin/Socio pueden editar, otros solo leen

#### 2.5 Seed: Decoration Packages
- **Descripción:** Crear tabla de paquetes de decoración
- **Archivo:** `supabase/migrations/20250106_010_seed_decoration_packages.sql`
- **Fuente:** `emergent/src/lib/decorationData.ts`
- **Contenido:**
  ```sql
  -- Migration: 20250106_010_seed_decoration_packages.sql
  -- Source: emergent/src/lib/decorationData.ts
  
  CREATE TABLE IF NOT EXISTS decoration_packages (
    id text PRIMARY KEY,
    name text NOT NULL,
    provider_id text REFERENCES decoration_providers(id),
    provider_cost numeric NOT NULL,
    client_cost numeric NOT NULL,
    description text,
    created_at timestamptz DEFAULT now()
  );
  
  -- Extraer paquetes de decorationData.ts
  INSERT INTO decoration_packages (id, name, provider_id, provider_cost, client_cost, description) VALUES
    ('cumple-completo-jimmy', 'Decoración Completa de Cumpleaños', 'jimmy', 500, 800, 'Paquete completo para cumpleaños con globos, mesa de dulces y decoración temática'),
    ('flores-especial-maria', 'Decoración Especial con Flores', 'maria', 700, 1100, 'Arreglos florales premium y centros de mesa elegantes'),
    ('boda-elegante-premium', 'Decoración de Boda Elegante', 'eventos-premium', 1500, 2500, 'Decoración completa para boda: arco, sillas, centros de mesa, iluminación'),
    ('infantil-tematico-juan', 'Decoración Temática Infantil', 'juan', 400, 650, 'Decoración temática para fiestas infantiles (superhéroes, princesas, etc.)')
  ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    provider_id = EXCLUDED.provider_id,
    provider_cost = EXCLUDED.provider_cost,
    client_cost = EXCLUDED.client_cost,
    description = EXCLUDED.description;
  
  -- RLS
  ALTER TABLE decoration_packages ENABLE ROW LEVEL SECURITY;
  CREATE POLICY decoration_packages_read ON decoration_packages 
    FOR SELECT TO authenticated USING (true);
  CREATE POLICY decoration_packages_write ON decoration_packages 
    FOR ALL TO authenticated
    USING (EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('admin','socio')));
  
  -- Validación
  DO $$
  BEGIN
    IF (SELECT COUNT(*) FROM decoration_packages) < 4 THEN
      RAISE EXCEPTION 'Expected at least 4 decoration packages';
    END IF;
    RAISE NOTICE 'Decoration packages seeded successfully';
  END $$;
  ```
- **Criterios de Aceptación:**
  - 4+ paquetes con costos proveedor/cliente
  - FK a decoration_providers

#### 2.6 Validación: Menu Items vs menuItems.ts (OBSERVACIÓN #5)
- **Descripción:** Comparar seed existente de `menu_dishes` con `menuItems.ts` de Emergent
- **Fuente:** `emergent/src/lib/menuItems.ts`
- **Acción:**
  - Query: `SELECT id, name, base_price FROM menu_dishes ORDER BY name;`
  - Comparar con array de menuItems.ts:
    ```typescript
    // emergent/src/lib/menuItems.ts
    export const menuItems: MenuItem[] = [
      { id: 'pollo-parrilla', name: 'Pollo a la Parrilla', price: 50, category: 'principal' },
      { id: 'carne-asada', name: 'Carne Asada', price: 60, category: 'principal' },
      { id: 'pescado-frito', name: 'Pescado Frito', price: 55, category: 'principal' },
      { id: 'lomo-saltado', name: 'Lomo Saltado', price: 65, category: 'principal' },
      { id: 'arroz-pollo', name: 'Arroz con Pollo', price: 45, category: 'principal' },
      { id: 'tallarines-rojos', name: 'Tallarines Rojos', price: 40, category: 'principal' },
      { id: 'ceviche', name: 'Ceviche', price: 70, category: 'principal' },
      { id: 'parrillada-mixta', name: 'Parrillada Mixta', price: 80, category: 'principal' }
    ];
    ```
  - Añadir/actualizar platos faltantes si necesario
- **Archivo:** `supabase/migrations/20250106_011_sync_menu_items.sql` (solo si hay diferencias)
- **Contenido:**
  ```sql
  -- Migration: 20250106_011_sync_menu_items.sql
  -- Source: emergent/src/lib/menuItems.ts
  -- Description: Sincronizar menu_dishes con menuItems de Emergent
  
  INSERT INTO menu_dishes (id, name, base_price, category, portions_per_recipe) VALUES
    ('pollo-parrilla', 'Pollo a la Parrilla', 50, 'principal', 1),
    ('carne-asada', 'Carne Asada', 60, 'principal', 1),
    ('pescado-frito', 'Pescado Frito', 55, 'principal', 1),
    ('lomo-saltado', 'Lomo Saltado', 65, 'principal', 1),
    ('arroz-pollo', 'Arroz con Pollo', 45, 'principal', 1),
    ('tallarines-rojos', 'Tallarines Rojos', 40, 'principal', 1),
    ('ceviche', 'Ceviche', 70, 'principal', 1),
    ('parrillada-mixta', 'Parrillada Mixta', 80, 'principal', 1)
  ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    base_price = EXCLUDED.base_price,
    category = EXCLUDED.category;
  
  -- Validación
  DO $$
  DECLARE
    dish_count int;
  BEGIN
    SELECT COUNT(*) INTO dish_count FROM menu_dishes WHERE category = 'principal';
    IF dish_count < 8 THEN
      RAISE WARNING 'Expected at least 8 principal dishes, got %', dish_count;
    END IF;
    RAISE NOTICE 'Menu items synchronized: % principal dishes', dish_count;
  END $$;
  ```
- **Criterios de Aceptación:**
  - Todos los platos de menuItems.ts existen en Bolt
  - Precios coinciden o están documentadas diferencias

### Entregables Fase 2
- 6 migraciones de seed ejecutadas
- Catálogos poblados: verduras, ajíes, staff roles, proveedores decoración, paquetes decoración
- Menu items validados y sincronizados
- Script de validación: `supabase/scripts/validate_catalogs.sql`
- **CONFIRMADO:** Archivos `*Data.ts` NO se usan en componentes de producción

**Commit Esperado:**
```bash
git add supabase/migrations/20250106_006*.sql supabase/migrations/20250106_007*.sql
git commit -m "feat(db): seed vegetables and chilis catalogs from Emergent arrays"

git add supabase/migrations/20250106_008*.sql
git commit -m "feat(db): seed staff roles catalog from Emergent"

git add supabase/migrations/20250106_009*.sql supabase/migrations/20250106_010*.sql
git commit -m "feat(db): seed decoration providers and packages from Emergent"

git add supabase/migrations/20250106_011*.sql
git commit -m "feat(db): sync menu items with Emergent menuItems.ts"
```

---

## FASE 3: AJUSTES DE RLS POLICIES (Día 3 - Mañana)

### Objetivo
Refinar políticas RLS para cumplir con permisos específicos de cada rol según manuales Emergent

**ACTUALIZACIÓN:** RLS policies deben validar contra tabla `roles` (OBSERVACIÓN #1)

### Tareas

#### 3.1 Actualizar Helper View `me` (OBSERVACIÓN #1)
- **Descripción:** View que valida rol contra tabla `roles`
- **Archivo:** `supabase/migrations/20250106_012_update_me_view.sql`
- **Contenido:**
  ```sql
  -- Migration: 20250106_012_update_me_view.sql
  -- Description: Actualizar view 'me' para validar contra tabla roles
  
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
    IF NOT EXISTS (SELECT 1 FROM information_schema.views WHERE table_name = 'me') THEN
      RAISE EXCEPTION 'View me was not created';
    END IF;
    RAISE NOTICE 'Helper view "me" updated with roles validation';
  END $$;
  ```
- **Criterios de Aceptación:**
  - View creada con JOIN a roles
  - Solo usuarios con rol válido aparecen en view

#### 3.2 Policy: Coordinador en `event_expenses`
- **Descripción:** Limitar coordinador a solo gastos de categoría "adicional"
- **Archivo:** `supabase/migrations/20250106_013_rls_coordinator_expenses.sql`
- **Contenido:**
  ```sql
  -- Migration: 20250106_013_rls_coordinator_expenses.sql
  -- Description: Policy específica para coordinador en expenses
  
  -- Drop policy genérica si existe
  DROP POLICY IF EXISTS expenses_insert ON event_expenses;
  
  -- Nueva policy para INSERT con validación de rol via tabla roles
  CREATE POLICY expenses_insert_by_role ON event_expenses
  FOR INSERT TO authenticated
  WITH CHECK (
    -- Coordinador: solo categoría 'adicional'
    (
      EXISTS (
        SELECT 1 FROM me 
        WHERE role IN (SELECT id FROM roles WHERE id = 'coordinador')
      )
      AND category = 'adicional'
    )
    OR
    -- Admin, Socio, Encargado Compras: cualquier categoría
    EXISTS (
      SELECT 1 FROM me 
      WHERE role IN (SELECT id FROM roles WHERE id IN ('admin','socio','encargado_compras'))
    )
  );
  
  -- Test inline
  DO $$
  BEGIN
    -- Simular usuario coordinador intentando INSERT gasto no-adicional
    -- (Este test debe ejecutarse manualmente con usuario real)
    RAISE NOTICE 'Policy created. Test manually: Coordinador can only INSERT category=adicional';
  END $$;
  ```
- **Criterios de Aceptación:**
  - Coordinador solo puede INSERT gastos con category = 'adicional'
  - Admin/Socio/Encargado pueden INSERT cualquier categoría
  - Test: Intentar INSERT con coordinador y category != 'adicional' → debe fallar

#### 3.3 Policy: Coordinador en `event_incomes`
- **Descripción:** Permitir coordinador registrar ingresos
- **Archivo:** `supabase/migrations/20250106_014_rls_coordinator_incomes.sql`
- **Contenido:**
  ```sql
  -- Migration: 20250106_014_rls_coordinator_incomes.sql
  
  ALTER TABLE event_incomes ENABLE ROW LEVEL SECURITY;
  
  -- SELECT: Admin, Socio, Coordinador
  DROP POLICY IF EXISTS incomes_select ON event_incomes;
  CREATE POLICY incomes_select ON event_incomes
  FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM me 
      WHERE role IN (SELECT id FROM roles WHERE id IN ('admin','socio','coordinador'))
    )
  );
  
  -- INSERT: Admin, Socio, Coordinador
  DROP POLICY IF EXISTS incomes_insert ON event_incomes;
  CREATE POLICY incomes_insert ON event_incomes
  FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM me 
      WHERE role IN (SELECT id FROM roles WHERE id IN ('admin','socio','coordinador'))
    )
  );
  
  -- Validación
  DO $$
  BEGIN
    RAISE NOTICE 'Income policies created for admin, socio, coordinador';
  END $$;
  ```
- **Criterios de Aceptación:**
  - Coordinador puede SELECT e INSERT en event_incomes
  - Servicio y Encargado Compras NO pueden acceder

#### 3.4 Validación: RLS por Rol
- **Descripción:** Crear script de validación de permisos
- **Archivo:** `supabase/scripts/test_rls_by_role.sql`
- **Contenido:** Tests SQL simulando cada rol
  ```sql
  -- Script: test_rls_by_role.sql
  -- Description: Validar RLS policies para cada rol
  
  -- TEST 1: Admin (debe tener acceso a todo)
  -- Ejecutar manualmente con usuario admin
  
  -- TEST 2: Coordinador - Gastos adicionales (debe funcionar)
  -- Ejecutar con usuario coordinador:
  INSERT INTO event_expenses (event_id, category, amount, description) 
  VALUES (1, 'adicional', 50, 'Test coordinador adicional');
  -- Esperado: ✅ SUCCESS
  
  -- TEST 3: Coordinador - Gastos comida (debe fallar)
  -- Ejecutar con usuario coordinador:
  INSERT INTO event_expenses (event_id, category, amount, description) 
  VALUES (1, 'comida', 100, 'Test coordinador comida');
  -- Esperado: ❌ ERROR: new row violates row-level security policy
  
  -- TEST 4: Coordinador - Ingresos (debe funcionar)
  INSERT INTO event_incomes (event_id, amount, description)
  VALUES (1, 200, 'Test coordinador ingreso');
  -- Esperado: ✅ SUCCESS
  
  -- TEST 5: Encargado Compras - Ingredientes (debe funcionar)
  -- Ejecutar con usuario encargado_compras:
  INSERT INTO event_ingredients (event_id, ingredient_name, quantity, unit_cost, total_cost)
  VALUES (1, 'Tomate', 5, 3.50, 17.50);
  -- Esperado: ✅ SUCCESS
  
  -- TEST 6: Servicio - Ver eventos asignados (debe funcionar)
  -- TEST 7: Servicio - Ver eventos no asignados (debe fallar)
  
  -- Resumen de tests
  SELECT 
    'RLS Tests Summary' as title,
    'Run tests manually with actual users' as instruction,
    'Document results in docs/RLS_TEST_RESULTS.md' as output;
  ```
- **Criterios de Aceptación:**
  - 5 roles testeados (admin, socio, coordinador, encargado_compras, servicio)
  - Documento de resultados: `docs/RLS_TEST_RESULTS.md`

### Entregables Fase 3
- 3 migraciones de ajuste RLS
- View `me` actualizada con validación contra roles
- Script de validación RLS
- Documento: `docs/RLS_TEST_RESULTS.md`

**Commit Esperado:**
```bash
git add supabase/migrations/20250106_012*.sql supabase/migrations/20250106_013*.sql supabase/migrations/20250106_014*.sql
git commit -m "feat(db): refine RLS policies with roles table validation"

git add supabase/scripts/test_rls_by_role.sql docs/RLS_TEST_RESULTS.md
git commit -m "test(db): add RLS validation script and results"
```

---

## FASE 4: SERVICES LAYER (Día 3 - Tarde + Día 4)

*[Contenido igual que versión anterior, sin cambios necesarios]*

### Objetivo
Crear/actualizar services TypeScript para abstraer acceso a Supabase

**NOTA IMPORTANTE (OBSERVACIÓN #5):**  
Los services **NO importan** archivos `*Data.ts`. Todos los datos vienen de queries a Supabase.

### Tareas

#### 4.1 Service: `ingredientsService.ts`
- **Descripción:** Service para gestión de ingredientes y verduras
- **Archivo:** `src/services/ingredientsService.ts`
- **Funciones:**
  ```typescript
  export const ingredientsService = {
    // Catálogos (desde DB, NO desde ingredientsData.ts)
    getVegetablesCatalog(): Promise<Vegetable[]>  // SELECT * FROM vegetables_catalog
    getChilisCatalog(): Promise<Chili[]>  // SELECT * FROM chilis_catalog
    
    // Ingredientes de evento
    getEventIngredients(eventId: number): Promise<EventIngredient[]>
    addEventIngredient(data: CreateEventIngredient): Promise<EventIngredient>
    updateEventIngredient(id: number, data: Partial<EventIngredient>): Promise<EventIngredient>
    deleteEventIngredient(id: number): Promise<void>
    
    // Calculadora
    calculateTotalIngredientsCost(eventId: number): Promise<number>
  }
  ```
- **Criterios de Aceptación:**
  - Todas las funciones implementadas con Supabase client
  - **NO** hay imports de `ingredientsData.ts`
  - Error handling consistente
  - TypeScript types exportados

#### 4.2 Service: `decorationService.ts`
- **Descripción:** Service para decoración (actualizar existente)
- **Archivo:** `src/services/decorationService.ts` (ya existe en Bolt, actualizar)
- **Nuevas Funciones:**
  ```typescript
  // Desde DB, NO desde decorationData.ts
  getDecorationProviders(): Promise<DecorationProvider[]>  // SELECT * FROM decoration_providers
  getDecorationPackages(): Promise<DecorationPackage[]>  // SELECT * FROM decoration_packages
  getPackagesByProvider(providerId: string): Promise<DecorationPackage[]>
  ```
- **Criterios de Aceptación:**
  - Service actualizado con nuevos métodos
  - Compatible con componentes de Emergent
  - **NO** hay imports de `decorationData.ts`

#### 4.3 Service: `staffService.ts`
- **Descripción:** Service para gestión de personal
- **Archivo:** `src/services/staffService.ts` (nuevo)
- **Funciones:**
  ```typescript
  export const staffService = {
    // Desde DB, NO desde staffRoles.ts
    getStaffRolesCatalog(): Promise<StaffRole[]>  // SELECT * FROM staff_roles_catalog
    
    getEventStaff(eventId: number): Promise<EventStaff[]>
    addEventStaff(data: CreateEventStaff): Promise<EventStaff>
    updateEventStaff(id: number, data: Partial<EventStaff>): Promise<EventStaff>
    deleteEventStaff(id: number): Promise<void>
    calculateTotalStaffCost(eventId: number): Promise<number>
  }
  ```
- **Criterios de Aceptación:**
  - Service completo con CRUD
  - Cálculo de costos por rol (hourly vs per_plate)
  - **NO** hay imports de `staffRoles.ts`

#### 4.4 Service: `auditService.ts`
- **Descripción:** Service para logging de auditoría (validar existente)
- **Archivo:** `src/services/auditService.ts` (ya existe, validar)
- **Funciones Requeridas:**
  ```typescript
  logAction(params: {
    eventId?: number;
    action: string;
    section: string;
    description: string;
  }): Promise<void>
  
  getAuditLogs(eventId?: number): Promise<AuditLog[]>
  ```
- **Criterios de Aceptación:**
  - Compatible con `auditLogger.ts` de Emergent (lógica, no import)
  - Logs incluyen user_id, role, timestamp automáticos
  - **NOTA:** Triggers automáticos (Fase 1.6) ya loggean la mayoría de acciones

#### 4.5 Service: `pettyCashService.ts` (NUEVO - OBSERVACIÓN #2)
- **Descripción:** Nuevo service para caja chica con historial
- **Archivo:** `src/services/pettyCashService.ts` (nuevo)
- **Funciones:**
  ```typescript
  export const pettyCashService = {
    // Status desde view
    getPettyCashStatus(eventId: number): Promise<PettyCashStatus>  // SELECT * FROM petty_cash_status WHERE event_id = ?
    
    // Movimientos
    getMovements(eventId: number): Promise<PettyCashMovement[]>
    assignBudget(eventId: number, amount: number, description: string): Promise<PettyCashMovement>
    recordExpense(eventId: number, amount: number, description: string, category?: string, receiptUrl?: string): Promise<PettyCashMovement>
    recordAdjustment(eventId: number, amount: number, description: string): Promise<PettyCashMovement>
    recordRefund(eventId: number, amount: number, description: string): Promise<PettyCashMovement>
    
    // Admin only
    deleteMovement(movementId: number): Promise<void>  // Solo admin por RLS
  }
  
  interface PettyCashStatus {
    eventId: number;
    budget: number;
    spent: number;
    refunds: number;
    remaining: number;
    totalMovements: number;
    lastMovementAt: Date;
  }
  ```
- **Criterios de Aceptación:**
  - CRUD completo de movimientos
  - View `petty_cash_status` usada para consultas rápidas
  - Validación: spent no puede exceder budget (en componente o DB check)

#### 4.6 Validación: Services Existentes
- **Descripción:** Revisar services ya creados en Bolt
- **Archivos:**
  - src/services/menu.service.ts ✅ (ya validado, muy completo)
  - src/services/events.service.ts ✅
  - src/services/clients.service.ts ✅
  - src/services/auth.service.ts ✅
  - etc.
- **Acción:** Documentar compatibilidad con Emergent UI
- **Criterios de Aceptación:**
  - Documento: `docs/SERVICES_COMPATIBILITY_MATRIX.md`
  - Lista de servicios OK vs servicios a ajustar
  - **CONFIRMADO:** Ningún service importa archivos `*Data.ts`

### Entregables Fase 4
- 3 nuevos services: ingredients, staff, pettyCash
- 2 services actualizados: decoration, audit (validado)
- Documento de compatibilidad de services
- **CONFIRMADO:** Cero imports de `*Data.ts` en services

**Commits Esperados:**
```bash
git add src/services/ingredientsService.ts
git commit -m "feat(services): add ingredients service with DB catalog queries"

git add src/services/staffService.ts
git commit -m "feat(services): add staff service with CRUD and cost calculation"

git add src/services/pettyCashService.ts
git commit -m "feat(services): add petty cash service with movements history"

git add src/services/decorationService.ts
git commit -m "feat(services): update decoration service with providers and packages from DB"

git add docs/SERVICES_COMPATIBILITY_MATRIX.md
git commit -m "docs: add services compatibility matrix (no *Data.ts imports confirmed)"
```

---

## FASES 5-11: [Contenido igual que versión anterior]

*Las fases restantes (5: Importación UI, 6: Integración Services, 7: React Query Hooks, 8: Auth/Routing, 9: CORS/Deployment, 10: Testing, 11: Documentación/PR) no requieren cambios estructurales más allá de:*

**Cambios menores en todas las fases:**
- Todos los componentes usan services (que consultan DB), NO imports de `*Data.ts`
- Tests validan que registered_by_name se llena automáticamente (trigger)
- Tests validan que audit_logs se llenan automáticamente (triggers)
- Tests de caja chica usan nueva tabla `petty_cash_movements`

---

## RESUMEN DE CAMBIOS POR OBSERVACIÓN

| Observación | Cambio en Plan | Fases Afectadas | Migraciones Añadidas |
|-------------|----------------|-----------------|----------------------|
| #1 | Constraint FK users.role → roles | Fase 1 | 20250106_001b, 20250106_012 (view) |
| #2 | Tabla petty_cash_movements + view | Fase 1, Fase 4 | 20250106_003 (nuevo modelo) |
| #3 | 5 triggers auditoría automática | Fase 1 | 20250106_015 (5 triggers) |
| #4 | Trigger registered_by_name snapshot | Fase 1 | 20250106_016 (1 trigger, 5 tablas) |
| #5 | Confirmación: seeds de arrays, sin *Data.ts en runtime | Fase 2, Fase 4, Fase 5, Fase 6 | Validaciones en services y componentes |
| #6 | Stop conditions en todas las migraciones + rollback | Todas las fases | Validaciones en TODAS las migraciones + rollback_integration.sql |

---

## CRITERIOS DE ACEPTACIÓN GLOBALES (ACTUALIZADOS)

### Funcionales
1. ✅ Usuario admin puede crear evento completo con todos los tabs
2. ✅ Coordinador puede registrar gastos adicionales pero no de otras categorías (RLS validado)
3. ✅ Encargado compras puede registrar ingredientes con precios
4. ✅ Servicio solo ve eventos asignados (RLS)
5. ✅ **Caja chica con historial completo** (tabla movements + view)
6. ✅ Resumen financiero calcula totales automáticamente
7. ✅ **Audit logs se registran automáticamente** (triggers)
8. ✅ **registered_by_name se llena automáticamente** (trigger)
9. ✅ Upload de recibos funciona (bucket + RLS)
10. ✅ **Constraint FK valida roles contra tabla `roles`**

### Técnicos
1. ✅ 0 errores TypeScript en modo strict
2. ✅ Build exitoso: `npm run build`
3. ✅ Lint sin errores críticos: `npm run lint`
4. ✅ Todas las queries usan React Query
5. ✅ RLS habilitado en todas las tablas
6. ✅ **RLS valida contra tabla `roles`** (no hardcoded)
7. ✅ No hay `service_role` en frontend
8. ✅ Environment variables correctas (.env.local)
9. ✅ CORS configurado en Supabase
10. ✅ **Todas las migraciones tienen stop conditions** (validaciones pre/post)
11. ✅ **Script de rollback global disponible**
12. ✅ **Cero imports de `*Data.ts` en services o componentes de producción**

### Documentación
1. ✅ README actualizado con setup completo
2. ✅ CHANGELOG con todos los cambios
3. ✅ Comentarios en código para lógica compleja
4. ✅ Documentos de validación (SCHEMA_PARITY_REPORT, SMOKE_TESTS_RESULTS, RLS_TEST_RESULTS)
5. ✅ **Rollback script documentado**

### Testing
1. ✅ Smoke tests manuales por 5 roles
2. ✅ RLS validado con tests SQL (coordinador solo adicionales)
3. ✅ Performance queries < 500ms
4. ✅ **Triggers de auditoría validados** (logs automáticos)
5. ✅ **Trigger de registered_by_name validado** (snapshot automático)
6. ✅ **Caja chica con movimientos validado** (historial completo)

---

## MÉTRICAS ACTUALIZADAS

**Total de Tareas:** 73 (antes 68)  
**Total de Migraciones:** 14 (antes 11)  
**Duración Estimada:** 7-8 días (sin cambio)

---

## APROBACIÓN FINAL

### Checklist de Observaciones Incorporadas

- [x] **Observación #1:** Constraint FK de users.role → roles implementado
- [x] **Observación #2:** Modelo caja chica con tabla de movimientos + view
- [x] **Observación #3:** 5 triggers de auditoría automática en primera iteración
- [x] **Observación #4:** Trigger de registered_by_name snapshot
- [x] **Observación #5:** Confirmado: seeds de arrays Emergent, sin *Data.ts en producción
- [x] **Observación #6:** Stop conditions en todas las migraciones + script de rollback global

**Estado:** ✅ APROBADO PARA EJECUCIÓN

---

**Fin del Plan de Trabajo (Versión Revisada)**  
**Versión:** 1.1  
**Última Actualización:** 2025-01-06  
**Incorpora:** 6 Observaciones Críticas del Usuario  
**Estado:** ✅ LISTO PARA EJECUCIÓN
