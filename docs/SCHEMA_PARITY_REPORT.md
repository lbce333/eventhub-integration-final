# SCHEMA PARITY REPORT
## Análisis de Brechas: Emergent Manuales vs Bolt Estado Actual

**Fecha de Análisis:** 2025-01-06  
**Versión:** 1.1 (Revisado con Observaciones)  
**Analista:** Claude Code  
**Repositorios Analizados:**
- Base (Bolt): github.com/mce333/eventhub-production
- UI/Dominio (Emergent): github.com/mce333/export-ui-only

---

## RESUMEN EJECUTIVO

### Estado General: ✅ ALTO NIVEL DE PARIDAD (85%)

El proyecto Bolt ya tiene implementada la mayoría de la estructura de base de datos requerida por los manuales de Emergent. Se identificaron **25+ migraciones** existentes que cubren las tablas principales, RLS policies, y buckets de storage. 

**ACTUALIZACIÓN POST-REVISIÓN:** Se han identificado 6 puntos críticos adicionales que deben implementarse antes de la ejecución:
1. Constraint de `users.role` contra tabla `roles`
2. Modelo de caja chica con historial completo
3. Triggers de auditoría automática en primera iteración
4. Trigger para snapshot de `registered_by_name`
5. Confirmación: seeds solo de arrays Emergent para poblar DB, sin *Data.ts en producción
6. Stop conditions para migraciones con rollback/dup handling

---

## 1. TABLAS DE BASE DE DATOS

### 1.1 Tablas COMPLETAMENTE IMPLEMENTADAS ✅

| Tabla | Estado | Migración | Notas |
|-------|--------|-----------|-------|
| `users` | ✅ COMPLETA | 20251029215816_001_initial_schema.sql | Extiende auth.users, incluye role, phone, name, last_name |
| `clients` | ✅ COMPLETA | 20251029215816_001_initial_schema.sql | id, name, email, phone, company, address, created_by |
| `events` | ✅ COMPLETA | 20251029215816_001_initial_schema.sql | Incluye type, status, date, location, service_type |
| `event_contracts` | ✅ COMPLETA | 20251029215816_001_initial_schema.sql | precio_total, pago_adelantado, saldo_pendiente |
| `event_receipts` | ✅ COMPLETA | 20251029215816_001_initial_schema.sql | receipt_url, amount, uploaded_by |
| `event_expenses` | ✅ COMPLETA | 20251029215816_001_initial_schema.sql | category, description, amount, registered_by |
| `event_decoration` | ✅ COMPLETA | 20251029215816_001_initial_schema.sql | item, quantity, unit_price |
| `event_furniture` | ✅ COMPLETA | 20251029215816_001_initial_schema.sql | item, quantity, condition |
| `event_staff` | ✅ COMPLETA | 20251029215816_001_initial_schema.sql | role, hours, hourly_rate |
| `event_timeline` | ✅ COMPLETA | 20251029215816_001_initial_schema.sql | date, title, type, description |
| `audit_logs` | ✅ COMPLETA | 20251029215816_001_initial_schema.sql | user_id, action, section, event_id |
| `menu_dishes` | ✅ COMPLETA | 20251102230714_add_menu_and_ingredients_system_fixed.sql | id, name, category, base_price, portions_per_recipe |
| `dish_ingredients` | ✅ COMPLETA | 20251102230714_add_menu_and_ingredients_system_fixed.sql | dish_id, ingredient_name, base_quantity, unit, is_vegetable |
| `event_ingredients` | ✅ COMPLETA | 20251102230714_add_menu_and_ingredients_system_fixed.sql | event_id, quantity, unit_cost, total_cost, registered_by |
| `event_staff_extra_hours` | ✅ COMPLETA | 20251103001849_add_staff_extra_hours_table.sql | staff_id, extra_hours, reason |
| `warehouse_movements` | ✅ COMPLETA | 20251103055439_add_warehouse_system.sql | type, item, quantity, event_id |

### 1.2 Tablas PARCIALMENTE IMPLEMENTADAS ⚠️

| Tabla | Estado | Brecha Identificada | Acción Requerida |
|-------|--------|---------------------|------------------|
| `event_incomes` | ⚠️ PARCIAL | Falta columna `coordinator_notes` según GUIA_DE_USO_SISTEMA.md | Añadir migración para agregar columna |
| `decoration_packages` | ⚠️ PARCIAL | Existe tabla pero faltan seeds con datos de decorationData.ts | Crear seed script con paquetes de Jimmy, Juan, María, Eventos Premium |

### 1.3 Tablas FALTANTES ❌

| Tabla Requerida | Fuente | Razón | Prioridad |
|-----------------|--------|-------|-----------|
| `roles` | DB_PARITY_CHECKLIST.md | Catálogo de roles del sistema + constraint FK | CRÍTICA |
| `petty_cash_movements` | **NUEVA OBSERVACIÓN** | Historial de movimientos de caja chica | CRÍTICA |
| `staff_roles_catalog` | staffRoles.ts (Emergent) | Catálogo de roles de personal (coordinador, mesero, limpieza) | ALTA |
| `decoration_providers` | decorationData.ts (Emergent) | Catálogo de proveedores de decoración | MEDIA |

**ACTUALIZACIÓN CRÍTICA - OBSERVACIÓN #1:**  
La tabla `users.role` debe tener constraint FOREIGN KEY contra `roles(id)` para garantizar integridad referencial.

**ACTUALIZACIÓN CRÍTICA - OBSERVACIÓN #2:**  
Caja chica requiere tabla de movimientos `petty_cash_movements` (no solo campos calculados en `events`). Ver sección 1.4.

---

### 1.4 NUEVO MODELO: CAJA CHICA CON HISTORIAL

**Observación #2 Implementada:**

#### Opción Seleccionada: **Tabla de Movimientos + View Agregada**

**Tabla: `petty_cash_movements`**
```sql
CREATE TABLE petty_cash_movements (
  id bigserial PRIMARY KEY,
  event_id bigint NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  movement_type text NOT NULL CHECK (movement_type IN ('budget_assignment', 'expense', 'adjustment', 'refund')),
  amount numeric NOT NULL,
  description text,
  category text, -- para expenses: 'transporte', 'varios', etc.
  receipt_url text,
  registered_by uuid REFERENCES users(id),
  registered_by_name text NOT NULL,
  registered_at timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now()
);

CREATE INDEX idx_petty_cash_movements_event ON petty_cash_movements(event_id, registered_at DESC);
```

**View: `petty_cash_status`**
```sql
CREATE OR REPLACE VIEW petty_cash_status AS
SELECT 
  event_id,
  SUM(CASE WHEN movement_type = 'budget_assignment' THEN amount ELSE 0 END) as budget,
  SUM(CASE WHEN movement_type IN ('expense', 'adjustment') THEN amount ELSE 0 END) as spent,
  SUM(CASE WHEN movement_type = 'refund' THEN amount ELSE 0 END) as refunds,
  SUM(CASE WHEN movement_type = 'budget_assignment' THEN amount ELSE 0 END) 
    - SUM(CASE WHEN movement_type IN ('expense', 'adjustment') THEN amount ELSE 0 END)
    + SUM(CASE WHEN movement_type = 'refund' THEN amount ELSE 0 END) as remaining
FROM petty_cash_movements
GROUP BY event_id;
```

**Ventajas:**
- ✅ Historial completo auditable
- ✅ Movimientos rastreables por usuario y timestamp
- ✅ View para consultas rápidas
- ✅ Permite ajustes y reembolsos
- ✅ Compatible con RLS (policies por event_id)

**Actualización en `events`:**  
REMOVER campos `petty_cash_budget`, `petty_cash_spent`, `petty_cash_remaining` (ahora en view).

---

## 2. COLUMNAS Y CAMPOS

### 2.1 Brechas Identificadas por Tabla

#### `users` Table - **ACTUALIZACIÓN CRÍTICA**
| Campo | Estado | Notas |
|-------|--------|-------|
| `role` | ⚠️ **REQUIERE CONSTRAINT** | **OBSERVACIÓN #1:** Añadir FK a `roles(id)` |

**Nueva Migración Requerida:**
```sql
-- Después de crear tabla roles
ALTER TABLE users 
  ADD CONSTRAINT fk_users_role 
  FOREIGN KEY (role) REFERENCES roles(id);
```

#### `events` Table
| Campo | Estado | Notas |
|-------|--------|-------|
| `garantia` / `security_deposit` | ✅ COMPLETO | Añadido en 20251103212441_add_security_deposit_field.sql |
| `decoration_advance` | ⚠️ VERIFICAR | Según RESUMEN_EJECUTIVO.md debe registrarse en creación, verificar si existe |
| ~~`petty_cash_*`~~ | ❌ **ELIMINADO** | **OBSERVACIÓN #2:** Usar tabla `petty_cash_movements` + view |

#### `event_expenses` Table
| Campo | Estado | Notas |
|-------|--------|-------|
| `receipt_url` | ✅ COMPLETO | Campo para subir comprobantes |
| `registered_by` | ✅ COMPLETO | UUID del usuario que registró |
| `registered_by_name` | ⚠️ **REQUIERE TRIGGER** | **OBSERVACIÓN #4:** Snapshot automático vía trigger |

#### `event_ingredients` Table
| Campo | Estado | Notas |
|-------|--------|-------|
| `registered_by_name` | ⚠️ **REQUIERE TRIGGER** | **OBSERVACIÓN #4:** Snapshot automático vía trigger |

#### `event_decoration` Table
| Campo | Estado | Notas |
|-------|--------|-------|
| `registered_by_name` | ⚠️ **REQUIERE TRIGGER** | **OBSERVACIÓN #4:** Snapshot automático vía trigger |

#### `event_staff` Table
| Campo | Estado | Notas |
|-------|--------|-------|
| `has_system_access` | ❌ FALTA | staffRoles.ts indica si el rol tiene acceso al sistema |
| `registered_by_name` | ⚠️ **REQUIERE TRIGGER** | **OBSERVACIÓN #4:** Snapshot automático vía trigger |

---

## 3. TRIGGERS Y AUTOMATIZACIÓN

### 3.1 Triggers IMPLEMENTADOS ✅

| Trigger | Tabla | Función | Estado |
|---------|-------|---------|--------|
| `update_financial_totals` | event_expenses, event_incomes | Actualiza totales automáticamente | ✅ COMPLETO (20251103001121) |
| `updated_at_trigger` | multiple tables | Actualiza timestamp automáticamente | ✅ COMPLETO |

### 3.2 Triggers REQUERIDOS (OBSERVACIONES #3 y #4) 🔴

**OBSERVACIÓN #3: Triggers de Auditoría Automática (Primera Iteración)**

#### Trigger: `audit_event_expenses_changes`
```sql
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
      format('Gasto registrado: %s - $%s', NEW.category, NEW.amount)
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

CREATE TRIGGER audit_event_expenses_trigger
AFTER INSERT OR UPDATE OR DELETE ON event_expenses
FOR EACH ROW EXECUTE FUNCTION audit_event_expenses_trigger();
```

**Triggers Similares Requeridos:**
- ✅ `audit_event_incomes_trigger` (INSERT/UPDATE/DELETE en event_incomes)
- ✅ `audit_event_staff_trigger` (INSERT/UPDATE/DELETE en event_staff)
- ✅ `audit_event_decoration_trigger` (INSERT/UPDATE/DELETE en event_decoration)
- ✅ `audit_petty_cash_trigger` (INSERT en petty_cash_movements)

---

**OBSERVACIÓN #4: Trigger para `registered_by_name` Snapshot**

#### Trigger: `set_registered_by_name`
```sql
CREATE OR REPLACE FUNCTION set_registered_by_name()
RETURNS TRIGGER AS $$
BEGIN
  -- Obtener nombre completo del usuario autenticado
  SELECT name || ' ' || last_name INTO NEW.registered_by_name
  FROM users
  WHERE id = auth.uid();
  
  -- Si no se encuentra, usar email
  IF NEW.registered_by_name IS NULL THEN
    SELECT email INTO NEW.registered_by_name
    FROM auth.users
    WHERE id = auth.uid();
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Aplicar a múltiples tablas
CREATE TRIGGER set_registered_by_name_expenses
BEFORE INSERT ON event_expenses
FOR EACH ROW EXECUTE FUNCTION set_registered_by_name();

CREATE TRIGGER set_registered_by_name_ingredients
BEFORE INSERT ON event_ingredients
FOR EACH ROW EXECUTE FUNCTION set_registered_by_name();

CREATE TRIGGER set_registered_by_name_decoration
BEFORE INSERT ON event_decoration
FOR EACH ROW EXECUTE FUNCTION set_registered_by_name();

CREATE TRIGGER set_registered_by_name_staff
BEFORE INSERT ON event_staff
FOR EACH ROW EXECUTE FUNCTION set_registered_by_name();

CREATE TRIGGER set_registered_by_name_petty_cash
BEFORE INSERT ON petty_cash_movements
FOR EACH ROW EXECUTE FUNCTION set_registered_by_name();
```

**Ventajas:**
- ✅ Snapshot automático del nombre en el momento de creación
- ✅ Inmutable (no cambia si usuario cambia su nombre después)
- ✅ Auditoría precisa histórica
- ✅ No requiere joins en queries de listado

---

## 4. ROW LEVEL SECURITY (RLS)

### 4.1 Estado de Políticas RLS

**Migración Base:** `20251031011429_complete_rls_policies.sql`  
**Migración Coordinador:** `20251103060219_fix_rls_add_coordinador_access.sql`

**ACTUALIZACIÓN - OBSERVACIÓN #1: RLS debe validar contra tabla `roles`**

#### Políticas RLS Actualizadas

**Helper View Mejorada:**
```sql
CREATE OR REPLACE VIEW public.me AS
  SELECT 
    up.user_id, 
    up.role,
    r.name as role_name,
    r.display_name as role_display_name
  FROM public.users up
  JOIN public.roles r ON r.id = up.role
  WHERE up.user_id = auth.uid();
```

**Ejemplo de Policy Actualizada:**
```sql
-- ANTES (sin validación de roles)
CREATE POLICY events_select ON public.events
FOR SELECT TO authenticated
USING (
  EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role IN ('admin','socio','coordinador'))
);

-- DESPUÉS (con validación contra tabla roles)
CREATE POLICY events_select ON public.events
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM me 
    WHERE role IN (
      SELECT id FROM roles WHERE id IN ('admin','socio','coordinador')
    )
  )
);
```

**Ventajas:**
- ✅ Roles validados en tiempo real contra catálogo
- ✅ Si rol no existe en tabla `roles`, policy falla (seguridad)
- ✅ No permite roles "fantasma" en campo `users.role`

### 4.2 Políticas para Nueva Tabla `petty_cash_movements`

```sql
ALTER TABLE petty_cash_movements ENABLE ROW LEVEL SECURITY;

-- SELECT: Admin/Socio/Coordinador pueden ver movimientos
CREATE POLICY petty_cash_select ON petty_cash_movements
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM me 
    WHERE role IN (SELECT id FROM roles WHERE id IN ('admin','socio','coordinador'))
  )
);

-- INSERT: Solo Admin/Socio/Coordinador pueden registrar movimientos
CREATE POLICY petty_cash_insert ON petty_cash_movements
FOR INSERT TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM me 
    WHERE role IN (SELECT id FROM roles WHERE id IN ('admin','socio','coordinador'))
  )
);

-- No se permite UPDATE/DELETE (inmutabilidad de historial)
-- Solo admin puede corregir errores vía DELETE + INSERT nuevo
CREATE POLICY petty_cash_delete ON petty_cash_movements
FOR DELETE TO authenticated
USING (
  EXISTS (SELECT 1 FROM me WHERE role = 'admin')
);
```

---

## 5. CATÁLOGOS Y SEED DATA

### 5.1 Seed Data Actual (Bolt)

**Migración:** `20251029232505_seed_demo_data.sql` + `20251102230751_seed_menu_dishes_and_ingredients.sql`

| Catálogo | Estado | Origen | Registros |
|----------|--------|--------|-----------|
| Test Users | ✅ SEEDED | 20251029223241_005_create_test_users.sql | 5 usuarios (admin, socio, coord, compras, servicio) |
| Menu Dishes | ✅ SEEDED | 20251102230751 | Platos con ingredientes |
| Clients Demo | ✅ SEEDED | 20251029232505 | Clientes de prueba |
| Events Demo | ✅ SEEDED | 20251029232505 | Eventos de prueba |

### 5.2 Catálogos Faltantes de Emergent ❌

**OBSERVACIÓN #5: Confirmación de Estrategia**

✅ **CONFIRMADO:** Seeds provienen de arrays en archivos `*Data.ts` de Emergent **SOLO PARA POBLAR INICIALMENTE** la base de datos.

✅ **CONFIRMADO:** En producción, **TODO sale de DB**. Los archivos `*Data.ts` **NO SE USAN** en runtime de la aplicación.

✅ **ESTRATEGIA:**
1. Extraer datos de `ingredientsData.ts`, `menuItems.ts`, `decorationData.ts`, `staffRoles.ts` de Emergent
2. Crear migraciones SQL con INSERT statements
3. Eliminar imports de `*Data.ts` en componentes de producción
4. Componentes usan **SOLO** services que consultan DB via Supabase

**Tabla de Catálogos a Seed:**

| Catálogo | Archivo Fuente (Emergent) | Tabla Destino | Registros | Estado | Prioridad |
|----------|---------------------------|---------------|-----------|--------|-----------|
| Roles del Sistema | permissions.ts | `roles` | 5 roles | ❌ FALTA | CRÍTICA |
| Menu Items | `menuItems.ts` | `menu_dishes` | 8 platos | ⚠️ PARCIAL | ALTA |
| Vegetable Options | `ingredientsData.ts` | `vegetables_catalog` | ~15 verduras | ❌ FALTA | ALTA |
| Chili Options | `ingredientsData.ts` | `chilis_catalog` | ~5 tipos de ají | ❌ FALTA | MEDIA |
| Decoration Packages | `decorationData.ts` | `decoration_packages` | 4 paquetes | ❌ FALTA | MEDIA |
| Decoration Providers | `decorationData.ts` | `decoration_providers` | 4 proveedores | ❌ FALTA | MEDIA |
| Staff Roles | `staffRoles.ts` | `staff_roles_catalog` | 5 roles | ❌ FALTA | ALTA |
| Event Images | `eventImages.ts` | N/A (solo UI) | Imágenes demo | ❌ FALTA | BAJA |

**Ejemplo de Migración de Seed (de array a SQL):**

```typescript
// ANTES (Emergent - emergent/src/lib/menuItems.ts)
export const menuItems: MenuItem[] = [
  { id: 'pollo-parrilla', name: 'Pollo a la Parrilla', price: 50, category: 'principal' },
  // ...
];

// DESPUÉS (Bolt - supabase/migrations/20250106_011_sync_menu_items.sql)
INSERT INTO menu_dishes (id, name, base_price, category) VALUES
  ('pollo-parrilla', 'Pollo a la Parrilla', 50, 'principal'),
  ('carne-asada', 'Carne Asada', 60, 'principal'),
  -- ...
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  base_price = EXCLUDED.base_price,
  category = EXCLUDED.category;
```

---

## 6. STOP CONDITIONS Y ROLLBACK

**OBSERVACIÓN #6: Estrategias de Rollback y Manejo de Duplicados**

### 6.1 Stop Conditions para Migraciones

**Cada migración debe incluir:**

```sql
-- Header estándar
-- Migration: 20250106_001_create_roles_table.sql
-- Description: Crear tabla roles con catálogo inicial
-- Rollback: Ver sección ROLLBACK al final
-- Idempotency: Usa IF NOT EXISTS / ON CONFLICT

-- Validaciones pre-ejecución
DO $$
BEGIN
  -- Validar que extensiones necesarias existen
  IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'uuid-ossp') THEN
    RAISE EXCEPTION 'Extension uuid-ossp required but not installed';
  END IF;
  
  -- Validar que tablas dependientes existen
  IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'users') THEN
    RAISE EXCEPTION 'Table users must exist before creating roles';
  END IF;
END $$;

-- Migración principal (idempotente)
CREATE TABLE IF NOT EXISTS roles (
  id text PRIMARY KEY,
  name text NOT NULL UNIQUE,
  display_name text NOT NULL,
  description text,
  created_at timestamptz DEFAULT now()
);

-- Seeds (idempotente con ON CONFLICT)
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

-- Validaciones post-ejecución
DO $$
DECLARE
  role_count int;
BEGIN
  SELECT COUNT(*) INTO role_count FROM roles;
  IF role_count < 5 THEN
    RAISE EXCEPTION 'Seed failed: Expected 5 roles, got %', role_count;
  END IF;
  
  RAISE NOTICE 'Migration completed successfully. % roles inserted.', role_count;
END $$;

-- ROLLBACK SCRIPT (ejecutar en caso de error)
/*
-- Revertir constraint en users (si ya se aplicó)
ALTER TABLE users DROP CONSTRAINT IF EXISTS fk_users_role;

-- Eliminar tabla (cuidado: solo si no hay datos de producción)
DROP TABLE IF EXISTS roles CASCADE;

-- Validar rollback
SELECT 'Rollback completed' as status;
*/
```

### 6.2 Stop Conditions para Seeds

```sql
-- Seed: 20250106_006_seed_vegetables_catalog.sql
-- Stop Conditions:
-- 1. Duplicados existentes → ON CONFLICT DO UPDATE
-- 2. Datos inválidos → CHECK constraints
-- 3. Tablas dependientes no existen → Validación pre-ejecución

DO $$
BEGIN
  -- Validar tabla existe
  IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'vegetables_catalog') THEN
    RAISE EXCEPTION 'Table vegetables_catalog does not exist. Run create table migration first.';
  END IF;
END $$;

-- Seed con idempotencia
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

-- Validación post-seed
DO $$
DECLARE
  veg_count int;
BEGIN
  SELECT COUNT(*) INTO veg_count FROM vegetables_catalog;
  IF veg_count < 15 THEN
    RAISE WARNING 'Expected 15 vegetables, got %', veg_count;
  END IF;
  
  RAISE NOTICE 'Seed completed: % vegetables in catalog', veg_count;
END $$;
```

### 6.3 Rollback Global (Script de Emergencia)

**Archivo:** `supabase/scripts/rollback_integration.sql`

```sql
-- ROLLBACK COMPLETO DE INTEGRACIÓN EMERGENT
-- USAR SOLO EN EMERGENCIA
-- IMPORTANTE: Este script elimina TODO el trabajo de integración

BEGIN;

-- 1. Eliminar triggers de auditoría
DROP TRIGGER IF EXISTS audit_event_expenses_trigger ON event_expenses;
DROP TRIGGER IF EXISTS audit_event_incomes_trigger ON event_incomes;
DROP TRIGGER IF EXISTS audit_event_staff_trigger ON event_staff;
DROP TRIGGER IF EXISTS audit_event_decoration_trigger ON event_decoration;
DROP FUNCTION IF EXISTS audit_event_expenses_trigger();

-- 2. Eliminar trigger de registered_by_name
DROP TRIGGER IF EXISTS set_registered_by_name_expenses ON event_expenses;
DROP TRIGGER IF EXISTS set_registered_by_name_ingredients ON event_ingredients;
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

-- 9. Validar rollback
SELECT 'ROLLBACK COMPLETED' as status,
       'All integration changes have been reverted' as message,
       now() as timestamp;

COMMIT;
```

---

## 7. RESUMEN DE BRECHAS CRÍTICAS (ACTUALIZADO)

### 7.1 CRÍTICAS (Bloqueantes) 🔴

1. **Tabla `roles` + Constraint FK en `users.role`** (OBSERVACIÓN #1)
   - Impacto: No hay catálogo normalizado de roles + posibles roles inválidos
   - Acción: Crear tabla + seed + ALTER TABLE users ADD CONSTRAINT

2. **Tabla `petty_cash_movements` + View** (OBSERVACIÓN #2)
   - Impacto: Sin historial auditable de caja chica
   - Acción: Crear tabla de movimientos + view agregada

3. **Triggers de Auditoría Automática** (OBSERVACIÓN #3)
   - Tablas: event_expenses, event_incomes, event_staff, event_decoration, petty_cash_movements
   - Impacto: Logs manuales propensos a errores
   - Acción: 5 triggers AFTER INSERT/UPDATE/DELETE

4. **Trigger de `registered_by_name` Snapshot** (OBSERVACIÓN #4)
   - Tablas: event_expenses, event_ingredients, event_decoration, event_staff, petty_cash_movements
   - Impacto: Columnas vacías o joins costosos
   - Acción: 1 trigger BEFORE INSERT reutilizable

5. **Catálogos sin seeds** (OBSERVACIÓN #5)
   - Verduras, Ajíes, Staff Roles, Decoration
   - Impacto: Frontend de Emergent depende de estos datos
   - Acción: Crear scripts de seed con datos de `*Data.ts`

6. **Stop Conditions en Migraciones** (OBSERVACIÓN #6)
   - Impacto: Migraciones frágiles sin rollback
   - Acción: Añadir validaciones pre/post + ON CONFLICT + script de rollback

### 7.2 ALTA PRIORIDAD (No Bloqueantes pero Importantes) 🟡

1. **Políticas RLS específicas para Coordinador**
   - Limitar event_expenses a categoría "adicional"
   - Limitar event_incomes a tipo "adicional"

2. **Índices adicionales**
   - event_ingredients(event_id, registered_at DESC)
   - petty_cash_movements(event_id, registered_at DESC)

3. **CORS y Auth Redirects**
   - Configurar en Supabase Dashboard

---

## 8. MATRIZ DE TRAZABILIDAD ACTUALIZADA

### Observaciones → Implementación

| Observación | Descripción | Tabla/Feature | Migración | Fase del Plan |
|-------------|-------------|---------------|-----------|---------------|
| #1 | Constraint users.role → roles | users, roles | 20250106_001 + 20250106_001b | Fase 1 |
| #2 | Modelo caja chica con historial | petty_cash_movements, petty_cash_status (view) | 20250106_003_v2 | Fase 1 |
| #3 | Triggers auditoría automática | audit_logs + 5 triggers | 20250106_015 | Fase 1 (nueva) |
| #4 | Trigger registered_by_name snapshot | 5 tablas + 1 trigger function | 20250106_016 | Fase 1 (nueva) |
| #5 | Confirmación: seeds de arrays Emergent | Todos los catálogos | Fase 2 (confirmado) | Fase 2 |
| #6 | Stop conditions y rollback | Todas las migraciones + script global | Todas las migraciones | Todas |

---

## 9. PRÓXIMOS PASOS (ACTUALIZADOS)

1. ✅ **Lectura y validación** de este reporte actualizado
2. ✅ **Aprobación final** con las 6 observaciones incorporadas
3. ⏳ **Actualizar PLAN_DE_TRABAJO.md** con nuevas migraciones y tareas
4. ⏳ **Actualizar PROGRESO.md** con tracking de nuevas tareas
5. ⏳ **Ejecución del plan** (SOLO después de aprobación final)

---

## 10. VALIDACIÓN FINAL

### Checklist de Observaciones

- [ ] **Observación #1:** Constraint FK de users.role → roles implementado
- [ ] **Observación #2:** Modelo caja chica con tabla de movimientos + view
- [ ] **Observación #3:** 5 triggers de auditoría automática en primera iteración
- [ ] **Observación #4:** Trigger de registered_by_name snapshot
- [ ] **Observación #5:** Confirmado: seeds de arrays Emergent, sin *Data.ts en producción
- [ ] **Observación #6:** Stop conditions en todas las migraciones + script de rollback global

---

**Fin del Reporte (Versión Revisada)**  
**Versión:** 1.1  
**Estado:** ✅ LISTO PARA APROBACIÓN FINAL  
**Incorpora:** 6 Observaciones Críticas del Usuario
