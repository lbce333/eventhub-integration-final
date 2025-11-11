# Vercel Setup - EventHub

Configuración completa de despliegue en Vercel para EventHub.

**Fecha:** 2025-01-06
**Fase:** F9 - Prep Deploy

## 1. Crear Proyecto en Vercel

### Importar desde GitHub

1. Ir a [Vercel Dashboard](https://vercel.com/dashboard)
2. Click **Add New** → **Project**
3. Importar repositorio: `lbce333/eventhub-integration-emergent`
4. Seleccionar rama: `integracion-emergent-ui` (o `main` después del merge)

### Configure Project

**Framework Preset:** Vite
- Build Command: `npm run build`
- Output Directory: `dist`
- Install Command: `npm install`

Click **Deploy** (primer deploy fallará por falta de ENV vars, está OK)

## 2. Configurar Variables de Entorno

### Production Environment

Ir a: **Settings** → **Environment Variables**

Agregar las siguientes variables para **Production**:

| Key | Value | Ejemplo |
|-----|-------|---------|
| `VITE_SUPABASE_URL` | URL de tu proyecto Supabase | `https://abcdefgh.supabase.co` |
| `VITE_SUPABASE_ANON_KEY` | Anon key de Supabase | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` |
| `VITE_PUBLIC_SITE_URL` | URL de producción de Vercel | `https://eventhub-production.vercel.app` |

**NO definir:**
- ❌ `VITE_ENABLE_SEED` - Debe estar ausente para deshabilitar seed UI
- ❌ `VITE_SUPABASE_SERVICE_ROLE_KEY` - NUNCA exponer en frontend

### Preview Environment

Agregar las mismas variables para **Preview**:

⚠️ **IMPORTANTE:** Para `VITE_PUBLIC_SITE_URL` en Preview, usar:
```
https://*.vercel.app
```

Esto permite que preview deployments funcionen correctamente.

### Obtener Credenciales Supabase

Desde Supabase Dashboard → **Settings** → **API**:

1. **Project URL** → Copiar a `VITE_SUPABASE_URL`
2. **anon/public key** → Copiar a `VITE_SUPABASE_ANON_KEY`

## 3. Configurar Dominio Personalizado (Opcional)

### Agregar Dominio

1. Ir a **Settings** → **Domains**
2. Click **Add**
3. Ingresar dominio: `eventhub.tudominio.com`
4. Seguir instrucciones de DNS

### Configurar DNS

Agregar registro CNAME:
```
eventhub.tudominio.com → cname.vercel-dns.com
```

### Actualizar Variables

Después de configurar dominio:
1. Actualizar `VITE_PUBLIC_SITE_URL` a `https://eventhub.tudominio.com`
2. Agregar dominio en Supabase Redirect URLs
3. Agregar dominio en Supabase CORS

## 4. Deploy Settings

### Build & Development Settings

Ir a: **Settings** → **General**

**Build Command:** (dejar por defecto)
```bash
npm run build
```

**Output Directory:** (dejar por defecto)
```
dist
```

**Install Command:** (dejar por defecto)
```bash
npm install
```

**Node Version:** (recomendado)
```
18.x
```

### Root Directory

Si el proyecto no está en la raíz:
```
.
```
(Dejar vacío si está en la raíz)

## 5. Desplegar

### Desde Dashboard

1. Ir a **Deployments**
2. Click **Redeploy** (si ya existe un deploy)
3. Esperar build (1-3 minutos)

### Desde CLI (Opcional)

```bash
npm install -g vercel
vercel login
vercel --prod
```

## 6. Verificación Post-Deploy

### Health Check

```bash
curl https://eventhub-production.vercel.app/health
```

Debe retornar:
```json
{
  "status": "ok",
  "version": "0.0.0",
  "buildTime": "...",
  "commitHash": "...",
  "environment": "production"
}
```

### Login Test

1. Ir a `https://eventhub-production.vercel.app/login`
2. Intentar login con credenciales de prueba
3. Verificar que redirija a `/eventos` o `/dashboard`

### Checklist Completo

Ejecutar: `docs/POST_DEPLOY_CHECKLIST.md`

## 7. Configurar Notifications (Opcional)

### Slack Integration

1. Ir a **Settings** → **Integrations**
2. Buscar "Slack"
3. Connect y seleccionar canal
4. Recibe notificaciones de deploys

### Email Notifications

1. Ir a **Settings** → **Notifications**
2. Habilitar "Deployment Started/Completed/Failed"

## 8. Preview Deployments

### Configuración

Ir a: **Settings** → **Git**

**Production Branch:** `main`

**Preview Branches:** Habilitar para todas las ramas

Cada PR automáticamente crea preview deployment con URL:
```
https://eventhub-git-branch-name-username.vercel.app
```

### Variables en Preview

Las variables de **Preview** environment se usan en todos los preview deployments.

## 9. Logs y Monitoreo

### Function Logs

Ir a: **Deployment** → Click deployment → **Function Logs**

Ver errores de runtime y request logs.

### Analytics

Ir a: **Analytics**

Ver:
- Page views
- Top pages
- Visitors
- Performance metrics

### Real-Time Logs

```bash
vercel logs https://eventhub-production.vercel.app --follow
```

## 10. Rollback (Si algo sale mal)

### Desde Dashboard

1. Ir a **Deployments**
2. Encontrar deployment anterior estable
3. Click **⋯** → **Promote to Production**

### Desde CLI

```bash
vercel rollback
```

## 11. CI/CD Automático

### GitHub Integration

Vercel se integra automáticamente con GitHub:

**On Push to `main`:**
- Build automático
- Deploy a Production
- Notification en GitHub PR

**On PR:**
- Build preview
- Deploy preview URL
- Comment en PR con URL

### Manual Deploy

Deshabilitar auto-deploy:
1. Ir a **Settings** → **Git**
2. Deshabilitar "Automatic Deployments"

Luego deploy manual desde dashboard.

## 12. Environment Variables Best Practices

### Seguridad

- ✅ Solo `anon key` en frontend
- ❌ NUNCA `service_role key`
- ✅ Usar variables diferentes para prod/preview
- ✅ Rotar keys periódicamente

### Actualizar Variables

Cuando cambies una variable:
1. Actualizar en **Settings** → **Environment Variables**
2. Click **Redeploy** para aplicar cambios
3. NO es necesario rebuild, solo redeploy

## 13. Custom Headers (Configurado en vercel.json)

El proyecto ya incluye `vercel.json` con:

```json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "X-Frame-Options", "value": "DENY" },
        { "key": "X-Content-Type-Options", "value": "nosniff" },
        { "key": "Referrer-Policy", "value": "strict-origin-when-cross-origin" },
        { "key": "Content-Security-Policy", "value": "..." }
      ]
    }
  ]
}
```

No modificar estos headers sin revisar implicaciones de seguridad.

## 14. Troubleshooting

### Build Failed

**Error:** "Module not found"
- Verificar `package.json` dependencies
- Confirmar que `npm install` funciona localmente

**Error:** "Environment variable not found"
- Verificar que todas las ENV vars estén configuradas
- Confirmar que están en el environment correcto (Production/Preview)

### Runtime Errors

**Error:** "Invalid API key"
- Verificar `VITE_SUPABASE_ANON_KEY` en Vercel
- Confirmar que key es de Supabase correcto

**Error:** "CORS blocked"
- Verificar que dominio de Vercel está en Supabase CORS
- Confirmar Redirect URLs en Supabase Auth

### 404 on Direct URLs

Si `/eventos/123` da 404 pero funciona navegando:
- Verificar que `vercel.json` tiene rewrites SPA
- Confirmar que está committeado en repo

## 15. Performance Optimization

### Edge Network

Vercel despliega a edge locations automáticamente. No requiere configuración.

### Cache Headers

Assets en `/assets/*` tienen cache inmutable (configurado en `vercel.json`):
```
Cache-Control: public, max-age=31536000, immutable
```

### Bundle Analysis

Ver tamaño del bundle:
```bash
npm run build
# Ver dist/ folder size
```

Si bundle > 1MB, considerar code splitting.

## Checklist de Deploy

- [ ] Variables de entorno configuradas (Production + Preview)
- [ ] Primer deploy exitoso
- [ ] Health check responde 200
- [ ] Login funciona
- [ ] CORS sin errores
- [ ] Storage uploads funcionan
- [ ] RLS policies aplicadas
- [ ] Preview deployments habilitados
- [ ] Notifications configuradas (opcional)
- [ ] Dominio personalizado configurado (opcional)

## Referencias

- [Vercel Documentation](https://vercel.com/docs)
- [Environment Variables Guide](https://vercel.com/docs/concepts/projects/environment-variables)
- [Custom Domains](https://vercel.com/docs/concepts/projects/custom-domains)

---

**Última actualización:** 2025-01-06
**Versión:** 1.0.0
