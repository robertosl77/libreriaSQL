/*
1461000000
ccyb: 19778
gelec: 
topology: 19778-TR1
sprlinks: 5256
cromo: 5256
*/

---NEXUS_GIS.SPRCLIENTS--------------------------------------------------------------------------
select fsclientid, custatt16, custatt21 from nexus_gis.sprclients where custatt16 = '1A' and custatt21 = '12521' and fsclientid='3883479936';
select fsclientid, custatt16, custatt21 from nexus_gis.sprclients where fsclientid='4517000000';

---NEXUS_CCYB.CLIENTES_CCYB----------------------------------------------------------------------
select cuenta, fechabaja, ssee, alimentador, ct from NEXUS_CCYB.clientes_ccyb where cuenta in ('6537987855');
select * from NEXUS_GIS.sprclients where fsclientid='1461000000';

---NEXUS_GIS.SPRLINKS, NEXUS_GIS.SPROBJECTS, NEXUS_GIS.NBM_RELATION------------------------------
select objectid from NEXUS_GIS.sprlinks where logidto=0 and linkid=407 and linkvalue='1113000000';
select objectnameid from NEXUS_GIS.sprobjects where sprid=190 and logidto=0 and objectid=9131324;
select object_name_id_from from NEXUS_GIS.nbm_relation where configuration_id = 1 and status = 0 and object_name_id_to=9131324;
select objectid from NEXUS_GIS.sprobjects where sprid=1170 and logidto=0 and objectid=29989560;
select substr(linkvalue,1,instr(linkvalue,'-')-1) ct from NEXUS_GIS.sprlinks where logidto=0 and linkid=611 and objectid=29989560; 
select codigossee, codigoalim, codigoct, cttrafo from nexus_gis.tmp_cadena_ct where codigoct='14748';

---NEXUS_GIS.SPRTOPOLOGY-------------------------------------------------------------------------
select lt.linkvalue trafo
from
  nexus_ccyb.clientes_ccyb cc,
  nexus_gis.sprlinks lc, 
  nexus_gis.sprtopology t, 
  nexus_gis.sprtopology tt, 
  nexus_gis.sprlinks lt
where 
  1=1
  and lc.linkvalue = rpad(cc.cuenta,30)
  and t.objectidfrom=lc.objectid
  and tt.topologyid=t.topologyid
  and lt.objectid=tt.objectidto
  and cc.fechabaja>sysdate
  and lc.linkid=407 and lc.logidto=0
  and t.topologytype=104 and t.logidto=0
  and lt.linkid=611
  and cc.cuenta='0068834943'
;

select t2.topologyid,l1.objectid, cl.cuenta --trim(l1.linkvalue)
from 
  nexus_gis.sprlinks l1, 
  nexus_ccyb.clientes_ccyb cl, 
  nexus_gis.sprtopology t2
where l1.linkid = 407
  and l1.linkvalue = rpad(cl.cuenta,30)
  and cl.fechabaja > sysdate
  and l1.logidto = 0
  and t2.topologytype = 104
  and t2.objectidfrom = l1.objectid
  and t2.logidto = 0
  and cl.cuenta='5308000000';
 
select * from nexus_gis.sprtopology where topologyid=64922928;
select * from nexus_gis.sprlinks where objectid=17533625 and linkid=611;



---BUSCA POR CUENTA EN SPRTOPOLOGY CON CADENA_CT-------------------------------------------------
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
  and lc.linkvalue in ('0068834943')
;

---BUSCA POR CUENTA EN NBM_RELATION--------------------------------------------------------------
select lt.linkvalue trafo
from 
  nexus_gis.nbm_relation r, 
  nexus_gis.sprobjects oc, 
  nexus_gis.sprlinks lc, 
  nexus_gis.sprobjects ot, 
  nexus_gis.sprlinks lt
where
      1=1
  and lc.objectid=oc.objectid
  and oc.objectnameid=r.object_name_id_to
  and r.object_name_id_from=ot.objectnameid
  and ot.objectid=lt.objectid
  and r.configuration_id=1 and r.status=0
  and lc.logidto=0 and lc.linkid=407
  and oc.sprid=190 and oc.logidto=0
  and ot.sprid=1170 and ot.logidto=0
  and lt.logidto=0 and lt.linkid=611
  and lc.linkvalue in ('0068834943')
;

---BUSCA POR CUENTA ORIGINAL DE IVAN INNUSO------------------------------------------------------
select
  (select trim(linkvalue) from nexus_gis.sprlinks where logidto = 0 and linkid = 611 and objectid = (select objectid from nexus_gis.sprobjects where sprid = 1170 and logidto = 0 and objectnameid = object_name_id_from)) object_from,
  --(select max(trim(linkvalue)) from nexus_gis.sprlinks where logidto = 0 and linkid = 407 and objectid = (select objectid from nexus_gis.sprobjects where sprid = 190 and logidto = 0 and objectnameid = object_name_id_to)) object_to,
  nbm_relation.*
from nexus_gis.nbm_relation 
where configuration_id = 1 and status = 0 and object_name_id_to = (
select objectnameid from nexus_gis.sprobjects where logidto = 0 and sprid = 190 and objectid =
(select objectid from nexus_gis.sprlinks where logidto = 0 and linkid = 407 and linkvalue = '0068834943')); 
