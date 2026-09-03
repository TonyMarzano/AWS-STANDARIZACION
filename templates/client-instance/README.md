# Cómo instanciar un cliente nuevo

1. Crear un repo **privado nuevo** (uno por cliente), ej. `lz-<nombre-cliente>`.
2. Copiar el contenido de esta carpeta (`templates/client-instance/`) como raíz de ese repo nuevo.
3. Renombrar/completar cada archivo a medida que se avanza por las etapas de [`docs/00-metodologia.md`](../../docs/00-metodologia.md) de este repo plantilla.
4. Este repo plantilla (`AWS-STANDARIZACION`) se puede agregar como submódulo o simplemente linkear por referencia — no es necesario duplicar los `docs/` en cada cliente, solo los archivos de esta carpeta.

## Contenido

| Archivo | Corresponde a | Se completa en |
|---|---|---|
| `00-intake.md` | Formulario de relevamiento | Etapa 1 |
| `01-cuentas-y-accesos.md` | Emails, Account IDs, dónde está guardado el acceso root | Etapa 1 |
| `02-baseline-checklist.md` | Evidencia de MFA/budgets/Organizations | Etapa 1 |
| `03-control-tower-checklist.md` | Evidencia del despliegue de Control Tower | Etapa 1 |
| `04-lza-config-notes.md` | Decisiones y valores usados en los YAML de LZA | Etapa 2 |
| `05-workloads-notes.md` | Decisiones de Terraform por carga de trabajo | Etapa 3 |
| `CHANGELOG.md` | Historial de cambios relevantes post go-live | Ongoing |

Al cerrar cada etapa, este conjunto de archivos (más la config real de LZA/Terraform en sus repos correspondientes) es la base del **entregable documental** para el cliente.
