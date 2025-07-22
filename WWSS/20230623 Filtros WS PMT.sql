SET SERVEROUTPUT ON 
declare
    CURSOR C_MODELO IS 
        SELECT 
            OD.ID,
            OD.NAME,
            DECODE(T.IS_FORCED, 0,'PROGRAMADO','FORZADO') ORIGEN,
            -- mayo 2015 Req. 55369 GH - sw utiliza la fecha de fin afectacion individual en lugar de la del documento o gen
            ro.time as FECHA_DOCUMENTO,
            DS.DESCRIPTION ESTADO,
            AE.ELEMENT_ID ELEMENT_ID,
            SUBSTR(TRIM(LK.LINKVALUE), 4) as CT_AFECTADO,
            AE.COUNT_PROPERTIES CANT_AFECTACIONES,
            AE.AFFECT_ID,
            OD.LAST_STATE_ID,
            OD.ESTIMATED_RESTORATION_TIME FECHA_NORM_PREVISTA,
--            DECODE(od.TYPE_ID ,3,'MT',4,'MT',5,'AT',6,'AT') SISTEMA,
--            OD.MODEL_ELEMENT_CHAIN CAD_ELECTRICA,
--            DECODE(OD.TYPE_ID ,3,'MT Forzada',4,'MT Forzada',5,'AT',6,'AT') MOTIVO, 
            TRUNC(((SYSDATE - RO.TIME) * (60 * 24))) TIEMPO_AFECTADO,
            OD.CREATION_TIME, 
            (SELECT FAILURE_TYPE_ID FROM NEXUS_GIS.OMS_DOCUMENT_CAUSE WHERE DOCUMENT_ID = OD.ID) CAUSA,
            CASE WHEN (SELECT COUNT(1) FROM NEXUS_GIS.TABLA_ENREMTAT_GEN WHERE NRO_DOCUMENTO= OD.NAME)>0 THEN 1 ELSE 0 END GEN,
            CASE WHEN (SELECT COUNT(1) FROM NEXUS_GIS.TABLA_ENREMTAT_DET WHERE NRO_DOCUMENTO= OD.NAME)>0 THEN 1 ELSE 0 END DET, 
            (SELECT MAX(AFFECT_ID) FROM NEXUS_GIS.OMS_AFFECTED_ELEMENT AE1, NEXUS_GIS.OMS_AFFECT_RESTORE_OPERATION RO WHERE AE1.AFFECT_ID = RO.ID AND RO.DOCUMENT_ID = OD.ID AND AE1.ELEMENT_ID = AE.ELEMENT_ID) MAX_AFFECTID, 
            (SELECT  NVL(D.COUNT_INIT_AFFECTED_CUSTOMERS, D.AFFECTED_CLIENTS) AS COUNT_AFFECTED FROM NEXUS_GIS.OMS_DOCUMENT D WHERE D.ID=od.ID) COUNT_AFFECTED
        FROM 
            NEXUS_GIS.OMS_AFFECTED_ELEMENT AE,
            NEXUS_GIS.OMS_AFFECT_RESTORE_OPERATION RO,
            NEXUS_GIS.OMS_DOCUMENT OD,
            NEXUS_GIS.SPRLINKS LK,
            NEXUS_GIS.OMS_DOCUMENT_STATE ds,
            NEXUS_GIS.SPROBJECTS OB,
            NEXUS_GIS.TABLA_ENREMTAT_GEN MT,
            NEXUS_GIS.OMS_DOCUMENT_TYPE T
        WHERE 
            ae.is_affected IN (1,0)
            AND RO.DOCUMENT_ID = MT.id
            AND ae.affect_id = ro.id
            AND od.LAST_STATE_ID = DS.ID
            AND MT.ID = OD.ID
            AND LK.OBJECTID = ae.element_id
            AND LK.LINKID = 1198
            AND OB.OBJECTNAMEID = ae.element_id
            AND OB.LOGIDTO=0
            AND T.ID = OD.TYPE_ID
            AND od.TYPE_ID IN (4)
--            AND AE.AFFECT_ID =(
--                SELECT MAX(AFFECT_ID)
--                FROM 
--                NEXUS_GIS.OMS_AFFECTED_ELEMENT AE1,
--                NEXUS_GIS.OMS_AFFECT_RESTORE_OPERATION ro
--                WHERE 
--                AE1.AFFECT_ID = RO.ID
--                AND RO.DOCUMENT_ID = mt.id
--                AND ae1.element_id = ae.element_id)
--            AND MT.NRO_DOCUMENTO = P_NAME
--            AND ((sysdate - RO.TIME) * (60 * 24))>=5
--            AND od.last_state_id >1
--            AND OD.LAST_STATE_ID < 5
            AND OD.NAME NOT IN (SELECT NRO_DOCUMENTO FROM NEXUS_GIS.TABLA_ENREMTAT_DET)
            AND TRUNC(OD.CREATION_TIME)>=TRUNC(SYSDATE)-1
--            AND ROWNUM<10
--            AND (SELECT  NVL(D.COUNT_INIT_AFFECTED_CUSTOMERS, D.AFFECTED_CLIENTS) AS COUNT_AFFECTED FROM NEXUS_GIS.OMS_DOCUMENT D WHERE D.ID=OD.ID)=0
--            and AE.COUNT_PROPERTIES>0
        ORDER BY MT.ID, CT_AFECTADO ASC 
        ;
        
    V_DOC VARCHAR(20):=NULL;

    V_OBJECTID NUMBER;
    V_NEXTID NUMBER;
    V_CT VARCHAR(20);
    
--    SELECT ID FROM NEXUS_GIS.D WHERE NAME='D-23-06-064110';

BEGIN
    --ESTE PL ANALIZA LOS MOTIVOS DE FILTRO DE LOS FORZADOS MT
    FOR M IN C_MODELO LOOP
    
        IF V_DOC IS NULL OR V_DOC<>M.NAME THEN
            V_DOC:=M.NAME;
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('#################################################');
            DBMS_OUTPUT.PUT_LINE('DOCUMENTO: '||V_DOC); 
            DBMS_OUTPUT.PUT_LINE('#################################################');
            DBMS_OUTPUT.PUT_LINE('ORIGEN: '||M.ORIGEN); 
            DBMS_OUTPUT.PUT_LINE('FECHA DE CREACION: '||M.CREATION_TIME); 
            DBMS_OUTPUT.PUT_LINE('ESTADO: '||M.ESTADO); 
            DBMS_OUTPUT.PUT_LINE('INSERTADO EN GEN: '||
                CASE WHEN M.GEN=1 THEN 'SI' ELSE 'NO' END
            ); 
            DBMS_OUTPUT.PUT_LINE('INSERTADO EN DET: '||
                CASE WHEN M.DET=1 THEN 'SI' ELSE 'NO' END
            ); 
            DBMS_OUTPUT.PUT_LINE('CAUSA: '||M.CAUSA||CHR(9) ||'(no incluye null,40,78,85)'); 
        END IF;
        DBMS_OUTPUT.PUT_LINE('-------------------------->>'); 
        DBMS_OUTPUT.PUT_LINE(CHR(9) || CHR(9) || 'ELEMENT_ID: '||M.ELEMENT_ID); 
        DBMS_OUTPUT.PUT_LINE(CHR(9) || CHR(9) || 'CT: '||M.CT_AFECTADO); 
        DBMS_OUTPUT.PUT_LINE(CHR(9) || CHR(9) || 'AFFECT ID: '||
            CASE WHEN M.AFFECT_ID<>M.MAX_AFFECTID THEN 'No corresponde con el maximo: '||m.MAX_AFFECTID else 'Ok' end
        ); 
        DBMS_OUTPUT.PUT_LINE(CHR(9) || CHR(9) || 'TIEMPO AFECTADO: '||M.TIEMPO_AFECTADO); 
        DBMS_OUTPUT.PUT_LINE(CHR(9) || CHR(9) || 'AFECTACIONES AL INICIO: '||M.COUNT_AFFECTED); 
        DBMS_OUTPUT.PUT_LINE(CHR(9) || CHR(9) || 'AFECTACIONES: '||M.CANT_AFECTACIONES); 
        DBMS_OUTPUT.PUT_LINE(CHR(9) || CHR(9) || 'CT EN OTRO DOC: '||'-'); 
        
        --CONCLUSION
        IF M.DET=1 THEN
          NULL;

        ELSIF M.GEN =0 AND TRUNC(M.CREATION_TIME)<>TRUNC(SYSDATE) THEN
          --FILTRO EN TABLA GEN
            DBMS_OUTPUT.PUT_LINE(CHR(13) || CHR(9) || CHR(9) || 'CONCLUSION: No ingresa en GEN por diferencia de fechas');

        ELSIF M.ESTADO='Pendiente' THEN
          --ESTADO PENDIENTE
            DBMS_OUTPUT.PUT_LINE(CHR(13) || CHR(9) || CHR(9) || '>>No ingresa en DET por estado pendiente');
            
        ELSIF M.COUNT_AFFECTED=0 THEN
          --MENOR 5 MIN
            DBMS_OUTPUT.PUT_LINE(CHR(13) || CHR(9) || CHR(9) || '>>No ingresa en DET por ser sin afectacion al inicio');
            
        ELSIF M.TIEMPO_AFECTADO<5 THEN
          --PRIMER FILTRO DE AFECTACION Y EL MAS IMPORTANTE
            DBMS_OUTPUT.PUT_LINE(CHR(13) || CHR(9) || CHR(9) || 'No ingresa en DET por tiempo de afectacion <5');

        ELSIF M.LAST_STATE_ID IN (5,6) THEN
          --SI TIENE ESTADO CERRADO 
            DBMS_OUTPUT.PUT_LINE(CHR(13) || CHR(9) || CHR(9) || 'No ingresa en DET por estados cerrados');

        ELSIF M.CANT_AFECTACIONES=0 THEN
          --SI NO TIENE AFECTACIONES POR EL MODELO 
            DBMS_OUTPUT.PUT_LINE(CHR(13) || CHR(9) || CHR(9) || 'No ingresa en DET por ser sin afectacion');

        ELSIF M.CAUSA is null THEN
          --FILTRA POR CAUSAS
            DBMS_OUTPUT.PUT_LINE(CHR(13) || CHR(9) || CHR(9) || 'No ingresa en DET por causas');

        ELSIF M.CAUSA IN (40,78,85) THEN
          --FILTRA POR CAUSAS
            DBMS_OUTPUT.PUT_LINE(CHR(13) || CHR(9) || CHR(9) || 'No ingresa en DET por causas');

        ELSE  
            DBMS_OUTPUT.PUT_LINE(CHR(13) || CHR(9) || CHR(9) || 'CONCLUSION: Fuera de los filtros analizados');
        END IF;
    END LOOP;  
END;

  





