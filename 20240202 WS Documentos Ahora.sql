--CADENA: R:ORO VERDE / 356-TR1 / 356-5544


SELECT * FROM tabla_enremtat_det
WHERE 
1=1
--ESTADO NOT IN ('Cancelado','Cerrado')
AND FECHA_DOCUMENTO>TO_DATE('01/02/2024 09:00:00','dd/mm/yyyy hh24:mi:ss')
and cad_electrica like '%356-5544%'

;
SELECT * FROM tabla_enremtat_det
WHERE 
1=1
--ESTADO NOT IN ('Cancelado','Cerrado')
AND FECHA_DOCUMENTO>TO_DATE('31/01/2024 09:00:00','dd/mm/yyyy hh24:mi:ss')
and localidad='VIRREY DEL PINO'

;



--D-24-02-003216
--11804879

select * from NEXUS_GIS.WS_ENREMTAT_LOG where nro_documento='D-24-02-003216';

SELECT * FROM TABLA_ENREMTAT_GEN WHERE NRO_DOCUMENTO='D-24-02-003216';
SELECT * FROM TABLA_ENREMTAT_DET WHERE NRO_DOCUMENTO='D-24-02-003216';

