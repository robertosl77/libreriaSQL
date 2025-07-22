set SERVEROUTPUT ON;
declare

    cursor c_columns is 
        select a.owner, a.table_name, b.column_name, b.num_distinct
        from all_tables a, all_tab_columns b
        where 
        1=1
        and a.owner ='GELEC' 
        and a.owner=b.owner 
        and a.table_name like '%CLIENTE%' 
        and a.table_name=b.table_name 
        and a.num_rows>0 
        and b.num_distinct > 0 
        and b.data_type = 'VARCHAR2'  --filtra tipo de dato del campo
        order by a.owner, a.table_name, b.column_name;
    
    v_sql_o varchar2(1000) := 'select count(1) from :TABLE where :ATT like :1'; 
    v_sql_a varchar2(1000);
    
    v_str varchar2(100) := '%1525565729%';  --valor que busco
    v_control number;
    v_rows_control number := 1000000;

begin
    
    for r_columns in c_columns
    loop
        v_sql_a := replace(v_sql_o, ':TABLE', r_columns.owner || '.' || r_columns.table_name);
        v_sql_a := replace(v_sql_a, ':ATT', r_columns.column_name);
        if r_columns.num_distinct <= v_rows_control then
            execute immediate v_sql_a into v_control using v_str;
            if v_control > 0 then
                dbms_output.put_line(v_sql_a);
            end if; 
        else
            dbms_output.put_line('Row limit exceeded: ' || v_sql_a);
        end if;
    end loop;
end;

