set serveroutput on
declare

  v_min number:=1;
  v_max number:=2147483647;
  v_bus number;
  v_num number;
  v_cnt number:=0;

begin

    --v_min:=1;
    --v_max:=500000;
    v_num:=v_min;
    
    while v_num<=v_max loop
        --dbms_output.put_line(v_min);
        select count(1) into v_bus from nexus_gis.sms_log where idtransaccion= v_num;
        
        if v_bus=0 then
            v_cnt:= v_cnt+1;
        end if;
        v_num:=v_num+1;
    end loop;
    dbms_output.put_line('');
    dbms_output.put_line('De '||v_min||' a '||v_max||' hay '||v_cnt||' ids libres');


end;

--    select min(idtransaccion) from nexus_gis.sms_log;  --29139
--    select max(idtransaccion) from nexus_gis.sms_log;  --2147483632