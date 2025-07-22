-- clientes EDP que le falte ct, alim o ssee en ccyb/gelec
set serveroutput on;
declare
	cursor c_clientes is
		select cc.cuenta, cc.ct
		from NEXUS_GIS.SPRCLIENTS cl left join NEXUS_CCYB.CLIENTES_CCYB cc 
    on cl.fsclientid=cc.cuenta
		where 
      cc.fechabaja>sysdate
      and cl.custatt16 = '1A'
      and cl.custatt21 = '12521' 
    ;
      
  v_ct nexus_gis.tmp_cadena_ct.codigoct%type;
  v_tmp CHAR(30 BYTE);

begin
  dbms_output.put_line('Faltantes en cadena de red');
  dbms_output.put_line('------------------------------');
	dbms_output.put_line('cuenta;ct_ccyb;cuenta_find;ct_find;estado');
	for r_cliente in c_clientes loop
      begin
          v_tmp:= r_cliente.cuenta;
          --busca x cuenta
          select ct.codigoct
          into v_ct
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
          and c.cuenta= v_tmp
          ;    
    exception
      when no_data_found then
        --dbms_output.put_line('No encontro datos!');
        null;
    end;    
    
    if v_ct= r_cliente.ct then
      dbms_output.put_line(r_cliente.cuenta||';'||r_cliente.ct||';'||to_char(r_cliente.cuenta)||';'||v_ct||';'||'Ok');
    else
      dbms_output.put_line(r_cliente.cuenta||';'||r_cliente.ct||';'||to_char(r_cliente.cuenta)||';'||v_ct||';'||'Diferentes');
    end if;
  

	end loop;

end;

--select * from nexus_gis.sprclients where fsclientid='8286272085' ;
--select * from nexus_ccyb.clientes_ccyb where cuenta='8286272085';
