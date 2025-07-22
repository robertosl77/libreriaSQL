SELECT ID_DOCUMENTO, CUENTA, CT_CLIE CT, FECHA_INICIO_CORTE, FECHA_FIN_CORTE FROM GELEC.ED_DET_DOCUMENTOS_CLIENTES WHERE FECHA_INICIO_CORTE>FECHA_FIN_CORTE;
8114701	5248680423	6526	12/11/2019 10:47:22	06/11/2019 20:50:26

SELECT
    c.cuenta,
    substr(l.linkvalue,0,instr(l.linkvalue,'-')-1) CT,
    AE.ID ID_AFECTACION, 
    aro.document_id,
    ARO.TIME FECHA_INICIO, 
    (select a.time from nexus_gis.oms_affect_restore_operation a, nexus_gis.oms_affected_element b where a.id=b.restore_id and b.id=ae.id) Fecha_Restauracion
FROM 
    NEXUS_GIS.SPRLINKS L, 
    NEXUS_GIS.SPROBJECTS O, 
    NEXUS_GIS.OMS_AFFECTED_ELEMENT AE, 
    NEXUS_GIS.OMS_AFFECT_RESTORE_OPERATION ARO, 
    gelec.ed_clientes c
WHERE
    L.LOGIDTO=0
    AND L.LINKID=1018
--    AND substr(l.linkvalue,0,instr(l.linkvalue,'-')-1)= 6526
    AND L.OBJECTID=O.OBJECTID
    AND O.LOGIDTO=0
    AND O.OBJECTNAMEID=AE.ELEMENT_ID
    AND AE.AFFECT_ID=ARO.ID
    AND ARO.IS_RESTORE=0
    AND ARO.OPERATION_ID IS NOT NULL
--    AND ARO.DOCUMENT_ID=8114701
    AND SUBSTR(L.LINKVALUE,0,INSTR(L.LINKVALUE,'-')-1)=C.CT
--    and c.cuenta='7076880282'
    and aro.document_id in (select affect_document_id from nexus_gis.nbm_mon_element)
;    
    









