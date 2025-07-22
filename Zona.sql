SELECT DISTINCT
    d.id,
    NVL(
        (SELECT description 
         FROM nexus_gis.OMS_WEATHER_TYPE 
         WHERE id = d.weather_type_id),
        'NORMAL'
    ) Cond_climatica,
    d.name nro_documento,
    d.creation_time inicio_corte,
    d.Address_id , --22257895
    trim((select zona from nexus_gis.partido_zona where areaid in (select areaid from nexus_gis.amareas where areaid in (select medium_area_id from nexus_gis.oms_address where id=d.address_id)))) AREA_OP,      -- CONVERSION  select * from nexus_gis.partido_zona;
    trim((select areaname from nexus_gis.amareas where areaid in (select medium_area_id from nexus_gis.oms_address where id=d.address_id))) PARTIDO,             -- Campo Address_id Tabla Amareas
    trim((select areaname from nexus_gis.amareas where areaid in (select small_area_id from nexus_gis.oms_address where id=d.address_id))) LOCALIDAD,         -- Campo Address_id Tabla Amareas
    d.model_element_chain JER_ELECTRICA,
    ae.count_properties AFECTADOS_AHORA,  -- Hacer sumatoria de afectados para que no duplique doc.
    d.affected_clients AFECTADOS_AHORA,
    d.count_init_affected_customers AFECTADOS_INI,
    NULL Equip,
    NULL NRO_ANOMALIA,
    NULL FECHA_DETECCION,
    NULL AVISO_OT,
    NULL ALIM,
    NULL SSEE,
    NULL INSTALACION,
    NULL TIPO_FALLA,
    CASE WHEN ae.count_properties>0 THEN 'SI' ELSE 'NO' END AFECTA_SUMINISTRO,
    NULL OBSERVACIONES_ENCARGADO,
    NULL SAP_NRO_ORDEN,
    NULL SAP_UBICACION_TECNICA,
    (SELECT DESCRIPTION FROM NEXUS_GIS.OMS_DEVICE_FAILURE_TYPE WHERE ID IN (SELECT DEVICE_FAILURE_TYPE_ID FROM NEXUS_GIS.OMS_DOCUMENT_CAUSE WHERE DOCUMENT_ID=D.ID)) CONFIRMAR_FALLA,
    NULL EM_DETECCION_OFICIAL,
    NULL EM_DETECCION_EMPRESA
FROM
    nexus_gis.oms_document d,
    nexus_gis.oms_document_type dt,
    nexus_gis.oms_document_state ds,
    nexus_gis.oms_operation op,
    nexus_gis.sprgoperations o,
    nexus_gis.oms_affect_restore_operation aro,
    nexus_gis.oms_affected_element ae
    -- nexus_gis.sprobjects ob
WHERE
    1 = 1
    AND d.type_id = dt.id
    AND d.last_state_id = ds.id
    AND d.id = op.document_id
    AND op.operation_model_id = o.operationid
    AND op.id = aro.operation_id
    AND aro.id = ae.affect_id
    -- AND ae.element_id = ob.objectid
    AND d.type_id IN (3, 4)
    AND d.last_state_id > 1
    AND d.last_state_id < 5
    AND ((SYSDATE - aro.time) * (60 * 24)) >= (
        SELECT valor 
        FROM nexus_gis.param_enre_mtat 
        WHERE tipo = 'DURACION'
    )
    AND aro.is_restore = 0
    AND o.logidto = 0
    AND DECODE(
        d.type_id, 
        3, 1, 
        4, (
            SELECT COUNT(1) 
            FROM nexus_gis.oms_anomaly 
            WHERE document_id = d.id 
              AND d.type_id = 4
        )
    ) > 0 -- DOC FORZ CON Y SIN ANOM Y DOC PROD CON ANOM
ORDER BY
    1;




------------------------
--ZONAS
select * from nexus_gis.partido_zona;
select * from nexus_gis.oms_address where id=22257895; -- small 468	medium 337	large 43
select * from nexus_gis.amareas where areaid= 468; -- localidad
select * from nexus_gis.amareas where areaid= 337; -- partido


select * from nexus_gis.partido_zona where areaid=337; -- oms_addres.medium -> zona



select areaname from nexus_gis.amareas where areaid in (select small_area_id from nexus_gis.oms_address where id=22257895); --localidad
select areaname from nexus_gis.amareas where areaid in (select medium_area_id from nexus_gis.oms_address where id=22257895); --partido
select zona from nexus_gis.partido_zona where areaid in (select areaid from nexus_gis.amareas where areaid in (select medium_area_id from nexus_gis.oms_address where id=22257895)); --zona




-----------------------------------
--ANOMALIAS
select * from nexus_gis.oms_anomaly;
select document_id, count(1) from nexus_gis.oms_anomaly group by document_id having count(1)>1;




-------------------------------------
--FAILURE

SELECT IT.ID, IT.DESCRIPTION AS INSTALACION, ODT.ID, ODT.DESCRIPTION AS TIPO_ELEMENTO, ODFT.ID, ODFT.DESCRIPTION AS TIPO_FALLA 
    FROM OMS_INSTALLATION_TYPE IT -- instalacion
    INNER JOIN OMS_REL_INSTALLATION_DEVICE ORID ON ORID.INSTALLATION_TYPE_ID = IT.ID --relación instalacion elemento
    INNER JOIN OMS_DEVICE_TYPE ODT ON ODT.ID = ORID.DEVICE_TYPE_ID -- elemento
    INNER JOIN OMS_REL_DEVICE_FAILURE ORDF ON ORDF.DEVICE_TYPE_ID = ODT.ID -- relación elemento falla
    INNER JOIN OMS_DEVICE_FAILURE_TYPE ODFT ON ODFT.ID = ORDF.DEVICE_FAILURE_TYPE_ID -- falla
ORDER BY 2;

SELECT * FROM NEXUS_GIS.OMS_INSTALLATION_TYPE;
SELECT * FROM NEXUS_GIS.OMS_REL_INSTALLATION_DEVICE WHERE DEVICE_TYPE_ID=11948415;
SELECT * FROM NEXUS_GIS.OMS_DEVICE_TYPE WHERE CODE=11948415;
SELECT * FROM NEXUS_GIS.OMS_REL_DEVICE_FAILURE WHERE DEVICE_FAILURE_TYPE_ID=11948415;
SELECT * FROM NEXUS_GIS.OMS_DEVICE_FAILURE_TYPE;


SELECT ID, FAILED_DEVICE_ID FROM NEXUS_GIS.OMS_DOCUMENT WHERE failed_device_id IS NOT NULL ORDER BY ID;
SELECT * FROM NEXUS_GIS.OMS_DOCUMENT_CAUSE;


SELECT DESCRIPTION FROM NEXUS_GIS.OMS_DEVICE_FAILURE_TYPE WHERE ID IN (SELECT DEVICE_FAILURE_TYPE_ID FROM NEXUS_GIS.OMS_DOCUMENT_CAUSE WHERE DOCUMENT_ID=7624874);


-----------------------------------
--SIN DUPLICAR

SELECT DISTINCT
    d.id,
    NVL(
        (SELECT description 
         FROM nexus_gis.OMS_WEATHER_TYPE 
         WHERE id = d.weather_type_id),
        'NORMAL'
    ) Cond_climatica,
    d.name nro_documento,
    d.creation_time inicio_corte,
    d.Address_id , --22257895
    trim((select zona from nexus_gis.partido_zona where areaid in (select areaid from nexus_gis.amareas where areaid in (select medium_area_id from nexus_gis.oms_address where id=d.address_id)))) AREA_OP,      -- CONVERSION  select * from nexus_gis.partido_zona;
    trim((select areaname from nexus_gis.amareas where areaid in (select medium_area_id from nexus_gis.oms_address where id=d.address_id))) PARTIDO,             -- Campo Address_id Tabla Amareas
    trim((select areaname from nexus_gis.amareas where areaid in (select small_area_id from nexus_gis.oms_address where id=d.address_id))) LOCALIDAD,         -- Campo Address_id Tabla Amareas
    d.model_element_chain JER_ELECTRICA,
    --ae.count_properties AFECTADOS_AHORA,  -- Hacer sumatoria de afectados para que no duplique doc.
    NVL((SELECT SUM(COUNT_PROPERTIES) FROM NEXUS_GIS.OMS_AFFECTED_ELEMENT WHERE AFFECT_ID IN (SELECT ID FROM NEXUS_GIS.oms_affect_restore_operation WHERE DOCUMENT_ID=D.ID) AND IS_AFFECTED=1),0) AFECTADOS_AHORA,
    d.affected_clients AFECTADOS_AHORA,
    d.count_init_affected_customers AFECTADOS_INI,
    NULL Equip,
    NULL NRO_ANOMALIA,
    NULL FECHA_DETECCION,
    NULL AVISO_OT,
    NULL ALIM,
    NULL SSEE,
    NULL INSTALACION,
    NULL TIPO_FALLA,
    --CASE WHEN ae.count_properties>0 THEN 'SI' ELSE 'NO' END AFECTA_SUMINISTRO,
    CASE WHEN 0>0 THEN 'SI' ELSE 'NO' END AFECTA_SUMINISTRO,
    NULL OBSERVACIONES_ENCARGADO,
    NULL SAP_NRO_ORDEN,
    NULL SAP_UBICACION_TECNICA,
    (SELECT DESCRIPTION FROM NEXUS_GIS.OMS_DEVICE_FAILURE_TYPE WHERE ID IN (SELECT DEVICE_FAILURE_TYPE_ID FROM NEXUS_GIS.OMS_DOCUMENT_CAUSE WHERE DOCUMENT_ID=D.ID)) CONFIRMAR_FALLA,
    NULL EM_DETECCION_OFICIAL,
    NULL EM_DETECCION_EMPRESA
FROM
    nexus_gis.oms_document d,
    nexus_gis.oms_document_type dt,
    nexus_gis.oms_document_state ds
    --nexus_gis.oms_operation op,
    --nexus_gis.sprgoperations o,
    --nexus_gis.oms_affect_restore_operation aro,
    ---nexus_gis.oms_affected_element ae
    -- nexus_gis.sprobjects ob
WHERE
    1 = 1
    AND d.type_id = dt.id
    AND d.last_state_id = ds.id
    --AND d.id = op.document_id
    --AND op.operation_model_id = o.operationid
    --AND op.id = aro.operation_id
    --AND aro.id = ae.affect_id
    -- AND ae.element_id = ob.objectid
    AND d.type_id IN (3, 4)
    AND d.last_state_id > 1
    AND d.last_state_id < 5
    --AND ((SYSDATE - aro.time) * (60 * 24)) >= (SELECT valor FROM nexus_gis.param_enre_mtat WHERE tipo = 'DURACION')
    --AND aro.is_restore = 0
    --AND o.logidto = 0
    AND DECODE(
        d.type_id, 
        3, 1, 
        4, (
            SELECT COUNT(1) 
            FROM nexus_gis.oms_anomaly 
            WHERE document_id = d.id 
              AND d.type_id = 4
        )
    ) > 0 -- DOC FORZ CON Y SIN ANOM Y DOC PROD CON ANOM
ORDER BY
    1;





--DOCUMENT_ID: 13096669
SELECT * FROM NEXUS_GIS.OMS_AFFECTED_ELEMENT WHERE AFFECT_ID IN (SELECT ID FROM NEXUS_GIS.oms_affect_restore_operation WHERE DOCUMENT_ID=13096686);

SELECT SUM(COUNT_PROPERTIES) FROM NEXUS_GIS.OMS_AFFECTED_ELEMENT WHERE AFFECT_ID IN (SELECT ID FROM NEXUS_GIS.oms_affect_restore_operation WHERE DOCUMENT_ID=13096686) AND IS_AFFECTED=1;




