set SERVEROUTPUT ON
declare

cursor c_delivery_point is select objectid
from NEXUS_GIS.sprobjects
where sprid=190 and logidto=0;

v_control number := 0;

begin

dbms_output.put_line('objectid');

for r_delivery_point in c_delivery_point loop

    begin
    
        select count(distinct linkvalue) into v_control
        from (select 'nbm_relation' tabla, a.object_name_id_from, a.object_name_id_to, c.linkvalue, b.linkvalue cuenta
        from NEXUS_GIS.nbm_relation a, NEXUS_GIS.sprlinks b, NEXUS_GIS.sprlinks c
        where --b.linkvalue='5582389307' and
        a.object_name_id_to=r_delivery_point.objectid and
        a.object_name_id_to=b.objectid
        and a.object_name_id_from=c.objectid
        and b.linkid=407 and b.logidto=0
        and c.linkid=611 and c.logidto=0
        union
        select 'sprtopology' tabla, a.objectidfrom, a.objectidto, c.linkvalue, b.linkvalue cuenta
        from nexus_gis.sprtopology a, NEXUS_GIS.sprlinks b, NEXUS_GIS.sprlinks c
        where --b.linkvalue='5582389307' and 
        a.logidto=0 and a.topologytype=104
        and a.objectidfrom=r_delivery_point.objectid
        and a.objectidfrom=b.objectid
        and b.linkid=407 and b.logidto=0
        and a.objectidto=c.objectid
        and c.linkid=611 and c.logidto=0) d
        --where d.cuenta=r_relation.linkvalue
        ;

    end;
    
    if v_control > 1 then
        dbms_output.put_line(r_delivery_point.objectid);
    end if;
    
end loop;
end;