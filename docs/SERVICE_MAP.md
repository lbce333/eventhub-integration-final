# Service Map - EventHub Integration

Mapa completo de servicios, métodos y componentes que los consumen.

**Fecha:** 2025-01-06
**Fase:** F8 - Pre-merge QA

## Servicios Implementados

### 1. eventsService (`src/services/eventsService.ts`)

**Métodos:**
- `list()` - Lista todos los eventos (con RLS)
- `getById(id)` - Obtiene un evento específico
- `create(data)` - Crea un nuevo evento
- `update(id, data)` - Actualiza un evento
- `delete(id)` - Elimina un evento

**Usado en:**
- `src/hooks/useServiceData.ts` → `useEvents()`, `useEvent(id)`, `useCreateEventMutation()`, `useUpdateEventMutation()`, `useDeleteEventMutation()`
- `src/pages/Dashboard.tsx` → Métricas y listado
- `src/pages/Eventos.tsx` → Lista de eventos
- `src/pages/EventoDetalle.tsx` → Detalle del evento

---

### 2. pettyCashService (`src/services/pettyCashService.ts`)

**Métodos:**
- `list(eventId)` - Lista gastos de un evento
- `create(data)` - Crea un gasto (con audit log)
- `delete(id)` - Elimina un gasto (con audit log)

**Usado en:**
- `src/hooks/useServiceData.ts` → `usePettyCash(eventId)`, `useCreatePettyCashMutation()`, `useDeletePettyCashMutation()`
- `src/components/events/GastosTab.tsx` → CRUD de gastos

---

### 3. eventAssignmentsService (`src/services/eventAssignmentsService.ts`)

**Métodos:**
- `listEventStaff(eventId)` - Lista staff asignado a un evento
- `addStaffToEvent(eventId, userId)` - Asigna staff (con audit log)
- `removeStaffFromEvent(eventId, userId)` - Remueve staff (con audit log)

**Usado en:**
- `src/hooks/useServiceData.ts` → `useEventAssignments(eventId)`, `useAddStaffAssignmentMutation()`, `useRemoveStaffAssignmentMutation()`
- `src/components/events/StaffTab.tsx` → Asignación de personal

---

### 4. decorationService (`src/services/decorationService.ts`)

**Métodos:**
- `list()` - Lista catálogo de decoraciones

**Usado en:**
- `src/hooks/useServiceData.ts` → `useDecoration()`
- `src/components/events/DecoracionTab.tsx` → Catálogo de decoraciones

---

### 5. storageService (`src/services/storageService.ts`)

**Métodos:**
- `uploadEventImage(eventId, file)` - Sube imagen de evento
- `getEventImages(eventId)` - Lista imágenes del evento
- `deleteEventImage(eventId, fileName)` - Elimina imagen
- `uploadReceipt(eventId, file)` - Sube recibo
- `getReceipts(eventId)` - Lista recibos
- `deleteReceipt(eventId, fileName)` - Elimina recibo

**Usado en:**
- `src/components/events/DecoracionTab.tsx` → Upload de imágenes
- `src/components/events/GastosTab.tsx` → Upload de recibos

---

### 6. auditService (`src/services/auditService.ts`)

**Métodos:**
- `log(entityType, action, entityId, metadata)` - Registra evento de auditoría

**Usado en:**
- `src/services/pettyCashService.ts` → Logs de gastos (integrado en mutations)
- `src/services/eventAssignmentsService.ts` → Logs de staff (integrado en mutations)
- `src/hooks/useServiceData.ts` → Todas las mutations registran audit logs automáticamente

---

### 7. authService (`src/services/auth.service.ts`)

**Métodos:**
- `signUp(email, password, userData)` - Registro de usuario
- `signIn(email, password)` - Login
- `signOut()` - Logout
- `getCurrentUser()` - Obtiene usuario actual
- `updateProfile(updates)` - Actualiza perfil

**Usado en:**
- `src/contexts/AuthContext.tsx` → Gestión de autenticación
- `src/pages/Login.tsx` → Login
- `src/pages/Register.tsx` → Registro

---

### 8. staffService (`src/services/staffService.ts`)

**Métodos:**
- `list()` - Lista todos los staff
- `getById(id)` - Obtiene staff específico
- `create(data)` - Crea staff
- `update(id, data)` - Actualiza staff
- `delete(id)` - Elimina staff

**Estado:** Implementado pero no usado en UI actual

---

### 9. staffRolesService (`src/services/staffRolesService.ts`)

**Métodos:**
- `list()` - Lista roles de staff

**Estado:** Implementado pero no usado en UI actual

---

### 10. menuItemsService (`src/services/menuItemsService.ts`)

**Métodos:**
- `list()` - Lista items del menú

**Estado:** Implementado pero no usado en UI actual

---

### 11. ingredientsService (`src/services/ingredientsService.ts`)

**Métodos:**
- `list()` - Lista ingredientes

**Estado:** Implementado pero no usado en UI actual

---

## Hooks React Query (`src/hooks/useServiceData.ts`)

### Queries

| Hook | Service | Componente(s) que lo usa |
|------|---------|--------------------------|
| `useEvents()` | eventsService | Dashboard, Eventos |
| `useEvent(id)` | eventsService | EventoDetalle |
| `usePettyCash(eventId)` | pettyCashService | GastosTab |
| `useEventAssignments(eventId)` | eventAssignmentsService | StaffTab |
| `useDecoration()` | decorationService | DecoracionTab |
| `useStaff()` | staffService | (No usado aún) |
| `useStaffRoles()` | staffRolesService | (No usado aún) |
| `useMenuItems()` | menuItemsService | (No usado aún) |
| `useIngredients()` | ingredientsService | (No usado aún) |

### Mutations

| Hook | Service | Componente(s) que lo usa |
|------|---------|--------------------------|
| `useCreateEventMutation()` | eventsService | (Listo para usar) |
| `useUpdateEventMutation()` | eventsService | (Listo para usar) |
| `useDeleteEventMutation()` | eventsService | (Listo para usar) |
| `useCreatePettyCashMutation()` | pettyCashService | GastosTab |
| `useDeletePettyCashMutation()` | pettyCashService | GastosTab |
| `useAddStaffAssignmentMutation()` | eventAssignmentsService | StaffTab |
| `useRemoveStaffAssignmentMutation()` | eventAssignmentsService | StaffTab |

## Role Guards (`src/hooks/useRoleGuards.ts`)

**Métodos:**
- `hasFullAccess()` - admin, socio
- `canManageEvents()` - admin, socio, coordinador
- `canManageExpenses()` - admin, socio, encargado_compras
- `canManageStaffAssignments()` - admin, socio, coordinador
- `canViewOnly()` - servicio

**Usado en:**
- `src/pages/Dashboard.tsx` → Redirige servicio a /eventos
- `src/pages/EventoDetalle.tsx` → Determina readOnly mode
- `src/components/events/GastosTab.tsx` → Muestra/oculta botones de CRUD
- `src/components/events/StaffTab.tsx` → Muestra/oculta botones de CRUD
- `src/components/events/DecoracionTab.tsx` → Muestra/oculta botón upload

## Flujo de Datos

```
User Action
    ↓
Component (UI)
    ↓
Hook (useServiceData.ts)
    ↓
Service (eventsService, pettyCashService, etc.)
    ↓
Supabase (API + RLS)
    ↓
Database
    ↓
Triggers (audit_logs, registered_by_name)
```

## Servicios con Audit Logs Automáticos

Los siguientes services registran automáticamente audit logs:

1. **pettyCashService**
   - create → `expenses`, `create`
   - delete → `expenses`, `delete`

2. **eventAssignmentsService**
   - addStaffToEvent → `staff`, `assign`
   - removeStaffFromEvent → `staff`, `unassign`

## Optimistic Updates

Los siguientes hooks implementan optimistic updates:

- `useCreatePettyCashMutation()` - Agrega gasto al cache antes de confirmar
- `useDeletePettyCashMutation()` - Remueve gasto del cache antes de confirmar
- `useAddStaffAssignmentMutation()` - Agrega staff al cache antes de confirmar
- `useRemoveStaffAssignmentMutation()` - Remueve staff del cache antes de confirmar

## React Query Keys

```typescript
['events'] // Lista de todos los eventos
['event', id] // Evento específico
['pettyCash', eventId] // Gastos de un evento
['eventAssignments', eventId] // Staff asignado a un evento
['decoration'] // Catálogo de decoraciones
['staff'] // Lista de staff
['staffRoles'] // Roles de staff
['menuItems'] // Items del menú
['ingredients'] // Ingredientes
```

## Servicios No Implementados (Futuros)

Los siguientes servicios existen en código pero no tienen implementación completa:

1. **clientsService** - Gestión de clientes (solo stub)
2. **menuService** - Gestión de menús (solo stub)
3. **storageService** (parcial) - Falta implementar delete methods en UI

## Recomendaciones

### Inmediato
1. ✅ Todos los servicios críticos implementados y funcionando
2. ✅ Audit logs automáticos en mutations
3. ✅ Optimistic updates en operaciones frecuentes

### Post-merge
1. Implementar UI para staffService (CRUD completo)
2. Implementar UI para menuItemsService
3. Implementar UI para ingredientsService
4. Agregar delete methods en storageService UI
5. Implementar clientsService completo
