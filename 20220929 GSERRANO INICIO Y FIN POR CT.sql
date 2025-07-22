SELECT
    ODO.ID ID_DOCUMENTO,
    ODO.NAME NRO_DOCUMENTO,
    substr(spli.linkvalue,1,instr(spli.linkvalue,'-')-1) ct,
    ope_afe.CREATION_TIME "Inicio",
    ope_rep.CREATION_TIME "Fin",
    afe.ID "Id Afectacion",
    decode(afe.ELEMENT_TO_AFFECT_ID, 2, 'Trafo', 3, 'Cliente') "Tipo Elemento",
    afe.ELEMENT_TO_AFFECT_ID,
    afe.ELEMENT_ID "Id Elemento",
    afe.COUNT_PROPERTIES "Clientes Asociados",
    AFE.* 
FROM
    nexus_gis.OMS_AFFECTED_ELEMENT afe
    inner join nexus_gis.OMS_AFFECT_RESTORE_OPERATION aro_afe on aro_afe.id = afe.affect_id and aro_afe.IS_RESTORE = 0
    inner join nexus_gis.OMS_OPERATION ope_afe on ope_afe.id = aro_afe.OPERATION_ID
    left join nexus_gis.OMS_AFFECT_RESTORE_OPERATION aro_rep on aro_rep.id = afe.RESTORE_ID and aro_rep.IS_RESTORE = 1
    left join nexus_gis.OMS_OPERATION ope_rep on ope_rep.id = aro_afe.OPERATION_ID
    INNER JOIN nexus_gis.oms_document odo ON odo.ID = aro_afe.DOCUMENT_ID
    inner join NEXUS_GIS.sprlinks spli on spli.objectid=afe.child_object_name_id and logidto=0 and linkid=611
WHERE
    odo.NAME = 'D-22-08-002090'
    AND AFE.CHILD_OBJECT_NAME_ID=73829317
--    AND AFE.ELEMENT_ID=75160208
--    afe.property_value='0027586160'

ORDER BY
    OPE_AFE.CREATION_TIME
;









