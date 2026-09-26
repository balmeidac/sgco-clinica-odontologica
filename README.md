# SGCO — Sistema de Gestión de Clínica Odontológica

**Relational database design and implementation project (PostgreSQL) for a mid-sized dental clinic.**
University coursework — *Fundamentos de Bases de Datos Relacionales*, Universidad Técnica Estatal de Quevedo (UTEQ), Ecuador.

---

## 🇬🇧 English Summary

**Role:** Technical Lead / Database Architect (group project, 4 members)

I led the design and implementation of a relational database for a fictional mid-sized dental clinic in Guayaquil, Ecuador, managing patients, appointments, treatments, billing, payments, inventory and customer complaints.

**What I did:**
- Designed a **27-table relational schema**, normalized up to Third Normal Form (3NF), covering clinical, financial and inventory modules.
- Modeled complex relationships, including an **N:N relationship** for patient allergy tracking (`historial_alergia`) and a **polymorphic invoice-line design** (`detalle_factura`) constrained with a `CHECK` clause so each line references *either* a clinical treatment *or* a product/service — never both.
- Added **Ecuadorian electronic-invoicing (SRI) fields** to the billing module to reflect real local tax/regulatory requirements.
- Wrote the **master SQL script** (schema + seed data + verification queries) in pgAdmin-native style: explicit `CREATE DATABASE`, sequences, referential-integrity constraints, domain `CHECK` constraints and unique keys — validated against ~100 records per core transactional table.
- Used `numeric(10,2)` for every monetary field to avoid floating-point rounding errors in billing and payments.
- Wrote and validated **40 SQL queries** (joins across multiple tables, aggregations with `GROUP BY`, subqueries, compound filters) answering real business questions for clinic administration, billing and inventory.
- Documented the schema, ER diagram, design decisions and known limitations in a full technical report.

**Stack:** PostgreSQL 18 · SQL (DDL/DML) · Graphviz (ER diagram)

**Repository contents:**
| Path | Description |
|---|---|
| [`database/script_maestro_sgco.sql`](database/script_maestro_sgco.sql) | Full schema (27 tables), seed data, and 5+ verification queries |
| [`diagrams/diagrama_sgco.svg`](diagrams/diagrama_sgco.svg) / `.png` | Complete entity-relationship diagram |
| [`docs/informe_tecnico_SGCO.pdf`](docs/informe_tecnico_SGCO.pdf) | Full technical report (Spanish, academic submission) |

---

## 🇪🇨 Descripción (Español)

Sistema de Gestión para Clínica Odontológica (SGCO), diseñado para una clínica odontológica privada de tamaño mediano en Guayaquil, Ecuador, con una cartera aproximada de +100 pacientes activos. El sistema centraliza el registro de pacientes, historias clínicas, citas, tratamientos, facturación, pagos, reclamos e inventario de insumos odontológicos.

**Mi rol:** Líder técnico y arquitecto de base de datos del proyecto grupal (4 integrantes — Byron Almeida, Jean España, Esther Montalván y Eduardo Indio).

### Aspectos técnicos destacados

- **27 tablas normalizadas hasta Tercera Forma Normal (3NF)**, distribuidas en módulos clínico, financiero y de inventario.
- **Modelado de relación N:N** para el registro de alergias de pacientes (`historial_alergia`).
- **Diseño polimórfico en `detalle_factura`**: una factura puede referirse a un tratamiento clínico o a un producto/servicio, pero nunca a ambos — resuelto con un campo discriminador (`tipo_item`) y una restricción `CHECK` (`chk_detalle_factura_tipo_item`) que obliga a que exactamente una de las dos llaves foráneas esté presente.
- **Campos de facturación electrónica (SRI Ecuador)** incorporados al módulo de facturación, ajustados tras retroalimentación del docente sobre el diagrama ER.
- **Tipo de dato `numeric(10,2)`** para todo campo monetario (precio, subtotal, IVA, descuento, total), evitando errores de redondeo de punto flotante en un sistema que factura y calcula pagos reales.
- **Tablas intermedias con atributos propios** (`detalle_factura`, `detalle_orden_compra`, `insumo_proveedor`) en lugar de simples tablas puente, para conservar el precio histórico de venta/compra aunque el precio de catálogo cambie después.
- **Script maestro SQL** en estilo nativo de pgAdmin (`CREATE DATABASE`, secuencias explícitas, restricciones de integridad referencial, restricciones de dominio `CHECK`, llaves únicas), validado con ~100 registros por tabla transaccional principal.
- **40 consultas SQL** documentadas y validadas contra datos de prueba reales: joins entre múltiples tablas, `GROUP BY` con funciones de agregación, subconsultas, filtros compuestos y reportes de apoyo a la toma de decisiones.

### Limitación identificada

El sistema no cuenta con un mecanismo uniforme de auditoría o baja lógica: algunas tablas incorporan una columna `activo` o `estado`, mientras que otras no la tienen, lo que impide desactivar un insumo o proveedor sin eliminarlo físicamente. Una versión futura podría resolver esto con columnas de auditoría estandarizadas (`activo`, `fecha_creacion`, `creado_por`) en todas las tablas transaccionales, o mediante una tabla central de bitácora de cambios.

### Contenido del repositorio

| Ruta | Descripción |
|---|---|
| [`database/script_maestro_sgco.sql`](database/script_maestro_sgco.sql) | Esquema completo (27 tablas), datos de prueba y consultas de verificación |
| [`diagrams/diagrama_sgco.svg`](diagrams/diagrama_sgco.svg) / `.png` | Diagrama entidad-relación completo |
| [`docs/informe_tecnico_SGCO.pdf`](docs/informe_tecnico_SGCO.pdf) | Informe técnico completo (entrega académica, en español) |

---

**Autor:** Byron Almeida Coello — [LinkedIn](https://www.linkedin.com/in/byronalmeidacoello)
**Curso:** Fundamentos de Bases de Datos Relacionales — Universidad Técnica Estatal de Quevedo (UTEQ), 2026
