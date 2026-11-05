-- =============================================================================
-- ESQUEMA BASE DE DATOS: PRODUCCION Y PAROS (VINILOS Y TEMPERAS)
-- Compatible con PostgreSQL 12+ / ANSI SQL
-- =============================================================================

DROP TABLE IF EXISTS registro_paro_detalle CASCADE;
DROP TABLE IF EXISTS registro_produccion_hora CASCADE;
DROP TABLE IF EXISTS registro_orden_turno CASCADE;
DROP TABLE IF EXISTS subcodigo_paro CASCADE;
DROP TABLE IF EXISTS codigo_paro CASCADE;
DROP TABLE IF EXISTS empleado CASCADE;
DROP TABLE IF EXISTS cargo CASCADE;
DROP TABLE IF EXISTS turno CASCADE;
DROP TABLE IF EXISTS linea_produccion CASCADE;

-- 1. Catálogo: Líneas de Producción
CREATE TABLE linea_produccion (
    linea_id SERIAL PRIMARY KEY,
    codigo_linea VARCHAR(20) NOT NULL UNIQUE,
    descripcion VARCHAR(100),
    capacidad_nominal_hora NUMERIC(10,2) NOT NULL CHECK (capacidad_nominal_hora > 0)
);

-- 2. Catálogo: Turnos de Trabajo
CREATE TABLE turno (
    turno_id SERIAL PRIMARY KEY,
    nombre_turno VARCHAR(20) NOT NULL UNIQUE,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    duracion_horas NUMERIC(4,2) NOT NULL DEFAULT 8.00 CHECK (duracion_horas > 0)
);

-- 3. Catálogo: Cargos
CREATE TABLE cargo (
    cargo_id SERIAL PRIMARY KEY,
    nombre_cargo VARCHAR(50) NOT NULL UNIQUE
);

-- 4. Entidad: Empleados (Con Pseudonimización Habeas Data)
CREATE TABLE empleado (
    empleado_id SERIAL PRIMARY KEY,
    codigo_empleado VARCHAR(32) NOT NULL UNIQUE,
    nombre_hash VARCHAR(64) NOT NULL,
    cargo_id INT NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_empleado_cargo FOREIGN KEY (cargo_id) 
        REFERENCES cargo(cargo_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 5. Catálogo: Códigos Principales de Paro (P-MTO-22)
CREATE TABLE codigo_paro (
    codigo_paro_id SERIAL PRIMARY KEY,
    codigo VARCHAR(10) NOT NULL UNIQUE,
    descripcion VARCHAR(150) NOT NULL,
    categoria VARCHAR(50) NOT NULL
);

-- 6. Catálogo: Subcódigos de Paro
CREATE TABLE subcodigo_paro (
    subcodigo_paro_id SERIAL PRIMARY KEY,
    codigo_paro_id INT NOT NULL,
    subcodigo VARCHAR(10) NOT NULL,
    descripcion VARCHAR(200) NOT NULL,
    CONSTRAINT fk_subcodigo_codigo_paro FOREIGN KEY (codigo_paro_id)
        REFERENCES codigo_paro(codigo_paro_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT uk_codigo_subcodigo UNIQUE (codigo_paro_id, subcodigo)
);

-- 7. Encabezado: Registro de Turno por Línea
CREATE TABLE registro_orden_turno (
    registro_turno_id BIGSERIAL PRIMARY KEY,
    linea_id INT NOT NULL,
    turno_id INT NOT NULL,
    operaria_id INT NOT NULL,
    fecha DATE NOT NULL,
    meta_produccion_unidades INT NOT NULL DEFAULT 0 CHECK (meta_produccion_unidades >= 0),
    CONSTRAINT fk_rot_linea FOREIGN KEY (linea_id)
        REFERENCES linea_produccion(linea_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_rot_turno FOREIGN KEY (turno_id)
        REFERENCES turno(turno_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_rot_operaria FOREIGN KEY (operaria_id)
        REFERENCES empleado(empleado_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT uk_linea_turno_fecha UNIQUE (linea_id, turno_id, fecha)
);

-- 8. Detalle: Producción Horaria
CREATE TABLE registro_produccion_hora (
    produccion_hora_id BIGSERIAL PRIMARY KEY,
    registro_turno_id BIGINT NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    unidades_producidas INT NOT NULL DEFAULT 0 CHECK (unidades_producidas >= 0),
    CONSTRAINT fk_rph_registro_turno FOREIGN KEY (registro_turno_id)
        REFERENCES registro_orden_turno(registro_turno_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 9. Detalle: Registro de Eventos de Paro
CREATE TABLE registro_paro_detalle (
    paro_id BIGSERIAL PRIMARY KEY,
    registro_turno_id BIGINT NOT NULL,
    subcodigo_paro_id INT NOT NULL,
    tecnico_mto_id INT,
    hora_inicio_paro TIMESTAMP NOT NULL,
    hora_fin_paro TIMESTAMP NOT NULL,
    duracion_minutos NUMERIC(8,2) NOT NULL CHECK (duracion_minutos > 0),
    observaciones TEXT,
    CONSTRAINT fk_rpd_registro_turno FOREIGN KEY (registro_turno_id)
        REFERENCES registro_orden_turno(registro_turno_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_rpd_subcodigo FOREIGN KEY (subcodigo_paro_id)
        REFERENCES subcodigo_paro(subcodigo_paro_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_rpd_tecnico FOREIGN KEY (tecnico_mto_id)
        REFERENCES empleado(empleado_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_fechas_paro CHECK (hora_fin_paro > hora_inicio_paro)
);

-- INDICES SECUNDARIOS
CREATE INDEX idx_rot_fecha_linea ON registro_orden_turno(fecha, linea_id);
CREATE INDEX idx_rot_turno_operaria ON registro_orden_turno(turno_id, operaria_id);
CREATE INDEX idx_rpd_subcodigo_fechas ON registro_paro_detalle(subcodigo_paro_id, hora_inicio_paro);
CREATE INDEX idx_rpd_registro_turno ON registro_paro_detalle(registro_turno_id);

-- VISTAS DEL NEGOCIO
CREATE OR REPLACE VIEW vw_productividad_mensual AS
SELECT 
    EXTRACT(YEAR FROM rot.fecha)::INT AS anio,
    EXTRACT(MONTH FROM rot.fecha)::INT AS mes,
    lp.codigo_linea,
    SUM(rph.unidades_producidas) AS unidades_reales,
    SUM(rot.meta_produccion_unidades) AS unidades_meta,
    ROUND(
        (SUM(rph.unidades_producidas)::NUMERIC / NULLIF(SUM(rot.meta_produccion_unidades), 0)) * 100, 2
    ) AS porcentaje_productividad
FROM registro_orden_turno rot
JOIN linea_produccion lp ON rot.linea_id = lp.linea_id
JOIN registro_produccion_hora rph ON rot.registro_turno_id = rph.registro_turno_id
GROUP BY EXTRACT(YEAR FROM rot.fecha), EXTRACT(MONTH FROM rot.fecha), lp.codigo_linea;

CREATE OR REPLACE VIEW vw_analisis_paros_codigo AS
SELECT 
    cp.codigo AS codigo_paro,
    cp.descripcion AS descripcion_codigo,
    cp.categoria,
    COUNT(rpd.paro_id) AS total_eventos_paro,
    SUM(rpd.duracion_minutos) AS total_minutos_paro,
    ROUND(
        (SUM(rpd.duracion_minutos) / SUM(SUM(rpd.duracion_minutos)) OVER ()) * 100, 2
    ) AS porcentaje_participacion
FROM registro_paro_detalle rpd
JOIN subcodigo_paro sp ON rpd.subcodigo_paro_id = sp.subcodigo_paro_id
JOIN codigo_paro cp ON sp.codigo_paro_id = cp.codigo_paro_id
GROUP BY cp.codigo, cp.descripcion, cp.categoria;
