# Supabase Setup - EventHub

Configuración completa de Supabase para EventHub incluyendo CORS, Authentication y Storage.

**Fecha:** 2025-01-06
**Fase:** F9 - Prep Deploy

## Proyecto Supabase

**URL del proyecto:** `https://tu-proyecto.supabase.co`
**Región:** Seleccionar la más cercana a tus usuarios

## 1. Aplicar Migraciones

Desde Supabase Dashboard → SQL Editor, ejecutar en orden:

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

**Verificación:**
- Ir a Database → Tables y confirmar que existen: `events`, `petty_cash`, `event_assignments`, etc.
- Ir a Storage y confirmar que existen buckets: `event-images`, `receipts`

## 2. Authentication Configuration

### URL Configuration

Ir a: **Authentication** → **URL Configuration**

#### Site URL
```
https://eventhub-production.vercel.app
```

#### Redirect URLs
Agregar las siguientes URLs (una por línea):

```
http://localhost:5173/**
https://eventhub-production.vercel.app/**
https://*.vercel.app/**
```

**Explicación:**
- `http://localhost:5173/**` - Para desarrollo local
- `https://eventhub-production.vercel.app/**` - Para producción
- `https://*.vercel.app/**` - Para preview deployments de Vercel

### Email Templates (Opcional)

Ir a: **Authentication** → **Email Templates**

Personalizar templates de:
- Confirm signup
- Reset password
- Change email

**Nota:** Por defecto, las confirmaciones de email están **deshabilitadas**. Si quieres habilitarlas:
1. Ir a **Authentication** → **Providers** → **Email**
2. Marcar "Confirm email"

## 3. API Settings

Ir a: **Settings** → **API**

### Obtener Credenciales

**Project URL:**
```
https://tu-proyecto.supabase.co
```
Copiar para `VITE_SUPABASE_URL`

**anon/public key:**
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```
Copiar para `VITE_SUPABASE_ANON_KEY`

⚠️ **IMPORTANTE:**
- Usar solo el `anon key` en frontend
- NUNCA exponer el `service_role key`
- El `service_role key` bypasses RLS - solo para backend trusted

### CORS Configuration

Ir a: **Settings** → **API** → **CORS**

**Allowed Origins:** (separar con comas)
```
http://localhost:5173,https://eventhub-production.vercel.app,https://*.vercel.app
```

**Explicación:**
- `http://localhost:5173` - Desarrollo local
- `https://eventhub-production.vercel.app` - Producción
- `https://*.vercel.app` - Preview deployments

**Additional headers:** (dejar por defecto)
```
Content-Type, Authorization, X-Client-Info, apikey
```

## 4. Storage Configuration

Ir a: **Storage** → Buckets

### Verificar Buckets

Deben existir los siguientes buckets (creados por migración):

#### event-images
- **Public:** No (privado)
- **File size limit:** 5 MB
- **Allowed MIME types:** `image/*`
- **RLS:** Habilitado

#### receipts
- **Public:** No (privado)
- **File size limit:** 10 MB
- **Allowed MIME types:** `image/*, application/pdf`
- **RLS:** Habilitado

### Verificar RLS Policies

En cada bucket, ir a **Policies** y verificar que existen:

**event-images:**
- Admin/Socio: Read/Write
- Coordinador: Read only
- Encargado Compras: Read only
- Servicio: Read only (eventos asignados)

**receipts:**
- Admin/Socio: Read/Write
- Encargado Compras: Read/Write
- Coordinador: Read only
- Servicio: Read only (eventos asignados)

## 5. Database Roles

Ir a: **Database** → **Roles**

Verificar que existe la tabla `roles` con los siguientes roles:

```sql
SELECT * FROM roles ORDER BY name;
```

Debe retornar:
- admin
- socio
- coordinador
- encargado_compras
- servicio

## 6. RLS Verification

### Verificar RLS Habilitado

Ir a: **Database** → **Tables** y verificar que RLS está habilitado en:

- ✅ events
- ✅ petty_cash
- ✅ event_assignments
- ✅ decoration_items
- ✅ user_profiles
- ✅ audit_logs
- ✅ staff
- ✅ staff_roles
- ✅ menu_items
- ✅ ingredients

### Test RLS Policies

Desde SQL Editor:

```sql
-- Como usuario anónimo (debe fallar)
SELECT * FROM events;

-- Como usuario autenticado con rol 'servicio' (debe ver solo eventos asignados)
-- Ejecutar después de crear usuarios de prueba
```

## 7. Crear Usuarios de Prueba

Desde la UI de la app (después del deploy):

1. Ir a `/register`
2. Crear usuarios con diferentes roles:

**Admin:**
```
Email: admin@eventhub.local
Password: Admin123!
Role: admin
```

**Socio:**
```
Email: socio@eventhub.local
Password: Socio123!
Role: socio
```

**Coordinador:**
```
Email: coord@eventhub.local
Password: Coord123!
Role: coordinador
```

**Encargado Compras:**
```
Email: compras@eventhub.local
Password: Compras123!
Role: encargado_compras
```

**Servicio:**
```
Email: servicio@eventhub.local
Password: Servicio123!
Role: servicio
```

## 8. Monitoreo

### Logs

Ir a: **Logs** → **Query Performance**

Monitorear queries lentas y optimizar índices si es necesario.

### Database Health

Ir a: **Database** → **Database**

Verificar:
- Conexiones activas
- Tamaño de la base de datos
- Uso de CPU/Memoria

### Storage Usage

Ir a: **Storage** → Buckets

Verificar tamaño de cada bucket y uso de cuota.

## 9. Backups (Opcional pero Recomendado)

Ir a: **Settings** → **Database** → **Backups**

Configurar:
- **Point-in-Time Recovery (PITR):** Habilitado (plan Pro+)
- **Daily Backups:** Habilitado
- **Retention:** 7 días mínimo

## 10. Security Checklist

- [ ] Migraciones aplicadas correctamente
- [ ] RLS habilitado en todas las tablas con datos
- [ ] Storage RLS policies configuradas
- [ ] CORS configurado con dominios correctos
- [ ] Redirect URLs incluyen localhost + producción + preview
- [ ] Solo `anon key` expuesto en frontend
- [ ] `service_role key` guardado de forma segura (nunca en código)
- [ ] Email confirmation configurado según necesidad
- [ ] Backups habilitados

## Troubleshooting

### Error: "Invalid API key"
- Verificar que `VITE_SUPABASE_ANON_KEY` sea correcto
- Confirmar que no hay espacios extra en el .env

### Error: "CORS policy blocked"
- Verificar que el dominio esté en Allowed Origins
- Confirmar que Redirect URLs incluyen el dominio

### Error: "Row Level Security policy violation"
- Verificar que el usuario tenga el rol correcto en `user_profiles`
- Confirmar que las policies permiten la acción
- Revisar logs de Supabase para detalles

### Storage uploads fallan
- Verificar que los buckets existen
- Confirmar que RLS policies permiten write
- Verificar tamaño del archivo contra límite del bucket

## Referencias

- [Supabase Auth Docs](https://supabase.com/docs/guides/auth)
- [RLS Policies Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [Storage Guide](https://supabase.com/docs/guides/storage)

---

**Última actualización:** 2025-01-06
**Versión:** 1.0.0
