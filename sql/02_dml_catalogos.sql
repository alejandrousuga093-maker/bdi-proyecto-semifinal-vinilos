-- =============================================================================
-- POBLACION DE CATALOGOS Y DATOS HISTORICOS DE MUESTRA
-- =============================================================================

INSERT INTO linea_produccion (codigo_linea, descripcion, capacidad_nominal_hora) VALUES
('Vinilos_1', 'Línea 1 Envasado Vinilos 250ml', 1200.00),
('Vinilos_2', 'Línea 2 Envasado Vinilos 500ml', 1000.00),
('Vinilos_3', 'Línea 3 Envasado Vinilos Galón', 600.00),
('Vinilos_4', 'Línea 4 Envasado Témperas Escolar', 1500.00);

INSERT INTO turno (nombre_turno, hora_inicio, hora_fin, duracion_horas) VALUES
('Turno 1', '06:00:00', '14:00:00', 8.00),
('Turno 2', '14:00:00', '22:00:00', 8.00),
('Turno 3', '22:00:00', '06:00:00', 8.00);

INSERT INTO cargo (nombre_cargo) VALUES
('Operaria de Envasado'),
('Técnico Mantenimiento Mecánico'),
('Técnico Mantenimiento Eléctrico');

INSERT INTO empleado (codigo_empleado, nombre_hash, cargo_id) VALUES
('EMP-OP-001', 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', 1),
('EMP-OP-002', 'f2d81a260dea8a100dd517985652e0789d61860a93f23abc437ecc914236a2e2', 1),
('EMP-OP-003', 'a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e', 1),
('EMP-MT-001', '8f434346648f6b96df89dda901c5176b10a6d83961dd3c1ac88b59b2dc327aa4', 2),
('EMP-MT-002', 'ed7303a82e6c706328152b2ad9c194a596dc1158d5b350f6d616b6e7d10ec135', 3);

INSERT INTO codigo_paro (codigo, descripcion, categoria) VALUES
('01', 'Falla Mecánica en Envasadora', 'Mantenimiento Mecánico'),
('02', 'Falla Eléctrica / Electrónica', 'Mantenimiento Eléctrico'),
('03', 'Falta de Materia Prima / Insumos', 'Operativa / Logística'),
('04', 'Ajuste de Calidad / Cambio de Color', 'Calidad'),
('05', 'Limpieza y Desinfección de Boquillas', 'Operativa');

INSERT INTO subcodigo_paro (codigo_paro_id, subcodigo, descripcion) VALUES
(1, '01.1', 'Atasco de envases en estrella de llenado'),
(1, '01.2', 'Ruptura de manguera de dosificación'),
(1, '01.3', 'Desalineación de pistones de dosificado'),
(2, '02.1', 'Fallo de sensor óptico de presencia de envase'),
(3, '03.1', 'Agotamiento de vinilo en tanque principal'),
(3, '03.2', 'Falta de tapas en tolva alimentadora'),
(4, '04.1', 'Purga y lavado por cambio de tono'),
(5, '05.1', 'Limpieza programada de boquillas de inyección'),
(5, '05.2', 'Desatasco manual por acumulación de pigmento seco');

INSERT INTO registro_orden_turno (linea_id, turno_id, operaria_id, fecha, meta_produccion_unidades) VALUES
(1, 1, 1, '2025-05-10', 9600),
(1, 2, 2, '2025-05-10', 9600),
(2, 1, 3, '2025-05-10', 8000),
(1, 1, 1, '2026-05-10', 9600),
(2, 1, 2, '2026-05-10', 8000);

INSERT INTO registro_produccion_hora (registro_turno_id, hora_inicio, hora_fin, unidades_producidas) VALUES
(4, '06:00:00', '07:00:00', 1200),
(4, '07:00:00', '08:00:00', 1150),
(4, '08:00:00', '09:00:00', 600),
(4, '09:00:00', '10:00:00', 1200),
(4, '10:00:00', '11:00:00', 1180),
(4, '11:00:00', '12:00:00', 1200),
(4, '12:00:00', '13:00:00', 1100),
(4, '13:00:00', '14:00:00', 1200);

INSERT INTO registro_paro_detalle (registro_turno_id, subcodigo_paro_id, tecnico_mto_id, hora_inicio_paro, hora_fin_paro, duracion_minutos, observaciones) VALUES
(4, 1, 4, '2026-05-10 08:15:00', '2026-05-10 08:45:00', 30.00, 'Atasco de botellas en la estrella principal'),
(1, 4, 5, '2025-05-10 10:00:00', '2025-05-10 10:45:00', 45.00, 'Falla en sensor de tapado'),
(2, 5, NULL, '2025-05-10 16:00:00', '2025-05-10 16:20:00', 20.00, 'Esperando lote de pigmento desde mezclado'),
(3, 7, NULL, '2025-05-10 09:00:00', '2025-05-10 09:50:00', 50.00, 'Purga por cambio de vinilo rojo a azul'),
(5, 8, 4, '2026-05-10 11:10:00', '2026-05-10 11:35:00', 25.00, 'Limpieza de boquillas atascadas');
