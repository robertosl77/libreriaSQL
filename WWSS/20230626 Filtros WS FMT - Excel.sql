SET SERVEROUTPUT ON 
declare
    CURSOR C_MODELO IS 
        SELECT 
            D.ID,
            D.NAME,
            DECODE(IS_FORCED, 0,'PROGRAMADO','FORZADO') ORIGEN,
            ARO.TIME AS FECHA_DOCUMENTO,
            DS.DESCRIPTION AS ESTADO,
            AE.ELEMENT_ID ELEMENT_ID,
            (SELECT SUBSTR(TRIM(LINKVALUE), 4) FROM NEXUS_GIS.SPRLINKS WHERE OBJECTID = ae.element_id AND LINKID = 1198 AND ROWNUM=1) CT_AFECTADO,
--            S.OBJECTID,
            AE.COUNT_PROPERTIES CANT_AFECTACIONES,
            AE.AFFECT_ID,
            D.LAST_STATE_ID,
--            D.ESTIMATED_RESTORATION_TIME FECHA_NORM_PREVISTA,
--            DECODE(D.TYPE_ID ,3,'MT',4,'MT',5,'AT',6,'AT') SISTEMA,
--            D.MODEL_ELEMENT_CHAIN CAD_ELECTRICA,
--            DECODE(D.TYPE_ID ,3,'MT Forzada',4,'MT Forzada',5,'AT',6,'AT') MOTIVO,
            D.OWNER_GROUP 
            , TRUNC(((SYSDATE - ARO.TIME) * (60 * 24))) TIEMPO_AFECTADO
            , D.CREATION_TIME
            , (SELECT EVENTO_CONFIRMADO FROM NEXUS_GIS.IDMS_DOCUMENTO_INFO WHERE ID_DOCUMENTO = D.ID) CONFIRMADO
            , CASE WHEN (SELECT COUNT(1) FROM NEXUS_GIS.TABLA_ENREMTAT_GEN WHERE NRO_DOCUMENTO= D.NAME)>0 THEN 1 ELSE 0 END GEN
            , CASE WHEN (SELECT COUNT(1) FROM NEXUS_GIS.TABLA_ENREMTAT_DET WHERE NRO_DOCUMENTO= D.NAME)>0 THEN 1 ELSE 0 END DET
            , (SELECT  NVL(D.COUNT_INIT_AFFECTED_CUSTOMERS, D.AFFECTED_CLIENTS) AS COUNT_AFFECTED FROM NEXUS_GIS.OMS_DOCUMENT OD WHERE OD.ID=D.ID) COUNT_AFFECTED
            , ARO.IS_RESTORE
        FROM 
            NEXUS_GIS.OMS_DOCUMENT D,
            NEXUS_GIS.OMS_DOCUMENT_TYPE DT,
            NEXUS_GIS.OMS_DOCUMENT_STATE DS,
            NEXUS_GIS.SPROBJECTS S,
            NEXUS_GIS.OMS_OPERATION OO,
            NEXUS_GIS.SPRGOPERATIONS SO,
            NEXUS_GIS.OMS_AFFECT_RESTORE_OPERATION ARO,
            NEXUS_GIS.OMS_AFFECTED_ELEMENT AE
        WHERE 
            1=1
            AND OO.DOCUMENT_ID = D.ID
            AND DT.ID = D.TYPE_ID
            AND DS.ID = D.LAST_STATE_ID
            AND OO.OPERATION_MODEL_ID = SO.OPERATIONID
            AND S.OBJECTID = AE.ELEMENT_ID
            AND OO.ID = ARO.OPERATION_ID
            AND ARO.ID = AE.AFFECT_ID
            AND SO.LOGIDTO = 0
            AND D.TYPE_ID IN (3)
--            AND ARO.IS_RESTORE = 0
--            AND D.LAST_STATE_ID>1
--            AND D.LAST_STATE_ID<5
--            AND ((SYSDATE - ARO.TIME) * (60 * 24))>=5
            AND D.NAME NOT IN (SELECT NRO_DOCUMENTO FROM NEXUS_GIS.TABLA_ENREMTAT_DET)
            AND TRUNC(D.CREATION_TIME)>=TRUNC(SYSDATE)-1
--            AND ROWNUM<100
        ORDER BY 1;    
        
    V_CONCLUSION VARCHAR(100);
    V_STREETID NUMBER;
    V_DELTA VARCHAR2(200):= NULL;
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('DOCUMENTO,ORIGEN,FECHA_CREACION,ESTADO,GEN,DET,CONFIRMADO,DELTA,AFFECT_ID,ELEMENT_ID,CT,TIEMPO_AFECTADO,AFECTADOS,CONCLUSION');
    --ESTE PL ANALIZA LOS MOTIVOS DE FILTRO DE LOS FORZADOS MT
    FOR M IN C_MODELO LOOP
        --BUSCO SI ES DEL DELTA
        BEGIN
            SELECT  
                (SELECT TRIM(SPRLINKS.LINKVALUE) FROM NEXUS_GIS.SPRLINKS WHERE SPRLINKS.LOGIDTO = 0 AND  SPRLINKS.LINKID = 1194 AND SPRLINKS.OBJECTID = L1.OBJECTID)
            INTO V_STREETID
            FROM NEXUS_GIS.SPRLINKS L1
            WHERE 
                L1.LOGIDTO = 0
                AND L1.LINKID = 1187
                AND L1.LINKVALUE = RPAD(TRIM(M.CT_AFECTADO),30);            
        EXCEPTION
            WHEN OTHERS THEN
                V_STREETID:=0;
        END;
        --
        BEGIN
            SELECT trim(substr(A1.AREANAME,1,5))
            INTO V_DELTA
            FROM 
                NEXUS_GIS.SMSTREETS,
                NEXUS_GIS.AMAREAS A1, 
                NEXUS_GIS.AMAREAS A2, 
                NEXUS_GIS.AMAREAS A3
            WHERE 
                A1.SUPERAREA = A2.AREAID
                AND A2.SUPERAREA = A3.AREAID
                AND A1.AREAID =  SMSTREETS.REGIONID
                AND SMSTREETS.STREETANTIQ = 0
                AND SMSTREETS.STREETDELETED = 0
                AND SMSTREETS.STREETID = V_STREETID;        
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                V_DELTA:=NULL;        
        END;
    
        --CONCLUSION
        IF M.DET=1 THEN
          NULL;

--        ELSIF M.GEN =0 AND TRUNC(M.CREATION_TIME)<>TRUNC(SYSDATE) THEN
          ELSIF M.GEN =0 THEN
            V_CONCLUSION:='FILTRA EN GEN';

        ELSIF M.ESTADO='Pendiente' THEN
            V_CONCLUSION:='ESTADO PENDIENTE';
            
        ELSIF M.LAST_STATE_ID IN (5,6) THEN
            V_CONCLUSION:='ESTADO CERRADOS';

        ELSIF M.TIEMPO_AFECTADO<5 THEN
            V_CONCLUSION:='AFECTACION <5';

        ELSIF M.IS_RESTORE=1 THEN
            V_CONCLUSION:='RESTAURADO';

        ELSIF M.CANT_AFECTACIONES=0 THEN
            V_CONCLUSION:='SIN AFECTACION';

        ELSIF LENGTH(M.CT_AFECTADO)=0 THEN
            V_CONCLUSION:='SIN CT';

        ELSIF NOT (M.CONFIRMADO=1 OR V_DELTA='DELTA') THEN
            V_CONCLUSION:='NO CONFIRMADO';

        ELSE
            V_CONCLUSION:= 'REVISAR MISMO CT EN OTRO DOC';
        END IF;
        --
        DBMS_OUTPUT.PUT_LINE(
                              M.NAME ||','||
                              M.ORIGEN ||','|| 
                              M.CREATION_TIME ||','|| 
                              M.ESTADO ||','|| 
                              CASE WHEN M.GEN=1 THEN 'SI' ELSE 'NO' END ||','|| 
                              CASE WHEN M.DET=1 THEN 'SI' ELSE 'NO' END ||','|| 
                              M.CONFIRMADO ||','|| 
                              V_DELTA ||','|| 
                              M.AFFECT_ID ||','|| 
                              M.ELEMENT_ID ||','|| 
                              M.CT_AFECTADO ||','|| 
                              M.TIEMPO_AFECTADO ||','|| 
                              M.CANT_AFECTACIONES ||','|| 
                              V_CONCLUSION
                              );        
    END LOOP;  
END;

  





