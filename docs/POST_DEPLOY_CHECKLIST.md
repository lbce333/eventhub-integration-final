# Post-Deployment Checklist

Esta checklist debe completarse después de cada despliegue a producción o preview en Vercel para verificar que todas las funcionalidades críticas funcionan correctamente.

## Pre-requisitos

- [ ] Despliegue completado exitosamente en Vercel
- [ ] Variables de entorno configuradas correctamente
- [ ] Migraciones de Supabase aplicadas
- [ ] Storage buckets creados (`event-images`, `receipts`)
- [ ] Redirect URLs configuradas en Supabase Auth

## 1. Health Check

- [ ] Acceder a `/health` sin autenticación
- [ ] Verificar que responde con status 200
- [ ] Confirmar que el JSON incluye:
  - `status: "ok"`
  - `version`
  - `buildTime`
  - `commitHash`
  - `environment`

## 2. Autenticación por Rol

### Admin
- [ ] Registrar/Login como usuario admin
- [ ] Verificar acceso al Dashboard
- [ ] Verificar que puede ver todas las secciones
- [ ] Logout exitoso

### Socio
- [ ] Registrar/Login como usuario socio
- [ ] Verificar acceso completo similar a admin
- [ ] Logout exitoso

### Coordinador
- [ ] Registrar/Login como coordinador
- [ ] Verificar acceso al Dashboard
- [ ] Confirmar permisos limitados (sin finanzas completas)
- [ ] Logout exitoso

### Encargado de Compras
- [ ] Registrar/Login como encargado_compras
- [ ] Verificar que es redirigido a /eventos (no Dashboard)
- [ ] Confirmar acceso solo a gastos
- [ ] Logout exitoso

### Servicio
- [ ] Registrar/Login como usuario de servicio
- [ ] Verificar acceso de solo lectura
- [ ] Confirmar que no puede editar nada
- [ ] Logout exitoso

## 3. Funcionalidad de Eventos (Admin/Socio)

- [ ] Crear un nuevo evento
  - Nombre del cliente
  - Tipo de evento
  - Fecha
  - Número de invitados
  - Monto total
- [ ] Verificar que aparece en la lista de eventos
- [ ] Abrir el detalle del evento
- [ ] Editar el evento (cambiar monto, fecha, etc.)
- [ ] Verificar que los cambios se guardan correctamente

## 4. Gastos (Encargado de Compras)

- [ ] Login como encargado_compras
- [ ] Acceder a un evento
- [ ] Ir al tab "Gastos"
- [ ] Crear un nuevo gasto:
  - Descripción
  - Monto
  - Recibo (opcional - adjuntar archivo)
- [ ] Verificar que el gasto aparece en la lista
- [ ] Verificar el total de gastos se actualiza
- [ ] Eliminar el gasto
- [ ] Confirmar que se elimina correctamente

## 5. Asignación de Staff (Coordinador)

- [ ] Login como coordinador
- [ ] Acceder a un evento
- [ ] Ir al tab "Staff"
- [ ] Asignar un miembro del staff al evento (usar UUID real de un usuario)
- [ ] Verificar que aparece en la lista de staff asignado
- [ ] Remover el miembro del staff
- [ ] Confirmar que se elimina de la lista

## 6. Permisos y RLS (Usuario Servicio)

- [ ] Login como usuario servicio
- [ ] Asignar este usuario a un evento específico (usar admin)
- [ ] Acceder al evento asignado
- [ ] Verificar que puede VER el evento
- [ ] Tab "Gastos": Verificar que NO hay botones de crear/eliminar
- [ ] Tab "Staff": Verificar que NO hay botones de asignar/remover
- [ ] Tab "Decoración": Verificar que NO hay botón de subir imagen
- [ ] Intentar acceder a un evento NO asignado
- [ ] Confirmar que recibe error 403 o no lo ve en la lista

## 7. Storage (Event Images)

- [ ] Login como admin/socio
- [ ] Acceder a un evento
- [ ] Ir al tab "Decoración"
- [ ] Subir una imagen (formato: JPG, PNG)
- [ ] Verificar que la imagen aparece en el grid
- [ ] Confirmar que la imagen se descarga/visualiza correctamente
- [ ] Verificar que el archivo está en Supabase Storage bucket `event-images` bajo `events/{event_id}/`

## 8. Storage (Receipts)

- [ ] Login como encargado_compras
- [ ] Crear un gasto con recibo adjunto
- [ ] Verificar que el recibo se sube correctamente
- [ ] Confirmar que `receipt_url` se guarda en el registro del gasto
- [ ] Verificar que el archivo está en Supabase Storage bucket `receipts` bajo `receipts/{event_id}/`

## 9. Seguridad y Headers

### CSP y CORS
- [ ] Abrir DevTools → Console
- [ ] Navegar por toda la aplicación
- [ ] Confirmar que NO hay errores de CSP (Content Security Policy)
- [ ] Confirmar que NO hay errores de CORS
- [ ] Verificar que las llamadas a Supabase funcionan sin errores

### Headers de Seguridad
- [ ] Abrir DevTools → Network
- [ ] Inspeccionar cualquier request
- [ ] Verificar que los headers incluyen:
  - `X-Frame-Options: DENY`
  - `X-Content-Type-Options: nosniff`
  - `Referrer-Policy: strict-origin-when-cross-origin`
  - `Content-Security-Policy` (presente)

### Ruta Seed Bloqueada
- [ ] Intentar acceder a `/admin/seed`
- [ ] Confirmar que la ruta NO existe (404) o NO renderiza nada
- [ ] Verificar en Vercel Environment Variables que `VITE_ENABLE_SEED` NO está definida o es `false`

## 10. Audit Logs

- [ ] Login como admin
- [ ] Realizar varias acciones:
  - Crear evento
  - Crear gasto
  - Asignar staff
- [ ] (Si tienes acceso a Supabase) Verificar en la tabla `audit_logs` que los eventos se registran correctamente:
  - `entity_type` correcto
  - `action` correcto
  - `user_id` del usuario que realizó la acción
  - `metadata` con información relevante

## 11. Responsive Design

- [ ] Probar en desktop (1920x1080)
- [ ] Probar en tablet (768x1024)
- [ ] Probar en mobile (375x667)
- [ ] Verificar que:
  - El layout se adapta correctamente
  - Los botones son clickeables
  - El texto es legible
  - Las tablas/grids se ajustan

## 12. Performance

- [ ] Verificar tiempo de carga de la página principal < 3s
- [ ] Confirmar que las imágenes se cargan lazy
- [ ] Verificar que no hay memory leaks (usar Chrome DevTools Memory)
- [ ] Confirmar que las queries de Supabase son eficientes (< 500ms en promedio)

## 13. Error Handling

- [ ] Intentar crear un evento con datos inválidos
- [ ] Confirmar que aparecen mensajes de error claros
- [ ] Verificar que los errores NO exponen información sensible
- [ ] Probar desconectar internet y verificar mensajes de error apropiados

## Notas Post-Verificación

**Fecha de verificación**: _________________

**Verificado por**: _________________

**Versión desplegada**: _________________

**Commit hash**: _________________

**Issues encontrados**:
-
-
-

**Acciones requeridas**:
-
-
-

---

## Troubleshooting Común

### Error: "Invalid project ref"
- Verificar `VITE_SUPABASE_URL` en Vercel Environment Variables
- Confirmar que no tiene trailing slash

### Error: "CORS policy blocked"
- Verificar Redirect URLs en Supabase Auth
- Agregar dominio de Vercel a Allowed Origins

### Storage uploads fallan
- Confirmar que la migración de storage (`20250106_020_storage_buckets_and_policies.sql`) está aplicada
- Verificar que los buckets `event-images` y `receipts` existen en Supabase Storage
- Confirmar que las RLS policies de storage permiten acceso según el rol

### Usuario no puede ver/editar datos
- Verificar que el rol del usuario está correctamente asignado en `user_profiles.role`
- Confirmar que las RLS policies de la tabla correspondiente permiten el acceso
- Revisar logs de Supabase para ver errores de RLS

### /health no responde
- Verificar que `vercel.json` tiene la configuración de rewrites SPA
- Confirmar que el build de Vercel fue exitoso
- Revisar logs de Vercel Functions
