# Role Guards Matrix - EventHub

Matriz completa de permisos por rol y acción en todos los componentes.

**Fecha:** 2025-01-06
**Fase:** F8 - Pre-merge QA

## Roles del Sistema

| Rol | Código | Descripción |
|-----|--------|-------------|
| **Admin** | `admin` | Acceso completo al sistema |
| **Socio** | `socio` | Acceso completo al sistema (equivalente a admin) |
| **Coordinador** | `coordinador` | Gestión de staff y eventos, lectura de finanzas |
| **Encargado de Compras** | `encargado_compras` | Gestión de gastos y compras |
| **Servicio** | `servicio` | Solo lectura de eventos asignados |

## Guards Implementados

### `useRoleGuards` Hook

| Guard | Admin | Socio | Coordinador | Encargado Compras | Servicio |
|-------|-------|-------|-------------|-------------------|----------|
| `hasFullAccess()` | ✅ | ✅ | 🚫 | 🚫 | 🚫 |
| `canManageEvents()` | ✅ | ✅ | ✅ | 🚫 | 🚫 |
| `canManageExpenses()` | ✅ | ✅ | 🚫 | ✅ | 🚫 |
| `canManageStaffAssignments()` | ✅ | ✅ | ✅ | 🚫 | 🚫 |
| `canViewOnly()` | 🚫 | 🚫 | 🚫 | 🚫 | ✅ |

## Matriz de Permisos por Página

### Dashboard (`src/pages/Dashboard.tsx`)

| Acción | Admin | Socio | Coordinador | Encargado Compras | Servicio |
|--------|-------|-------|-------------|-------------------|----------|
| Acceder | ✅ | ✅ | ✅ | 🚫 (redirect→eventos) | 🚫 (redirect→eventos) |
| Ver métricas | ✅ | ✅ | ✅ | - | - |
| Ver calendario | ✅ | ✅ | ✅ | - | - |

### Eventos - Lista (`src/pages/Eventos.tsx`)

| Acción | Admin | Socio | Coordinador | Encargado Compras | Servicio |
|--------|-------|-------|-------------|-------------------|----------|
| Acceder | ✅ | ✅ | ✅ | ✅ | ✅ |
| Ver lista | ✅ | ✅ | ✅ | ✅ | ✅ (solo asignados - RLS) |
| Crear evento | ✅ | ✅ | ✅ | 🚫 | 🚫 |
| Editar evento | ✅ | ✅ | ✅ | 🚫 | 🚫 |
| Eliminar evento | ✅ | ✅ | 🚫 | 🚫 | 🚫 |

### Evento Detalle (`src/pages/EventoDetalle.tsx`)

| Acción | Admin | Socio | Coordinador | Encargado Compras | Servicio |
|--------|-------|-------|-------------|-------------------|----------|
| Acceder | ✅ | ✅ | ✅ | ✅ | ✅ (solo asignados - RLS) |
| Ver información | ✅ | ✅ | ✅ | ✅ | ✅ |
| Tabs disponibles | Todos | Todos | Todos | Todos | Todos (read-only) |

## Matriz de Permisos por Tab

### Tab: Gastos (`src/components/events/GastosTab.tsx`)

| Acción | Admin | Socio | Coordinador | Encargado Compras | Servicio |
|--------|-------|-------|-------------|-------------------|----------|
| Ver lista gastos | ✅ | ✅ | ✅ | ✅ | ✅ |
| Ver total | ✅ | ✅ | ✅ | ✅ | ✅ |
| Crear gasto | ✅ | ✅ | 🚫 | ✅ | 🚫 |
| Subir recibo | ✅ | ✅ | 🚫 | ✅ | 🚫 |
| Eliminar gasto | ✅ | ✅ | 🚫 | ✅ | 🚫 |

**Guard usado:** `canManageExpenses() && !readOnly`

### Tab: Staff (`src/components/events/StaffTab.tsx`)

| Acción | Admin | Socio | Coordinador | Encargado Compras | Servicio |
|--------|-------|-------|-------------|-------------------|----------|
| Ver lista staff | ✅ | ✅ | ✅ | ✅ | ✅ |
| Ver total asignados | ✅ | ✅ | ✅ | ✅ | ✅ |
| Asignar staff | ✅ | ✅ | ✅ | 🚫 | 🚫 |
| Remover staff | ✅ | ✅ | ✅ | 🚫 | 🚫 |

**Guard usado:** `canManageStaffAssignments() && !readOnly`

### Tab: Decoración (`src/components/events/DecoracionTab.tsx`)

| Acción | Admin | Socio | Coordinador | Encargado Compras | Servicio |
|--------|-------|-------|-------------|-------------------|----------|
| Ver catálogo | ✅ | ✅ | ✅ | ✅ | ✅ |
| Ver imágenes | ✅ | ✅ | ✅ | ✅ | ✅ |
| Subir imagen | ✅ | ✅ | 🚫 | 🚫 | 🚫 |
| Eliminar imagen | ✅ | ✅ | 🚫 | 🚫 | 🚫 |

**Guard usado:** `hasFullAccess() && !readOnly`

## Permisos de Storage (RLS)

### Bucket: `event-images`

| Acción | Admin | Socio | Coordinador | Encargado Compras | Servicio |
|--------|-------|-------|-------------|-------------------|----------|
| Read | ✅ | ✅ | ✅ | ✅ | ✅ (solo eventos asignados) |
| Write | ✅ | ✅ | 🚫 | 🚫 | 🚫 |
| Delete | ✅ | ✅ | 🚫 | 🚫 | 🚫 |

### Bucket: `receipts`

| Acción | Admin | Socio | Coordinador | Encargado Compras | Servicio |
|--------|-------|-------|-------------|-------------------|----------|
| Read | ✅ | ✅ | ✅ | ✅ | ✅ (solo eventos asignados) |
| Write | ✅ | ✅ | 🚫 | ✅ | 🚫 |
| Delete | ✅ | ✅ | 🚫 | ✅ | 🚫 |

## Permisos de Base de Datos (RLS Policies)

### Tabla: `events`

| Acción | Admin | Socio | Coordinador | Encargado Compras | Servicio |
|--------|-------|-------|-------------|-------------------|----------|
| SELECT | ✅ (todos) | ✅ (todos) | ✅ (todos) | ✅ (todos) | ✅ (solo asignados) |
| INSERT | ✅ | ✅ | ✅ | 🚫 | 🚫 |
| UPDATE | ✅ | ✅ | ✅ | 🚫 | 🚫 |
| DELETE | ✅ | ✅ | 🚫 | 🚫 | 🚫 |

### Tabla: `petty_cash`

| Acción | Admin | Socio | Coordinador | Encargado Compras | Servicio |
|--------|-------|-------|-------------|-------------------|----------|
| SELECT | ✅ (todos) | ✅ (todos) | ✅ (todos) | ✅ (todos) | ✅ (solo eventos asignados) |
| INSERT | ✅ | ✅ | 🚫 | ✅ | 🚫 |
| UPDATE | ✅ | ✅ | 🚫 | ✅ | 🚫 |
| DELETE | ✅ | ✅ | 🚫 | ✅ | 🚫 |

### Tabla: `event_assignments`

| Acción | Admin | Socio | Coordinador | Encargado Compras | Servicio |
|--------|-------|-------|-------------|-------------------|----------|
| SELECT | ✅ (todos) | ✅ (todos) | ✅ (todos) | ✅ (todos) | ✅ (solo propios) |
| INSERT | ✅ | ✅ | ✅ | 🚫 | 🚫 |
| UPDATE | ✅ | ✅ | ✅ | 🚫 | 🚫 |
| DELETE | ✅ | ✅ | ✅ | 🚫 | 🚫 |

### Tabla: `decoration_items`

| Acción | Admin | Socio | Coordinador | Encargado Compras | Servicio |
|--------|-------|-------|-------------|-------------------|----------|
| SELECT | ✅ | ✅ | ✅ | ✅ | ✅ |
| INSERT | ✅ | ✅ | 🚫 | 🚫 | 🚫 |
| UPDATE | ✅ | ✅ | 🚫 | 🚫 | 🚫 |
| DELETE | ✅ | ✅ | 🚫 | 🚫 | 🚫 |

## Rutas Protegidas

### Routing

| Ruta | Admin | Socio | Coordinador | Encargado Compras | Servicio |
|------|-------|-------|-------------|-------------------|----------|
| `/dashboard` | ✅ | ✅ | ✅ | 🚫 (redirect) | 🚫 (redirect) |
| `/eventos` | ✅ | ✅ | ✅ | ✅ | ✅ |
| `/eventos/:id` | ✅ | ✅ | ✅ | ✅ | ✅ (RLS aplica) |
| `/finanzas` | ✅ | ✅ | ✅ | ✅ | ✅ |
| `/configuracion` | ✅ | ✅ | ✅ | ✅ | ✅ |
| `/health` | ✅ (sin auth) | ✅ (sin auth) | ✅ (sin auth) | ✅ (sin auth) | ✅ (sin auth) |
| `/admin/seed` | ✅ (solo VITE_ENABLE_SEED=true) | ✅ (solo VITE_ENABLE_SEED=true) | ✅ (solo VITE_ENABLE_SEED=true) | ✅ (solo VITE_ENABLE_SEED=true) | ✅ (solo VITE_ENABLE_SEED=true) |

## Flujo de Autorización

```
1. Usuario se autentica → Supabase Auth
2. AuthContext carga user_profile con role
3. useRoleGuards() determina permisos frontend
4. RLS policies verifican permisos backend
5. Audit logs registran acciones críticas
```

## Verificación de Permisos

### Frontend (UI)
- **Componentes:** Usan `useRoleGuards()` para mostrar/ocultar botones
- **Páginas:** Redirigen según rol en `useEffect()`
- **Guards:** Determinan si botones están enabled/disabled

### Backend (Database)
- **RLS Policies:** Verifican permisos a nivel de query
- **Triggers:** Audit logs automáticos en cambios críticos
- **Views:** `auth.me()` view expone user profile con rol

## Testing de Permisos (Post-Deploy Checklist)

Ver `docs/POST_DEPLOY_CHECKLIST.md` para testing exhaustivo de:

1. Autenticación por cada rol
2. Acceso a páginas
3. Visibilidad de botones
4. Operaciones CRUD
5. Storage uploads
6. RLS en queries

## Resumen de Seguridad

✅ **Frontend Guards:** Implementados en todos los componentes críticos
✅ **RLS Policies:** Aplicadas en todas las tablas con datos
✅ **Storage Policies:** Configuradas por rol en ambos buckets
✅ **Audit Logs:** Automáticos en mutations críticas
✅ **Auth Real:** Supabase Auth sin mocks
✅ **Seed Bloqueado:** Solo disponible con VITE_ENABLE_SEED=true

## Notas Importantes

1. **Servicio rol** tiene acceso de solo lectura a:
   - Eventos a los que está asignado
   - Gastos de esos eventos
   - Staff de esos eventos
   - Imágenes y recibos de esos eventos

2. **RLS es la última línea de defensa:**
   - Aunque UI oculte botones, RLS previene acciones no autorizadas
   - Frontend guards mejoran UX, RLS garantiza seguridad

3. **Admin y Socio son equivalentes:**
   - Ambos tienen acceso completo
   - Diferenciación solo para auditoría

4. **Coordinador vs Encargado de Compras:**
   - Coordinador: Staff + Eventos
   - Encargado: Gastos + Compras
   - Roles complementarios sin overlap de permisos críticos
