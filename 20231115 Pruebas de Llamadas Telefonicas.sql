CLIENTE	DOCUMENT_ID	RESPUESTAS
2282919334	D-23-11-000979	CON LUZ                                 1570094563
6250065176	D-23-11-000979	CON LUZ                                 1559934248  
8924784610	D-23-11-000980	SIN LUZ                                 1554521323
7545143995	D-23-11-000980	CON LUZ                                 1540347329
8882413265	D-23-11-000980	CON LUZ                                 1540793878
1331774523	D-23-11-000981	ATENDER/NO HABLAR/ NO CONTESTAR         1527315927  
3267555361	D-23-11-000988	CONTESTAR HOLA/NO SELECCIONAR OPCIÓN    1554897959  
1005490173	D-23-11-000989	                                        1540378504  

-- 1) Cambiar tel_camp a los registros que diga Alan

select * from NEXUS_GIS.OMS_CUST_SITUATION_INTERF where fsclientid=2282919334;


--update NEXUS_GIS.OMS_CUST_SITUATION_INTERF set tel_camp = '9*1540378504' where fsclientid = 1005490173;

--2 Verificar cambios

SELECT *  FROM NEXUS_GIS.OMS_CUST_SITUATION_INTERF
where fsclientid='1005490173';


-----------------------------------------------

-- Una vez terminada la campaña y despues de 30 minutos que corrio el proceso de integracion (Chequear que los reclamos tengan last_state_id con 3 o 4).

--Correr el siguiente proceso  que actualiza la tabla NEXUS_GIS.OMS_CUST_SITUATION_INTERF (campo EVENT_NOTES Y LOS ULTIMOS CAMPOS) para

--que un proceso interno de NEXUS cierre reclamos con LUZ y si corresponde, cierre el documento

 

Begin

NEXUS_GIS.LLAM_PROCESOS.llam_agrupados_bt; 

end;


------------------------------------------------------

--D-23-11-000989
--9*1540378504



 select distinct(om.document_id), om.nro_camp
      from NEXUS_GIS.OMS_CUST_SITUATION_INTERF OM
     WHERE 
       1=1
--       AND OM.FE_ULTIM_UPDATE IS NOT NULL
--       AND TRUNC(OM.FE_ULTIM_UPDATE) = TRUNC(SYSDATE)
--       AND OM.LAST_ACTION =0
        and om.document_id in (select id from oms_document where name='D-23-11-000989')
;

select I.CLAIM_ID,
       c.name,
       I.DOCUMENT_ID,
       I.nom_doc,
       I.FSCLIENTID,
       I.FULLNAME,
       C.LAST_STATE_ID as LAST_STATE_ID_rec,
       DOC.LAST_STATE_ID,
       I.LAST_STATE_ID as LAST_STETE_ID_INTER,
       C.CLAIMER_TYPE_ID,
       C.HAZARD_LEVEL_ID,
       C.TYPE_ID as type_rec,
       I.NRO_CAMP,
       I.IVR_NOTES,
       I.LAST_ACTION,
       i.tel_camp,
       (select count(*) from NEXUS_GIS.OMS_CUST_SITUATION_INTERF where document_id =i.DOCUMENT_ID and nro_camp= i.nro_camp) as cant_rec_doc,
       (select count(*) from NEXUS_GIS.OMS_CLAIM where property_value= I.FSCLIENTID and id < I.CLAIM_ID and trunc(creation_time)>trunc(sysdate-7)) as rec_Ant,
       RC.RECREITERATIONS,
       DOC.TYPE_ID as type_doc,DOC.IS_GROUPED,
       nvl((select STATE_ID from nexus_gis.OMS_ANOMALY where DOCUMENT_ID = i.DOCUMENT_ID and rownum < 2),0)as anomaly,
       (select count(*)from nexus_gis.sprobjects ob,nexus_gis.oms_operation o, nexus_gis.sprgoperations ope
                      where o.operation_model_id = ope.operationid
                        and ob.objectid = ope.objectid
                        and ope.intprocid = 0 and ope.statustype = 1
                        and o.document_id = i.DOCUMENT_ID
                        and ope.operationdate = (select max(ope1.operationdate)
                                                   from nexus_gis.sprobjects ob1,nexus_gis.oms_operation o1, nexus_gis.sprgoperations ope1
                                                  where o1.operation_model_id = ope1.operationid
                                                    and ob1.objectid = ope1.objectid
                                                    and ope1.intprocid = 0
                                                    and ope1.statustype = 1
                                                    and o1.document_id= o.document_id
                                                    and ope.objectid = ope1.objectid )
                        and ope.status <> ob.normalstate) as maniobras,
       (select count(*) from nexus_gis.oms_document od,
           nexus_gis.oms_affect_restore_operation op,
           nexus_gis.oms_affected_element ae
     where od.id = i.DOCUMENT_ID
       and od.ID = op.DOCUMENT_ID
       and op.ID = ae.AFFECT_ID
       and ae.RESTORE_ID is null) as afectaciones
  from NEXUS_GIS.OMS_CUST_SITUATION_INTERF i,
       NEXUS_GIS.OMS_CLAIM c,
       NEXUS_GIS.DSCCRECLAIMS rc,
       NEXUS_GIS.OMS_DOCUMENT doc
 where I.CLAIM_ID = C.ID
   and RC.FSCLIENTID = i.FSCLIENTID
   and c.PROPERTY_VALUE = RC.FSCLIENTID
   and c.NAME = RC.RECLAIMID
   AND DOC.ID = I.DOCUMENT_ID
   and doc.id = 9161923
   AND I.NRO_CAMP =2871
 order by I.NOM_DOC asc;


SELECT COUNT (C.DOCUMENT_ID) 
--INTO V_RETORNO 
from  NEXUS_GIS.OMS_CLAIM c, NEXUS_GIS.SPRCLIENTS i
	where i.FSCLIENTID = c.PROPERTY_VALUE
	and i.LOGIDTO = 0
	and i.FARETYPECODEID in (
	select CODEID from NEXUS_GIS.SPRGCODES where CODETYPEID = 23 and FSCODE in ('2','3BT'))
	and i.LOGIDTO = 0
	AND I.VOLTAGE <= 380 
	and c.DOCUMENT_ID = 9161918;





  
  SELECT * FROM NEXUS_GIS.OMS_CUST_SITUATION_INTERF where document_id=9161923;
  
    SELECT id, name, type_id FROM NEXUS_GIS.oms_document where id=9161923;
    
    
    select * from nexus_gis.OMS_ANOMALY where document_id=9161923;
    
select count(*)from nexus_gis.sprobjects ob,nexus_gis.oms_operation o, nexus_gis.sprgoperations ope
                      where o.operation_model_id = ope.operationid
                        and ob.objectid = ope.objectid
                        and ope.intprocid = 0 and ope.statustype = 1
                        and o.document_id = 9161923
                        and ope.operationdate = (select max(ope1.operationdate)
                                                   from nexus_gis.sprobjects ob1,nexus_gis.oms_operation o1, nexus_gis.sprgoperations ope1
                                                  where o1.operation_model_id = ope1.operationid
                                                    and ob1.objectid = ope1.objectid
                                                    and ope1.intprocid = 0
                                                    and ope1.statustype = 1
                                                    and o1.document_id= o.document_id
                                                    AND OPE.OBJECTID = OPE1.OBJECTID )
                        and ope.status <> ob.normalstate;
  
  
  
  --if RG.hazard_level_id <> 10700 and RG.hazard_level_id <> 10703 then
  
  select hazard_level_id, LAST_STATE_ID, CLAIMER_TYPE_ID from NEXUS_GIS.OMS_CLAIM c where document_id=9161923;
  
 SELECT LAST_STATE_ID, IVR_NOTES FROM NEXUS_GIS.OMS_CUST_SITUATION_INTERF where document_id=9161923;

select count(*) from NEXUS_GIS.OMS_CUST_SITUATION_INTERF where document_id =9161923 and nro_camp= 2871;
  