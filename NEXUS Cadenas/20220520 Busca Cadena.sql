--busca x cttrafo
select cuenta, codigossee, codigoalim, codigoct, cttrafo
from
nexus_gis.nbm_relation r, 
(select trim(l.linkvalue) ct, o.objectnameid from nexus_gis.sprlinks l, nexus_gis.sprobjects o where l.objectid=o.objectid and l.logidto=0 and l.linkid=611) t, 
(select l.linkvalue cuenta, o.objectnameid from nexus_gis.sprlinks l, nexus_gis.sprobjects o where l.objectid=o.objectid and l.logidto=0 and l.linkid=407) c, 
(select ct.codigossee, ct.codigoalim, ct.codigoct, ct.cttrafo from nexus_gis.tmp_cadena_ct ct) ct
where
r.object_name_id_from=t.objectnameid and
r.object_name_id_to=c.objectnameid and
t.ct=ct.cttrafo and 
r.configuration_id = 1 and 
r.status = 0 and
ct.cttrafo='17324-TR1'
;

--busca x cuenta
select c.cuenta, ct.codigossee, ct.codigoalim, ct.codigoct, ct.cttrafo
from
nexus_gis.nbm_relation r, 
(select trim(l.linkvalue) ct, o.objectnameid from nexus_gis.sprlinks l, nexus_gis.sprobjects o where l.objectid=o.objectid and l.logidto=0 and l.linkid=611) t, 
(select l.linkvalue cuenta, o.objectnameid from nexus_gis.sprlinks l, nexus_gis.sprobjects o where l.objectid=o.objectid and l.logidto=0 and l.linkid=407) c, 
(select ct.codigossee, ct.codigoalim, ct.codigoct, ct.cttrafo from nexus_gis.tmp_cadena_ct ct) ct
where
r.object_name_id_from=t.objectnameid 
and r.object_name_id_to=c.objectnameid 
and t.ct=ct.cttrafo 
and r.configuration_id = 1 
and r.status = 0 
and rownum=1
and
--c.cuenta in ('7047289386','8101663568','2799897065')
c.cuenta in ('1461000000')
;


--busca cadena original
select
  (select trim(linkvalue) from nexus_gis.sprlinks where logidto = 0 and linkid = 611 and objectid = 
    (select objectid from nexus_gis.sprobjects where sprid = 1170 and logidto = 0 and objectnameid = object_name_id_from)) object_from,
  (select max(trim(linkvalue)) from nexus_gis.sprlinks where logidto = 0 and linkid = 407 and objectid = 
    (select objectid from nexus_gis.sprobjects where sprid = 190 and logidto = 0 and objectnameid = object_name_id_to)) object_to,
  nbm_relation.*
from nexus_gis.nbm_relation 
where configuration_id = 1 and status = 0 and object_name_id_to = (
select objectnameid from nexus_gis.sprobjects where logidto = 0 and sprid = 190 and objectid =
(select objectid from nexus_gis.sprlinks where logidto = 0 and linkid = 407 and linkvalue = '2799897065')); --6934000000

