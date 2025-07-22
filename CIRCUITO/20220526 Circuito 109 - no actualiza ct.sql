/*
9174294463
cromo: 1742
gelec: 1102
ccyb: 1102
sprlinks: 1742
*/

select * from NEXUS_CCYB.clientes_ccyb where cuenta='9174294463';
select * from NEXUS_GIS.sprlinks where linkvalue='9174294463' and logidto=0 and linkid=407; --sprlinks.linkvalue=9174294463, sprlinks.objectid= 6681645
select * from NEXUS_GIS.sprobjects where objectid=6681645;  -- sprobject.objectid= 6681645

select * from NEXUS_GIS.nbm_relation where object_name_id_to=6681645; --nbm_relation.object_name_id_from=85162745, nbm_relation.configuration_id= 1

select * from NEXUS_GIS.sprobjects where objectid=85162745;
select * from NEXUS_GIS.sprlinks where objectid=17470727 and logidto=0 and linkid=611; 

--

select * from all_tables where owner='NEXUS_GIS' and table_name like '%CONF%';
select * from NEXUS_GIS.NBM_CONFIGURATION WHERE CONFIGURATION_ID IN (1, 32, 48);


/*
4870189480
cromo: 54080
gelec: 50948
ccyb: 50948
sprlinks: 54080
*/
select * from NEXUS_CCYB.clientes_ccyb where cuenta='4870189480';

select * from NEXUS_GIS.sprlinks where linkvalue='4870189480' and logidto=0 and linkid=407;
select * from NEXUS_GIS.sprobjects where objectid=32385278;

select * from NEXUS_GIS.nbm_relation where object_name_id_to=31888752;

select * from NEXUS_GIS.sprobjects where objectid=17670827;
select * from NEXUS_GIS.sprlinks where objectid=17670827 and logidto=0 and linkid=611; 

select * from all_tables where owner='NEXUS_GIS' and table_name like '%CONF%';
select * from NEXUS_GIS.NBM_CONFIGURATION WHERE CONFIGURATION_ID IN (1, 32, 48);


select * from NEXUS_GIS.nbm_relation where object_name_id_to in (84305847); 
select * from nexus_gis.tmp_cadena_ct where codigoct in ('1742','1102');
select * from nexus_gis.tmp_cadena_ct where codigoct in ('54080','50948');

select * from NEXUS_CCYB.cadena_ct;

select * from nexus_gis.sprtopology where objectidfrom=6681645;
select * from NEXUS_GIS.sprobjects where objectid=32385279;
select * from NEXUS_GIS.sprlinks where objectid=32385279;


/*
1413760448
cromo: 53209
gelec: 53209
ccyb: 53209
sprlinks: 53209
*/

select * from NEXUS_CCYB.clientes_ccyb where cuenta='1413760448';
select * from NEXUS_GIS.sprlinks where linkvalue='9174294463' and logidto=0 and linkid=407; --sprlinks.linkvalue=9174294463, sprlinks.objectid= 6681645
select * from NEXUS_GIS.sprobjects where objectid=6681645;  -- sprobject.objectid= 6681645

select * from NEXUS_GIS.nbm_relation where object_name_id_to=6681645; --nbm_relation.object_name_id_from=85162745, nbm_relation.configuration_id= 1

select * from NEXUS_GIS.sprobjects where objectid=85162745;
select * from NEXUS_GIS.sprlinks where objectid=85162745 and logidto=0 and linkid=611; 



/*
8583310224
cromo: 8055
gelec: 
ccyb: 8055
sprlinks: 8055-TR1
*/

select cuenta, ssee, alimentador, ct from NEXUS_CCYB.clientes_ccyb where cuenta='8583310224';
--
select * from NEXUS_GIS.sprlinks where linkvalue='8583310224' and logidto=0 and linkid=407; --sprlinks.linkvalue=9174294463, sprlinks.objectid= 6681645
select * from NEXUS_GIS.sprobjects where objectid=12116642;  -- sprobject.objectid= 6681645
select * from NEXUS_GIS.nbm_relation where object_name_id_to=12116642; --nbm_relation.object_name_id_from=85162745, nbm_relation.configuration_id= 1
select * from NEXUS_GIS.sprobjects where objectid=17809175;
select * from NEXUS_GIS.sprlinks where objectid=17809175 and logidto=0 and linkid=611; 

/*
3753181490
cromo: 
gelec: 
ccyb: 
sprlinks: 
*/

select * from NEXUS_CCYB.clientes_ccyb where cuenta='1413760448';
select * from NEXUS_GIS.sprlinks where linkvalue='9174294463' and logidto=0 and linkid=407; --sprlinks.linkvalue=9174294463, sprlinks.objectid= 6681645
select * from NEXUS_GIS.sprobjects where objectid=6681645;  -- sprobject.objectid= 6681645

select * from NEXUS_GIS.nbm_relation where object_name_id_to=6681645; --nbm_relation.object_name_id_from=85162745, nbm_relation.configuration_id= 1

select * from NEXUS_GIS.sprobjects where objectid=85162745;
select * from NEXUS_GIS.sprlinks where objectid=85162745 and logidto=0 and linkid=611; 

/*
1461000000
ccyb: 19778
gelec: 
topology: 19778-TR1
sprlinks: 5256
cromo: 5256
*/

select cuenta, ssee, alimentador, ct from NEXUS_CCYB.clientes_ccyb where cuenta='1461000000';
--
select * from NEXUS_GIS.sprlinks where linkvalue='1461000000' and logidto=0 and linkid=407; --sprlinks.linkvalue=9174294463, sprlinks.objectid= 6681645
select * from NEXUS_GIS.sprobjects where objectid=78679202;
select * from NEXUS_GIS.nbm_relation where object_name_id_to=13207419;
select * from NEXUS_GIS.sprobjects where objectid=17707739;
select * from NEXUS_GIS.sprlinks where objectid=17707739 and logidto=0 and linkid=611; 

-------------------------------

select cue.cuenta, ctr.linkvalue from
(select t2.topologyid,l1.objectid, cl.cuenta --trim(l1.linkvalue)
from nexus_gis.sprlinks l1, nexus_ccyb.clientes_ccyb cl, nexus_gis.sprtopology t2
where l1.linkid = 407
and l1.linkvalue = rpad(cl.cuenta,30)
and cl.fechabaja > sysdate
and l1.logidto = 0
and t2.topologytype = 104
and t2.objectidfrom = l1.objectid
and t2.logidto = 0
and cl.cuenta=9174294463
--and t2.topologyid = (select max(tt.topologyid) from nexus_gis.sprtopology tt where tt.objectidfrom = l1.objectid and tt.topologytype = 104)
) cue
,(select t1.topologyid,l1.objectid, trim(l1.linkvalue) linkvalue
from nexus_gis.sprlinks l1, nexus_gis.sprtopology t1
where l1.linkid = 611
and l1.logidto = 0
and t1.topologytype = 104
and t1.objectidto = l1.objectid
and t1.logidto = 0) ctr
, nexus_gis.sprtopology t3
where t3.topologyid = ctr.topologyid
and t3.topologyid = cue.topologyid
minus
select cuenta, ct||'-'||codtrafo from nexus_ccyb.clientes_ccyb;