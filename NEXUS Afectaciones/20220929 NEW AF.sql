SELECT distinct
    odo.id id_documento, 
    odo.NAME nro_documento,
    trim(nmt.NAME) ct,
    c.cuenta,
    nme.affect_time,
    nme.restore_time,
    nmt.object_name_id,
    oae.affect_id,
    oae.restore_id
--    (SELECT o.creation_time from nexus_gis.OMS_OPERATION o, nexus_gis.OMS_AFFECT_RESTORE_OPERATION aro WHERE aro.is_restore=0 AND aro.document_id=odo.ID AND aro.ID=oae.affect_id) Inicio

FROM 
    nexus_gis.oms_document odo,
    nexus_gis.nbm_mon_element nme,
    NEXUS_GIS.nbm_mon_trafos nmt,
    nexus_gis.OMS_AFFECTED_ELEMENT oae,
    nexus_gis.nbm_relation_values nrv,
    gelec.ed_clientes c
WHERE
    1=1
    AND odo.ID=nme.affect_document_id
    AND nme.object_name_id=nmt.parent_object_name_id  AND nmt.revision_id_to=0
    AND nmt.object_name_id=oae.child_object_name_id
    AND nmt.object_name_id=nrv.object_name_id_from    AND nrv.property_id=2
    and nrv.property_value=c.cuenta
    
    and odo.id=10487985
ORDER BY
    odo.ID,
    trim(nmt.NAME),
    c.cuenta
;

SELECT * FROM nexus_gis.nbm_mon_element;
SELECT * FROM nexus_gis.OMS_AFFECT_RESTORE_OPERATION WHERE document_id=10487985;
SELECT * FROM nexus_gis.OMS_AFFECTED_ELEMENT	WHERE affect_id=9150268;













