set serveroutput on
DECLARE
	v_ssee NEXUS_CCYB.CLIENTES_CCYB.ssee%type;
	v_alim NEXUS_CCYB.CLIENTES_CCYB.alimentador%type;
	v_ct NEXUS_CCYB.CLIENTES_CCYB.ct%type;
	v_cuenta nexus_gis.sprlinks.linkvalue%type;
	a_cuentas sys.odcivarchar2list;
BEGIN
    a_cuentas := sys.odcivarchar2list(
'0309468933','0334326828','0420959652','0505087232','0507000000','0547594638','0671000000','0700213586','0731715508','1111027690',
'1113000000','1461000000','1462997480','1466000000','1515000000','1536467087','1651740406','1656000000','1704846788','1815648041',
'1925000000','2056660708','2075000000','2162000000','2219997531','2396150384','2509348320','2622638686','2714000000','2849822554',
'3053548876','3246000000','3322772905','3412000000','3540094577','3554000000','3662000000','4108000000','4194707311','4417000000',
'4463552153','4483000000','4547404507','4563000000','4662000000','4705281474','4886458268','5062788942','5260031055','5330271121',
'5526000000','5555264558','5832615709','5872968480','5950472561','6042000000','6092000000','6188679503','6263060910','6300843897',
'6392242859','6932499506','6934000000','6964725348','7027000000','7201000000','7291000000','7584402172','7870000000','8050000000',
'8140000000','8256413287','8262000000','8372000000','8583310224','8707660530','8777000000','8825000000','8880229626','8888623185',
'8903000000','8948830000','9255000000','9307829299','9633000000','9672000000','9907713139','9985184490','5308000000'
    );
    
	for case_a in (select cuenta, ssee, alimentador, ct from NEXUS_CCYB.clientes_ccyb where cuenta in (select m.column_value from table(a_cuentas) m))
	loop
		--dbms_output.put_line(case_a.cuenta || ';' || case_a.ssee || ';' || case_a.alimentador || ';' || case_a.ct);	
    
		v_cuenta := case_a.cuenta;
		
    begin
    
      select ca.codigossee, ca.codigoalim, ca.codigoct
      into v_ssee, v_alim, v_ct
      from 
        nexus_gis.nbm_relation r, 
        nexus_gis.sprobjects oc, 
        nexus_gis.sprlinks lc, 
        nexus_gis.sprobjects ot, 
        nexus_gis.sprlinks lt, 
        nexus_gis.tmp_cadena_ct ca
      where
            rownum=1
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
        and lc.linkvalue in (v_cuenta)
      ;    
        
    exception
      when no_data_found then
        v_ssee:=null;
        v_alim:=null;
        v_ct:=null;

    end;
    
    dbms_output.put_line(case_a.cuenta || ';' || v_ssee || ';' || v_alim || ';' || v_ct);

	end loop;
    
	
EXCEPTION
	when others then
		dbms_output.put_line('Ha ocurrido un error en la ejecucion: ' || sqlerrm );
    
end;