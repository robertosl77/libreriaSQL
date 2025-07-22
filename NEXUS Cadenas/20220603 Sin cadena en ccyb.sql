-- clientes EDP que le falte ct, alim o ssee en ccyb/gelec
set serveroutput on;
declare
	cursor c_clientes is
		select cc.cuenta, cc.ct, cc.alimentador, cc.ssee
		from NEXUS_GIS.SPRCLIENTS cl left join NEXUS_CCYB.CLIENTES_CCYB cc 
    on cl.fsclientid=cc.cuenta
		where 
      cc.fechabaja>sysdate
      and (cc.ct is null or cc.alimentador is null or cc.ssee is null)
      --and cl.custatt16 = '1A'
      --and cl.custatt21 = '12521' 
      --and cc.cuenta='3488805583'
      --order by cc.ct desc
      --and cc.cuenta in (select linkvalue from nexus_gis.sprlinks)
      --and rownum<=10
    ;
  
  v_tmp CHAR(30 BYTE);
  v_cu nexus_ccyb.clientes_ccyb.cuenta%type;
  v_ct nexus_ccyb.clientes_ccyb.ct%type;
  v_al nexus_ccyb.clientes_ccyb.alimentador%type;
  v_se nexus_ccyb.clientes_ccyb.ssee%type;

begin
  dbms_output.put_line('Faltantes en cadena de red');
  dbms_output.put_line('------------------------------');
	dbms_output.put_line('cuenta; ct; alim; ssee');
	for r_cliente in c_clientes loop
		if r_cliente.ssee is null or r_cliente.alimentador is null or r_cliente.ct is null then
			begin
        begin
          v_tmp:= r_cliente.cuenta;
          --
          select lc.linkvalue cuenta, ca.codigoct, ca.codigoalim, ca.codigossee
          into v_cu, v_ct, v_al, v_se
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
            and lc.linkvalue= v_tmp
          ;
          
        exception
          when no_data_found then
            v_cu:=null;
        end;    
        
        if v_cu is null then
  				dbms_output.put_line(r_cliente.cuenta||';'||r_cliente.ct||';'||r_cliente.alimentador||';'||r_cliente.ssee);
        else  
          dbms_output.put_line(v_cu||';'||v_ct||';'||v_al||';'||v_se);
        end if;
        
			exception
				when no_data_found then	
					dbms_output.put_line('No encontro datos!');
			end;
		end if;
	end loop;

end;

--select * from NEXUS_GIS.sprclients;
--select * from nexus_gis.sprlinks;
--select * from nexus_gis.tmp_cadena_ct;
--select * from nexus_gis.sprclients where fsclientid='3488805583';
--select * from nexus_ccyb.clientes_ccyb where cuenta='0000837919';

--select * from NEXUS_GIS.sprlinks where linkvalue='0000837919' and logidto=0 and linkid=407;
--select * from NEXUS_GIS.sprobjects where objectid=84556027;
--select * from NEXUS_GIS.nbm_relation where object_name_id_to=84556027;
--select * from NEXUS_GIS.sprobjects where objectid=17757961;
--select * from NEXUS_GIS.sprlinks where objectid=17757961 and logidto=0 and linkid=611; 

