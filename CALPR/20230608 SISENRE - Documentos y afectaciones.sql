-- clientes afectados de esas interrupciones 
SELECT 
  T9.ID_USUAR,
  T9.ID_INTER,
  T9.ID_REPOS,
  T9.TARIFA,
  T9.CEN_MTBT,
  T2.SISTEMA,
  T2.START_DOCUMENT
--  ,(SELECT COUNT(1) FROM NEXUS_GIS.TABLA_ENRE WHERE NRO_DOCUMENTO=T2.START_DOCUMENT) WSBT
FROM 
  NEXUS_GIS.GI_ENRE_TABLA09 T9, 
  NEXUS_GIS.GI_ENRE_TABLA02 t2        -- 974.017
WHERE  
  t9.idperiodo = 54
  AND T9.ID_INTER = T2.ID_INTER
  and t9.id_inter in (
        -- interrupciones de esos documentos
        select distinct id_inter from NEXUS_GIS.GI_ENRE_TABLA02
        where idperiodo = 54
        and start_document in (
                --- documentos que no fueron por ws
                select distinct(start_document) from NEXUS_GIS.GI_ENRE_TABLA02
                where idperiodo = 54
                minus
                select distinct nro_documento from NEXUS_GIS.WS_ENREMTAT_LOG
                where substr(nro_documento,1,7) = ('D-22-09')
          )
    )
;