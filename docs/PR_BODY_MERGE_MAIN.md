# PR: Integración Emergent UI con Supabase (F1-F7)

## Resumen

Esta PR integra la UI existente de EventHub con backend Supabase completo, eliminando dependencias de mocks y localStorage, implementando autenticación real, RLS policies por rol, audit logs automáticos, y Storage para archivos.

**Branch:** `integracion-emergent-ui` → `main`
**Tipo:** Feature
**Breaking Changes:** Ninguno

## Cambios Principales

### ✅ F1-F2: Schema Base + RLS Policies + Auth
- Migraciones SQL completas (eventos, gastos, staff, decoración, storage)
- RLS policies por rol (admin, socio, coordinador, encargado_compras, servicio)
- Triggers automáticos: audit_logs, registered_by_name
- Supabase Auth email/password (sin magic links ni social)
- AuthContext integrado

### ✅ F3: Services Layer + React Query
- 11 services implementados (events, pettyCash, staff, decoration, storage, audit, auth, etc.)
- Hooks React Query con optimistic updates
- Cache management automático
- Error handling consistente

### ✅ F4: Storage + Deploy Config
- Buckets: `event-images`, `receipts` con RLS por rol
- Upload de imágenes en tab Decoración
- Upload de recibos en tab Gastos
- Docs de despliegue Vercel completos
- Seed UI bloqueado en prod (VITE_ENABLE_SEED)

### ✅ F6: EventoDetalle + Tabs Funcionales
- Página EventoDetalle con routing `/eventos/:id`
- Tab Gastos: CRUD con pettyCashService
- Tab Staff: CRUD con eventAssignmentsService
- Tab Decoración: catálogo + upload imágenes
- Role guards aplicados en cada tab

### ✅ F7: Vercel Config + Health Check
- `vercel.json` con SPA rewrites y security headers
- Endpoint `/health` sin auth (status, version, buildTime)
- CSP minimal permitiendo Supabase
- POST_DEPLOY_CHECKLIST.md con 13 categorías

### ✅ F8: Pre-merge QA
- Audit de mocks residuales (LEFTOVERS_MOCKS.md)
- SERVICE_MAP.md (servicios → métodos → componentes)
- ROLE_GUARDS_MATRIX.md (matriz completa de permisos)
- Limpieza de archivos obsoletos

## Archivos Clave

### Migraciones (Supabase)
```
supabase/migrations/
├── 20250106_000_schema_base.sql
├── 20250106_001_create_roles_table.sql
├── 20250106_002_add_registered_by_name.sql
├── 20250106_003_add_petty_cash_system.sql
├── 20250106_013_rls_complete_policies.sql
├── 20250106_015_audit_triggers.sql
└── 20250106_020_storage_buckets_and_policies.sql
```

### Services
```
src/services/
├── eventsService.ts
├── pettyCashService.ts
├── eventAssignmentsService.ts
├── decorationService.ts
├── storageService.ts
├── auditService.ts
└── auth.service.ts
```

### Componentes Principales
```
src/pages/
├── EventoDetalle.tsx (NEW)
├── Dashboard.tsx (integrado con useEvents)
├── Eventos.tsx (integrado con useEvents)
└── Health.tsx (NEW)

src/components/events/
├── GastosTab.tsx (NEW)
├── StaffTab.tsx (NEW)
└── DecoracionTab.tsx (NEW)
```

### Configuración
```
vercel.json (NEW)
.env.example (NEW)
docs/DEPLOY_VERCEL.md (NEW)
docs/POST_DEPLOY_CHECKLIST.md (NEW)
```

## Cómo Probar Localmente

### 1. Clonar y configurar
```bash
git clone <repo>
git checkout integracion-emergent-ui
cp .env.example .env
# Llenar .env con credenciales Supabase
npm install
```

### 2. Aplicar migraciones
```bash
# Desde Supabase Dashboard → SQL Editor
# Ejecutar en orden:
# 20250106_000_schema_base.sql
# 20250106_001_create_roles_table.sql
# ... (ver orden en DEPLOY_VERCEL.md)
```

### 3. Ejecutar localmente
```bash
npm run dev
# Abrir http://localhost:5173
```

### 4. Crear usuarios de prueba
```bash
# Registrar desde UI: /register
# Roles disponibles: admin, socio, coordinador, encargado_compras, servicio
```

### 5. Probar flujos por rol
- **Admin:** Crear evento → agregar gastos → asignar staff → subir imágenes
- **Encargado compras:** Crear/eliminar gastos con recibos
- **Coordinador:** Asignar/quitar staff de eventos
- **Servicio:** Solo lectura de eventos asignados

## Seguridad

✅ **Sin Secrets Expuestos:**
- `.env` en `.gitignore`
- Solo `anon key` en frontend
- `service_role key` NUNCA expuesto

✅ **RLS Aplicado:**
- Todas las tablas con datos tienen RLS enabled
- Policies verificadas por rol
- Storage con policies por bucket

✅ **Audit Logs:**
- Gastos: create/delete
- Staff: assign/unassign
- Triggers automáticos con user_id

✅ **Auth Real:**
- Supabase Auth sin mocks
- Passwords hasheados
- Sessions manejadas por Supabase

## Testing Post-Deploy

Ver `docs/POST_DEPLOY_CHECKLIST.md` para checklist completo:

1. Health check (`/health`)
2. Auth por rol
3. Eventos CRUD
4. Gastos con recibos
5. Staff assignments
6. Permisos RLS (servicio read-only)
7. Storage (images + receipts)
8. CSP/CORS sin errores
9. Seed bloqueado en prod

## Métricas

- **LOC añadidas:** ~10,000+
- **Services creados:** 11
- **Migraciones SQL:** 7
- **Componentes nuevos:** 8
- **Hooks React Query:** 20+
- **RLS Policies:** 30+
- **Build size:** 704KB (gzip: 205KB)
- **Bundle modules:** 1801

## Breaking Changes

**Ninguno** - Esta es una feature nueva que no modifica APIs existentes.

## Post-Merge

### Inmediato
1. Aplicar migraciones en Supabase production
2. Configurar variables de entorno en Vercel
3. Actualizar Redirect URLs en Supabase Auth
4. Ejecutar POST_DEPLOY_CHECKLIST.md

### Futuro (No bloqueante)
1. Migrar `decorationData.ts` a DB con CRUD UI
2. Implementar módulo completo de ingredientes
3. Agregar CRUD UI para staffService
4. Implementar clientsService completo

## Documentación

- ✅ `docs/DEPLOY_VERCEL.md` - Guía de despliegue
- ✅ `docs/POST_DEPLOY_CHECKLIST.md` - Checklist de verificación
- ✅ `docs/SERVICE_MAP.md` - Mapa de servicios y componentes
- ✅ `docs/ROLE_GUARDS_MATRIX.md` - Matriz de permisos
- ✅ `docs/LEFTOVERS_MOCKS.md` - Audit de mocks residuales
- ✅ `docs/PROGRESO.md` - Tracking de fases F1-F8

## Notas Finales

- Seed UI está deshabilitado por defecto (requiere `VITE_ENABLE_SEED=true`)
- Mocks residuales son provisionales y justificados (catálogos/helpers)
- Todas las páginas críticas usan servicios reales
- RLS garantiza seguridad incluso si UI tiene bugs

## Checklist de Merge

- [ ] Migraciones aplicadas en Supabase prod
- [ ] Vars de entorno configuradas en Vercel
- [ ] Redirect URLs actualizadas en Supabase
- [ ] Build exitoso en Vercel
- [ ] Health check responde 200
- [ ] Login funciona con roles reales
- [ ] POST_DEPLOY_CHECKLIST completado
- [ ] No hay secrets expuestos en código

---

**Reviewer:** Verificar que migraciones estén en orden correcto y que `.env` esté en `.gitignore`.
