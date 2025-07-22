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
            SUBSTR(TRIM(LK.LINKVALUE), 4) AS CT_AFECTADO,
            (SELECT  NVL(D.COUNT_INIT_AFFECTED_CUSTOMERS, D.AFFECTED_CLIENTS) AS COUNT_AFFECTED FROM NEXUS_GIS.OMS_DOCUMENT D WHERE D.ID=OD.ID) COUNT_AFFECTED,
            OD.AFFECTED_CLIENTS,
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
            (SELECT MAX(AFFECT_ID) FROM NEXUS_GIS.OMS_AFFECTED_ELEMENT AE1, NEXUS_GIS.OMS_AFFECT_RESTORE_OPERATION RO WHERE AE1.AFFECT_ID = RO.ID AND RO.DOCUMENT_ID = OD.ID AND AE1.ELEMENT_ID = AE.ELEMENT_ID) MAX_AFFECTID
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
        
    V_CONCLUSION VARCHAR(100);
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('DOCUMENTO,ORIGEN,FECHA_CREACION,ESTADO,GEN,DET,CAUSA,AFFECT_ID,ELEMENT_ID,CT,AFFECTID_CHECK,TIEMPO_AFECTADO,AFECTADOS_INICIO,AFECTADOS_OMS,AFECTADOS,CONCLUSION');
    --ESTE PL ANALIZA LOS MOTIVOS DE FILTRO DE LOS PROGRAMADOS MT
    FOR M IN C_MODELO LOOP
        --CONCLUSION
        IF M.DET=1 THEN
          NULL;

--        ELSIF M.GEN =0 AND TRUNC(M.CREATION_TIME)<>TRUNC(SYSDATE) THEN
        ELSIF M.GEN =0 THEN
            V_CONCLUSION:='FILTRA EN GEN';

        ELSIF M.ESTADO='Pendiente' THEN
            V_CONCLUSION:='ESTADO PENDIENTE';
            
        ELSIF M.COUNT_AFFECTED=0 THEN
            V_CONCLUSION:='SIN AFE AL INICIO';
            
        ELSIF M.TIEMPO_AFECTADO<5 THEN
            V_CONCLUSION:='AFECTACION <5';

        ELSIF M.LAST_STATE_ID IN (5,6) THEN
            V_CONCLUSION:='ESTADO CERRADOS';

        ELSIF M.CANT_AFECTACIONES=0 THEN
            V_CONCLUSION:='SIN AFECTACION';

        ELSIF M.CAUSA is null THEN
            V_CONCLUSION:='POR CAUSAS';

        ELSIF M.CAUSA IN (40,78,85) THEN
            V_CONCLUSION:='POR CAUSAS';

        ELSE  
            V_CONCLUSION:= 'OTROS';
        END IF;
        --
        DBMS_OUTPUT.PUT_LINE(
                              M.NAME ||','||
                              M.ORIGEN ||','|| 
                              M.CREATION_TIME ||','|| 
                              M.ESTADO ||','|| 
                              CASE WHEN M.GEN=1 THEN 'SI' ELSE 'NO' END ||','|| 
                              CASE WHEN M.DET=1 THEN 'SI' ELSE 'NO' END ||','|| 
                              M.CAUSA ||','|| 
                              M.AFFECT_ID ||','|| 
                              M.ELEMENT_ID ||','|| 
                              M.CT_AFECTADO ||','|| 
                              CASE WHEN M.AFFECT_ID<>M.MAX_AFFECTID THEN 'No corresponde con el maximo: '||M.MAX_AFFECTID ELSE 'Ok' END ||','|| 
                              M.TIEMPO_AFECTADO ||','|| 
                              M.COUNT_AFFECTED ||','|| 
                              M.AFFECTED_CLIENTS ||','|| 
                              M.CANT_AFECTACIONES ||','|| 
                              V_CONCLUSION
                              );
    END LOOP;  
END;

  





