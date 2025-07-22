select * from all_tables where owner='GELEC';
select * from all_tables where owner='NEXUS_CCYB';
select * from all_tables where owner='NEXUS_GIS';

select * from NEXUS_GIS.afectacion_ct;
select * from NEXUS_CCYB.cadena_ct;

select * from NEXUS_CCYB.clientes_ccyb;
select cuenta, fechabaja, ssee, alimentador, ct from NEXUS_CCYB.clientes_ccyb where (ssee is null or alimentador is null or ct is null) and fechabaja>=sysdate;
select cuenta, ssee, alimentador, ct from NEXUS_CCYB.clientes_ccyb;
select cuenta, ssee, alimentador, ct from NEXUS_CCYB.clientes_ccyb where ssee is not null;
select cuenta, ssee, alimentador, ct from NEXUS_CCYB.clientes_ccyb where cuenta = '8101663568';
select cuenta, ssee, alimentador, ct from NEXUS_CCYB.clientes_ccyb where cuenta = '2799897065';
select cuenta, ssee, alimentador, ct from NEXUS_CCYB.clientes_ccyb where cuenta = '7047289386';

select cuenta, ssee, alimentador, ct from gelec.ed_clientes where cuenta = '8101663568';
select cuenta, ssee, alimentador, ct from gelec.ed_clientes where cuenta = '2799897065';
select cuenta, ssee, alimentador, ct from gelec.ed_clientes where cuenta = '7047289386';




select * from GELEC.ED_CLIENTES where cuenta = '2799897065';
 
select * from all_tables where owner='GELEC';
select * from all_tables where owner='NEXUS_CCYB';


select * from all_tables order by owner;

