select trim(lt.linkvalue) trafo, ca.*
from 
  nexus_gis.nbm_relation r, 
  nexus_gis.sprobjects oc, 
  nexus_gis.sprlinks lc, 
  nexus_gis.sprobjects ot, 
  nexus_gis.sprlinks lt, 
  nexus_gis.tmp_cadena_ct ca
where
      1=1
  and lc.objectid=oc.objectid
  and oc.objectnameid=r.object_name_id_to
  and r.object_name_id_from=ot.objectnameid
  and ot.objectid=lt.objectid
  and substr(lt.linkvalue,1,instr(lt.linkvalue,'-')-1)=ca.codigoct(+)
  and r.configuration_id = 1 and r.status = 0
  and lc.logidto=0 and lc.linkid=407
  and oc.sprid=190 and oc.logidto=0
  and ot.sprid=1170 and ot.logidto=0
  and lt.logidto=0 and lt.linkid=611
  and lc.linkvalue in ('0068834943');
  
  
select * from NEXUS_GIS.nbm_relation_configuration
where 1=1 --configuration_id=1
and sprid_from=190
;

--41 relaciona 1113 con 1170 con red normal
--47 relaciona 190 a 1113 con red normal

select * from NEXUS_GIS.nbm_configuration

;

select * from all_tables where table_name like '%ent%';

