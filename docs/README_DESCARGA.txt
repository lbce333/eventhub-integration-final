================================================================================
  DOCUMENTOS DE PLANIFICACIÓN - INTEGRACIÓN EMERGENT UI EN BOLT
  Versión 1.1 - Actualizada con 6 Observaciones Críticas
================================================================================

UBICACIÓN DE ARCHIVOS:
  /tmp/cc-agent/59765837/project/docs/

ARCHIVOS DISPONIBLES:
  1. SCHEMA_PARITY_REPORT.md       (27 KB, 717 líneas)
  2. PLAN_DE_TRABAJO.md            (58 KB, 1601 líneas)
  3. PROGRESO.md                   (32 KB, 584 líneas)
  4. RESUMEN_ACTUALIZACION.md      (14 KB, 442 líneas)
  5. README_DESCARGA.txt           (este archivo)

TOTAL: 131 KB de documentación

================================================================================
CAMBIOS EN VERSIÓN 1.1
================================================================================

OBSERVACIONES INCORPORADAS:
  1. Constraint FK users.role → roles(id) + validación RLS
  2. Modelo caja chica con tabla movements + view agregada
  3. 5 triggers de auditoría automática (expenses, incomes, staff, etc.)
  4. Trigger snapshot registered_by_name (5 tablas)
  5. Confirmación: seeds de arrays, sin *Data.ts en runtime
  6. Stop conditions en todas las migraciones + rollback global

MÉTRICAS ACTUALIZADAS:
  - Tareas totales: 73 (antes 68) +5
  - Migraciones SQL: 14 (antes 11) +3
  - Triggers automáticos: 11 (antes 1) +10
  - Services: 6 (antes 5) +1 (pettyCashService)
  - Duración: 7-8 días (sin cambio)

================================================================================
RESUMEN EJECUTIVO
================================================================================

ESTADO: ✅ APROBADO PARA EJECUCIÓN

El plan integra toda la UI y lógica de dominio de Emergent en el proyecto
Bolt, reemplazando persistencia mock/localStorage por services TypeScript 
con Supabase.

CARACTERÍSTICAS PRINCIPALES:
  ✅ Integridad referencial (constraint FK users.role → roles)
  ✅ Historial completo auditable (caja chica + audit logs)
  ✅ Triggers automáticos (auditoría + snapshot nombres)
  ✅ RLS estricta por rol validada contra tabla roles
  ✅ Migraciones idempotentes con stop conditions
  ✅ Script de rollback global
  ✅ Seeds desde arrays Emergent, sin hardcoded data en runtime

FASES DEL PLAN:
  Fase 0: Preparación y configuración (2-3h)
  Fase 1: Paridad de base de datos (5-6h) - 9 migraciones + rollback
  Fase 2: Catálogos y seed data (4-5h) - 6 migraciones
  Fase 3: Ajustes RLS policies (2-3h) - 3 migraciones
  Fase 4: Services layer (6-8h) - 6 services
  Fase 5: Importación UI y lib (4-5h) - 30+ archivos
  Fase 6: Integración con services (6-8h) - 10 componentes
  Fase 7: React Query hooks (2-3h) - 6 hooks
  Fase 8: Autenticación y routing (3-4h)
  Fase 9: CORS, Storage, Deployment (2-3h)
  Fase 10: Testing y validación (4-5h) - 5 roles
  Fase 11: Documentación y PR (3-4h)

================================================================================
DOCUMENTOS DETALLADOS
================================================================================

1. SCHEMA_PARITY_REPORT.md
   - Análisis exhaustivo de brechas DB
   - Estado actual vs requerimientos Emergent
   - Tablas, columnas, índices, RLS policies
   - Triggers y automatización
   - Catálogos y seeds
   - Matriz de trazabilidad (Manual → Implementación)
   - Estrategias de rollback detalladas

2. PLAN_DE_TRABAJO.md
   - 11 fases con 73 tareas numeradas
   - Cada tarea con criterios de aceptación
   - Ejemplos SQL completos de migraciones
   - Código TypeScript de services
   - Estructura de componentes a adaptar
   - Comandos git y commits esperados
   - Matriz de trazabilidad completa

3. PROGRESO.md
   - Tracking operativo de ejecución
   - Tablas de progreso por fase
   - Estado de cada tarea (TODO/DOING/DONE/BLOCKED)
   - Métricas de avance (0/73 tareas = 0%)
   - Registro de bloqueos y riesgos
   - Checklist de aprobaciones
   - Changelog del documento

4. RESUMEN_ACTUALIZACION.md
   - Resumen ejecutivo de cambios v1.1
   - Detalle de cada una de las 6 observaciones
   - Impacto por fase y métricas actualizadas
   - Tabla de riesgos mitigados
   - Checklist de aprobación final
   - Próximos pasos inmediatos

================================================================================
USO DE LOS DOCUMENTOS
================================================================================

PARA PRODUCT OWNER:
  - Leer: RESUMEN_ACTUALIZACION.md (visión general)
  - Revisar: SCHEMA_PARITY_REPORT.md (secciones 1, 7, 8, 13)
  - Aprobar: Checklist final en PROGRESO.md

PARA TECH LEAD:
  - Leer: PLAN_DE_TRABAJO.md completo (arquitectura técnica)
  - Validar: Migraciones SQL en Fase 1 (stop conditions)
  - Revisar: Services en Fase 4 (contratos y diseño)

PARA DESARROLLADOR:
  - Usar: PROGRESO.md como checklist de ejecución
  - Seguir: PLAN_DE_TRABAJO.md paso a paso
  - Consultar: SCHEMA_PARITY_REPORT.md para contexto DB

PARA QA/TESTER:
  - Revisar: Fase 10 en PLAN_DE_TRABAJO.md (smoke tests)
  - Validar: Criterios de aceptación en cada tarea
  - Documentar: Resultados en docs/SMOKE_TESTS_RESULTS.md

================================================================================
PRÓXIMOS PASOS
================================================================================

1. INMEDIATO (Hoy):
   ✅ Descargar los 4 documentos
   ✅ Revisar RESUMEN_ACTUALIZACION.md
   ⏳ Dar aprobación final
   ⏳ Cambiar a modo "Build" en Claude Code

2. FASE 0 (Día 1 - Mañana):
   ⏳ Crear rama integracion-emergent-ui
   ⏳ Actualizar .env.local
   ⏳ Verificar instancia Supabase
   ⏳ Instalar dependencias

3. FASE 1 (Día 1 - Tarde):
   ⏳ Ejecutar 9 migraciones SQL
   ⏳ Crear script rollback
   ⏳ Validar con queries de prueba
   ⏳ Commit incremental

================================================================================
SOPORTE Y CONTACTO
================================================================================

DOCUMENTACIÓN FUENTE:
  - Emergent Manuales: docs/emergent/*.md
  - Bolt DB Schema: supabase/migrations/*.sql
  - Checklists: docs/checklists/*.md

REFERENCIAS:
  - Repo Base (Bolt): github.com/mce333/eventhub-production
  - Repo UI (Emergent): github.com/mce333/export-ui-only

SUPABASE INSTANCE:
  - URL: https://tvpaanmxhjhwljjfsuvd.supabase.co
  - Anon Key: (ver .env.local después de configuración)

================================================================================
NOTAS IMPORTANTES
================================================================================

⚠️ STOP CONDITIONS:
  - Detener si service_role en frontend
  - Detener si RLS deshabilitado sin justificación
  - Detener si conflicto de migraciones
  - Detener si environment variables incorrectas

✅ VALIDACIONES:
  - Todas las migraciones tienen validaciones pre/post
  - Todas las migraciones son idempotentes (ON CONFLICT)
  - Script de rollback global disponible
  - Cero imports de *Data.ts en producción

🔒 SEGURIDAD:
  - RLS estricta en todas las tablas
  - Constraint FK valida roles contra catálogo
  - Triggers de auditoría automática
  - Snapshot de nombres para inmutabilidad

================================================================================
FIN DEL README DE DESCARGA
================================================================================

Versión: 1.1
Fecha: 2025-01-06
Estado: ✅ APROBADO PARA EJECUCIÓN
Autor: Claude Code
