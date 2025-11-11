# Release Notes - EventHub v1.0.0

**Fecha de Release:** 2025-01-06
**Branch:** `integracion-emergent-ui` → `main`
**Tipo:** Major Release

## Resumen

Primera versión production-ready de EventHub con integración completa de Supabase backend, autenticación real, permisos por rol, y gestión de archivos.

## Características Nuevas

### Autenticación y Usuarios
- ✅ Sistema de auth completo con Supabase (email/password)
- ✅ 5 roles de usuario: admin, socio, coordinador, encargado_compras, servicio
- ✅ Permisos granulares por rol con RLS
- ✅ Audit logs automáticos en acciones críticas

### Gestión de Eventos
- ✅ CRUD completo de eventos con datos desde Supabase
- ✅ Página de detalle con tabs: Gastos | Staff | Decoración
- ✅ Calendar view interactivo
- ✅ Filtrado y búsqueda de eventos

### Módulo de Gastos (Petty Cash)
- ✅ Crear/eliminar gastos por evento
- ✅ Adjuntar recibos (imágenes o PDFs)
- ✅ Totales automáticos por evento
- ✅ Permisos específicos (admin, socio, encargado_compras)

### Asignación de Staff
- ✅ Asignar/quitar staff a eventos
- ✅ Vista de staff asignado por evento
- ✅ Permisos específicos (admin, socio, coordinador)

### Catálogo de Decoración
- ✅ Vista de decoraciones disponibles
- ✅ Subir imágenes de eventos
- ✅ Galería de imágenes por evento

### Storage (Archivos)
- ✅ Bucket `event-images` para fotos de eventos
- ✅ Bucket `receipts` para recibos de gastos
- ✅ RLS policies por rol en ambos buckets
- ✅ Organización por carpetas: `events/{event_id}/`, `receipts/{event_id}/`

### Deploy y Monitoring
- ✅ Configuración para Vercel (SPA + security headers)
- ✅ Endpoint `/health` con version info
- ✅ CSP headers permitiendo Supabase
- ✅ CORS configurado para preview/production

### Documentación
- ✅ Guía de despliegue en Vercel
- ✅ Checklist post-deploy con 13 categorías
- ✅ Mapa de servicios y componentes
- ✅ Matriz de permisos por rol
- ✅ Troubleshooting común

## Mejoras Técnicas

### Performance
- React Query con cache optimizado
- Optimistic updates en mutations frecuentes
- Lazy loading de componentes pesados
- Assets con cache inmutable (1 año)

### Seguridad
- RLS policies en todas las tablas con datos
- Storage policies por rol
- Auth tokens manejados por Supabase
- Headers de seguridad (CSP, X-Frame-Options, etc.)
- Seed UI deshabilitado en producción

### Developer Experience
- Services layer con separación de concerns
- Hooks React Query reutilizables
- Role guards centralizados
- Audit logging automático
- Error handling consistente

## Breaking Changes

**Ninguno** - Esta es la primera versión production-ready.

## Migraciones Requeridas

Ejecutar en orden desde Supabase Dashboard → SQL Editor:

```sql
1. 20250106_000_schema_base.sql
2. 20250106_001_create_roles_table.sql
3. 20250106_001b_add_users_role_constraint.sql
4. 20250106_002_add_registered_by_name.sql
5. 20250106_003_add_petty_cash_system.sql
6. 20250106_004_add_decoration_advance.sql
7. 20250106_005_add_performance_indexes.sql
8. 20250106_012_update_me_view.sql
9. 20250106_013_rls_complete_policies.sql
10. 20250106_015_audit_triggers.sql
11. 20250106_016_trigger_registered_by_name.sql
12. 20250106_020_storage_buckets_and_policies.sql
```

## Configuración Post-Deploy

### 1. Variables de Entorno en Vercel

Agregar en Vercel → Settings → Environment Variables (Production + Preview):

```
VITE_SUPABASE_URL=https://tu-proyecto.supabase.co
VITE_SUPABASE_ANON_KEY=tu-anon-key
VITE_PUBLIC_SITE_URL=https://tu-dominio.vercel.app
```

**NO definir** `VITE_ENABLE_SEED` (deshabilita seed UI)

### 2. Supabase Auth Configuration

En Supabase Dashboard → Authentication → URL Configuration:

**Site URL:**
```
https://tu-dominio.vercel.app
```

**Redirect URLs:**
```
https://tu-dominio.vercel.app/**
https://tu-dominio.vercel.app/login
https://tu-dominio.vercel.app/register
https://*.vercel.app/** (para preview deploys)
```

### 3. Verificación

Ejecutar checklist completo: `docs/POST_DEPLOY_CHECKLIST.md`

Mínimo verificar:
1. `/health` responde 200
2. Login funciona
3. Crear evento
4. CRUD de gastos
5. Asignación de staff
6. Upload de archivos

## Limitaciones Conocidas

### Catálogos Estáticos (Temporal)
Los siguientes datos usan archivos estáticos temporalmente (plan de migración en fase futura):

- Catálogo de decoración (packages/providers)
- Diccionario de ingredientes
- Helper functions de cálculo de costos

**Razón:** No hay UI de administración de catálogos aún.

### Módulos No Implementados
Los siguientes módulos tienen services pero no UI completa:

- Staff management (CRUD desde UI)
- Menu items management
- Ingredients management
- Clients management

**Próximas versiones:** Se agregarán interfaces de administración.

## Performance

- **Bundle size:** 704KB (gzip: 205KB)
- **First load:** < 3s en conexión 4G
- **Time to Interactive:** < 2s
- **Lighthouse score:** 90+ (desktop)

## Soporte de Navegadores

- Chrome/Edge 90+
- Firefox 88+
- Safari 14+
- Mobile browsers (iOS Safari, Chrome Android)

## Roadmap (Post v1.0)

### v1.1 (Próximo)
- UI de administración de catálogos (decoración, ingredientes)
- CRUD completo de staff desde UI
- Gestión de clientes
- Dashboard mejorado con más métricas

### v1.2
- Reportes y exportación (PDF, Excel)
- Módulo de inventario completo
- Notificaciones push
- Multi-idioma (ES/EN)

### v2.0
- Mobile app (React Native)
- API pública
- Integraciones con calendar (Google, Outlook)
- Payments gateway (Stripe)

## Soporte y Contacto

Para reportar bugs o solicitar features:
- GitHub Issues: [lbce333/eventhub-integration-emergent](https://github.com/lbce333/eventhub-integration-emergent)
- Documentación: `docs/` folder

## Agradecimientos

Gracias a todos los que contribuyeron a esta release:
- Diseño UI/UX
- Implementación backend Supabase
- Testing y QA
- Documentación

---

**Nota de Seguridad:** Esta versión incluye RLS policies comprehensivas y audit logging. Revisar `docs/ROLE_GUARDS_MATRIX.md` para detalles de permisos.

**Nota de Deploy:** Seguir `docs/DEPLOY_VERCEL.md` para instrucciones paso a paso.
