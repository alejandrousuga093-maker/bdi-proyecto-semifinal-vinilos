# Documentación Arquitectónica del Modelo Relacional

## Normalización (3FN)
1. **1FN**: Eliminación de campos repetidos de horas (`Prod_H1` a `Prod_H8`) mediante la tabla `registro_produccion_hora`.
2. **2FN**: Separación de información del turno (`registro_orden_turno`) respecto a los eventos individuales de parada (`registro_paro_detalle`).
3. **3FN**: Desacoplamiento de nombres de operarias/técnicos (`empleado`), líneas de envasado (`linea_produccion`), turnos (`turno`), y jerarquía de códigos y subcódigos de paros (`codigo_paro` y `subcodigo_paro`).

## Cumplimiento de Habeas Data
Los datos personales de los empleados se almacenan pseudonimizados mediante la combinación de un código institucional (`codigo_empleado`) y el hash SHA-256 de su nombre completo (`nombre_hash`).
