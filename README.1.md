# Base de Datos Relacional para Registro de Paros y Producción (Vinilos y Témperas)

Este proyecto contiene el diseño e implementación completo en PostgreSQL para el control de producción y paros operativos de envasado (procedimiento `P-MTO-22`), sustituyendo la hoja de cálculo de Excel.

## Estructura del Repositorio

```text
bdi-proyecto-final-vinilos/
├── README.md
├── .gitignore
├── docs/
│   └── Modelo_Relacional_Notas.md
└── sql/
    ├── 01_ddl_esquema.sql     -- Creación de tablas, llaves, restricciones, índices y vistas
    ├── 02_dml_catalogos.sql   -- Carga de catálogos, datos transaccionales y datos históricos
    ├── 03_dml_pruebas.sql     -- Pruebas de validación e integridad referencial
    └── 04_consultas.sql       -- Consultas SQL analíticas para la toma de decisiones
```

## Guía de Despliegue Rápido en DBeaver

1. Abra **DBeaver** y asegúrese de estar conectado a su servidor de **PostgreSQL**.
2. Cree la base de datos vacía ejecutando: `CREATE DATABASE db_vinilos_produccion;`.
3. Conéctese a la nueva base de datos `db_vinilos_produccion`.
4. Abra y ejecute secuencialmente los scripts de la carpeta `sql/`:
   - `01_ddl_esquema.sql` (Crea todas las tablas, relaciones, reglas e índices).
   - `02_dml_catalogos.sql` (Pobla líneas, turnos, códigos de paro P-MTO-22 y datos de prueba).
   - `03_dml_pruebas.sql` (Prueba las restricciones de integridad y cascadas).
   - `04_consultas.sql` (Ejecuta las consultas analíticas del negocio).
