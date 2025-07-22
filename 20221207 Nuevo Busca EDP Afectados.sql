SET SERVEROUTPUT ON
DECLARE
--        select id from nexus_gis.oms_document where name='D-22-12-016734';

    CURSOR C_OBJETOS 
    IS (
        select 
            C.DOCUMENT_ID, 
            C.TIME INICIO, 
            A.ID ID_AFECTACION, 
            B.OBJECTNAMEID
        from 
            NEXUS_GIS.OMS_AFFECTED_ELEMENT a,
            (select objectid, objectnameid from nexus_gis.sprobjects where sprid=1293 and logidto=0) b,
            NEXUS_GIS.oms_affect_restore_operation c
        WHERE 
            1=1
--            and a.is_affected=1
            and a.element_id=b.objectnameid
            and a.affect_id=c.id
            and c.operation_id is not null
            and c.document_id in(SELECT AFFECT_DOCUMENT_ID FROM NEXUS_GIS.NBM_MON_ELEMENT)
    );
        
    CURSOR C_CLIENTES (MYOBJECTNAMEID NUMBER)
    IS (
        SELECT 
          d.fsclientid cuenta, d.fullname razon_social
        FROM 
          NEXUS_GIS.NBM_RELATION A, 
          NEXUS_GIS.SPROBJECTS B, 
          NEXUS_GIS.SPRLINKS C, 
          nexus_gis.sprclients D
        WHERE 
          A.CONFIGURATION_ID=47 
          AND A.OBJECT_NAME_ID_FROM=B.OBJECTNAMEID 
          AND B.LOGIDTO=0 AND B.SPRID=190 
          AND B.OBJECTID=C.OBJECTID 
          AND C.LOGIDTO=0 
          AND C.LINKID=407 
          and a.object_name_id_to in (
              SELECT B.OBJECTNAMEID 
              FROM NEXUS_GIS.SPRLINKS A, NEXUS_GIS.SPROBJECTS B, NEXUS_GIS.NBM_RELATION C 
              WHERE A.LINKID=410 
              AND A.OBJECTID=B.OBJECTID 
              and b.sprid=1113
              AND B.OBJECTNAMEID=C.OBJECT_NAME_ID_FROM 
              and c.configuration_id=41
              and a.logidto=0 and b.logidto=0
              and c.object_name_id_to = (
                  select d.objectnameid
                  FROM NEXUS_GIS.SPROBJECTS A, NEXUS_GIS.SPRLINKS B, NEXUS_GIS.SPRLINKS C, NEXUS_GIS.SPROBJECTS D
                  WHERE 1=1
                  AND A.OBJECTNAMEID=MYOBJECTNAMEID 
                  AND A.SPRID=1293 
                  and a.logidto=0
                  AND A.OBJECTID=B.OBJECTID 
                  AND B.LINKID=1018 
                  and b.logidto=0
                  AND B.LINKVALUE=C.LINKVALUE 
                  AND C.LOGIDTO=0 
                  AND C.LINKID=611
                  AND C.OBJECTID=D.OBJECTID 
                  AND D.LOGIDTO=0 
                  AND D.SPRID=1170
              )
          )
        --  AND C.OBJECTID=to_number(D.CUSTATT2)
          and trim(c.linkvalue)=d.fsclientid
          AND D.CUSTATT16='1A'
          AND D.CUSTATT21=12521    
          AND D.LOGIDTO=0
    );
        
BEGIN

    FOR F_OBJETOS IN C_OBJETOS LOOP
        FOR F_CLIENTES IN C_CLIENTES(F_OBJETOS.OBJECTNAMEID) LOOP
            DBMS_OUTPUT.PUT_LINE(F_CLIENTES.cuenta);
        
        end loop;    
    END LOOP;
    
END;















