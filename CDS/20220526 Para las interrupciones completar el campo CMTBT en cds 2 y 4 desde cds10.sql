--Para las interrupciones completar el campo CMTBT en cds 2 y 4 desde cds10
set serveroutput on size unlimited
declare

	cursor tabla is
		select * from sisenre.cds2 
		where ref in ('BFZ202205051932', 'BFZ202205051937', 'BFZ202205051940') 
		and nvl(operacion,'X') <>'B';
	
	v_pol sisenre.cds9.pol%type;
	v_ct  varchar2(50);
	v_usuario sisenre.cds2.usuario%type: 'SEMD_004';

begin
	for cur in tabla loop
		begin
			select pol into v_pol  from sisenre.cds9
			where ref= cur.ref
			and nvl(operacion,'X')<>'B'
			and rownum=1;
		
		exception
			when no_data_found then	
				dbms_output.put_line('No encuentra en t9');
		
		end;
		
		begin
			select substr(cen_mtbt,1,instr(cen_mtbt,'TR')+2) into v_ct from sisenre.cds10_sem
			where periodo='SEM_51'
			and id_usuar= v_pol
			and nvl(operacion,'X')<>'B';
			
			-- hacer el update en t2 y t4
			--dbms_output.put_line(cur.ref||''||v_ct);
			
			update sisenre.cds2 
			set 
				usuario= v_usuario, 
				fecha_oper= sysdate, 
				operacion= 'M', 
				cmtbt= v_ct
			where ref= cur.ref
			and nvl(operacion,'X')<>'B';
			
			update sisenre.cds4 
			set 
				usuario= v_usuario, 
				fecha_oper= sysdate, 
				operacion= 'M', 
				cmtbt= v_ct
			where ref= cur.ref
			and nvl(operacion,'X')<>'B';			
			
		exception
			when no_data_found then
				dbms_output.put_line('No se encuentra en t10');
		
		end;
	end loop;
end;