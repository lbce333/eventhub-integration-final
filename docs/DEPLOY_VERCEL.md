# Despliegue en Vercel

Esta guía describe los pasos necesarios para desplegar EventHub en Vercel con integración completa de Supabase.

## Prerrequisitos

- Cuenta de Vercel activa
- Proyecto Supabase configurado con las migraciones aplicadas
- Repositorio Git con el código del proyecto

## Configuración de Variables de Entorno en Vercel

### 1. Acceder a la Configuración del Proyecto

1. Ir a tu proyecto en Vercel
2. Navegar a **Settings** → **Environment Variables**

### 2. Agregar las Variables Requeridas

Añade las siguientes variables de entorno para **Production** y **Preview**:

```
VITE_SUPABASE_URL=https://tu-proyecto.supabase.co
VITE_SUPABASE_ANON_KEY=tu-anon-key-aqui
VITE_PUBLIC_SITE_URL=https://tu-dominio.vercel.app
```

**NO definir `VITE_ENABLE_SEED`** en producción (o configurarlo explícitamente como `false`). La ruta `/admin/seed` solo está disponible cuando esta variable es `true`.

#### Donde obtener los valores:

- **VITE_SUPABASE_URL**: En Supabase Dashboard → Settings → API → Project URL
- **VITE_SUPABASE_ANON_KEY**: En Supabase Dashboard → Settings → API → Project API keys → `anon` `public`
- **VITE_PUBLIC_SITE_URL**: El dominio de tu proyecto en Vercel (ej: `https://eventhub.vercel.app`)

⚠️ **IMPORTANTE**:
- Usa el `anon key` (público), NO el `service_role key` (privado)
- Asegúrate de configurar estas variables tanto para **Production** como para **Preview**
- Para local development, copia `.env.example` a `.env` y llena los valores

## Configuración de Supabase

### 1. Configurar Redirect URLs en Supabase Auth

1. Ir a Supabase Dashboard → **Authentication** → **URL Configuration**
2. En **Site URL**, configurar:
   ```
   https://tu-dominio.vercel.app
   ```
3. En **Redirect URLs**, agregar:
   ```
   https://tu-dominio.vercel.app/**
   https://tu-dominio.vercel.app/login
   https://tu-dominio.vercel.app/register
   ```
4. Para deployments de preview de Vercel, agregar wildcard:
   ```
   https://*.vercel.app/**
   ```

### 2. Configurar CORS (Opcional)

Si experimentas problemas de CORS:

1. Ir a Supabase Dashboard → **Settings** → **API**
2. En **CORS Origins**, agregar:
   ```
   https://tu-dominio.vercel.app
   ```

## Despliegue

### Despliegue Automático

Vercel desplegará automáticamente:
- **Production**: Cuando se hace push a la rama `main`
- **Preview**: Cuando se hace push a otras ramas o se abre un PR

### Primer Despliegue Manual

1. Conectar tu repositorio Git a Vercel
2. Seleccionar el framework: **Vite**
3. Configurar las variables de entorno (ver arriba)
4. Click en **Deploy**

## Migraciones de Base de Datos

Las migraciones deben aplicarse manualmente en Supabase antes del despliegue:

```bash
# Si usas Supabase CLI local
supabase db push

# O aplicar manualmente desde Supabase Dashboard → SQL Editor
```

### Orden de Migraciones F3-F6:

1. `20250106_000_schema_base.sql` - Schema base
2. `20250106_001_create_roles_table.sql` - Tabla de roles
3. `20250106_002_add_registered_by_name.sql` - Triggers registered_by
4. `20250106_003_add_petty_cash_system.sql` - Sistema caja chica
5. `20250106_004_add_decoration_advance.sql` - Adelanto decoración
6. `20250106_005_add_performance_indexes.sql` - Índices
7. `20250106_013_rls_complete_policies.sql` - RLS policies
8. `20250106_015_audit_triggers.sql` - Audit logs
9. `20250106_020_storage_buckets_and_policies.sql` - Storage buckets (F4)

## Verificación Post-Despliegue

### 1. Verificar Variables de Entorno

Ir a Vercel → Settings → Environment Variables y confirmar que todas estén configuradas.

### 2. Probar Autenticación

1. Ir a `https://tu-dominio.vercel.app/register`
2. Crear una cuenta de prueba
3. Verificar que redirija correctamente después del login

### 3. Verificar RLS

- Probar acceso con diferentes roles: admin, socio, coordinador, encargado_compras, servicio
- Confirmar que solo se muestren las acciones permitidas por rol

### 4. Verificar Storage

- Intentar subir una imagen en el tab de Decoración
- Intentar subir un recibo en el tab de Gastos
- Confirmar que los archivos se almacenan correctamente en Supabase Storage

## Problemas Comunes

### Error: "Invalid project ref"

**Solución**: Verificar que `VITE_SUPABASE_URL` sea correcto y no incluya trailing slash.

### Error: "CORS policy blocked"

**Solución**:
1. Agregar el dominio de Vercel a CORS Origins en Supabase
2. Verificar que las Redirect URLs estén configuradas
3. Limpiar caché del browser y recargar

### Error: "Network request failed" en Storage

**Solución**:
1. Verificar que la migración de storage (`20250106_020_storage_buckets_and_policies.sql`) esté aplicada
2. Confirmar que los buckets `event-images` y `receipts` existan en Supabase Dashboard → Storage
3. Verificar que las RLS policies de storage estén activas

### Seed UI Visible en Producción

**Solución**: Confirmar que `VITE_ENABLE_SEED=false` esté configurado en Vercel.

## Build Commands

Vercel usa automáticamente:
- **Build Command**: `npm run build`
- **Output Directory**: `dist`
- **Install Command**: `npm install`

No necesitas modificar estos valores.

## Dominio Personalizado (Opcional)

1. Ir a Vercel → Settings → Domains
2. Agregar tu dominio personalizado
3. Seguir las instrucciones de DNS de Vercel
4. Actualizar `VITE_PUBLIC_SITE_URL` al nuevo dominio
5. Actualizar Redirect URLs en Supabase con el nuevo dominio

## Soporte

Para problemas:
1. Revisar los logs de build en Vercel
2. Revisar los logs de funciones en Vercel → Functions
3. Revisar los logs de Supabase en Dashboard → Logs

## Seguridad

⚠️ **Recordatorios de Seguridad**:
- NUNCA commitear el archivo `.env` con credenciales reales
- Usar solo `anon key` en variables de entorno de frontend
- Mantener `service_role key` solo en backend/server-side code
- Deshabilitar seed UI en producción (`VITE_ENABLE_SEED=false`)
- Revisar RLS policies periódicamente
