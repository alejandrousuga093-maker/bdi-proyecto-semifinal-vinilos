-- =============================================================================
-- CASOS DE PRUEBA DE RESTRICCIONES (DML VALIDOS E INVALIDOS)
-- =============================================================================

-- 1. Actualización Válida (UPDATE)
UPDATE linea_produccion 
SET capacidad_nominal_hora = 1250.00 
WHERE codigo_linea = 'Vinilos_1';

-- 2. Borrado Válido (DELETE) con Cascada Controlada a tablas dependientes
DELETE FROM registro_orden_turno WHERE registro_turno_id = 3;

-- 3. Pruebas comentadas de violaciones esperadas (Descomentar para probar rechazo por el motor):
-- INSERT INTO registro_paro_detalle (registro_turno_id, subcodigo_paro_id, hora_inicio_paro, hora_fin_paro, duracion_minutos)
-- VALUES (4, 1, '2026-05-10 08:00:00', '2026-05-10 07:30:00', -30.00);

-- INSERT INTO registro_orden_turno (linea_id, turno_id, operaria_id, fecha)
-- VALUES (999, 1, 1, '2026-05-11');
