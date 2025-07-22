SELECT 
  ARO.DOCUMENT_ID, 
  TRIM(SUBSTR(L.LINKVALUE,1,INSTR(L.LINKVALUE,'-')-1)) CT, 
  (SELECT COUNT(1) FROM NEXUS_CCYB.CLIENTES_CCYB WHERE CT=TRIM(SUBSTR(L.LINKVALUE,1,INSTR(L.LINKVALUE,'-')-1)) AND FECHABAJA<SYSDATE) CLIENTES
FROM 
  NEXUS_GIS.OMS_AFFECT_RESTORE_OPERATION ARO, 
  NEXUS_GIS.OMS_AFFECTED_ELEMENT AE, 
  NEXUS_GIS.SPROBJECTS O,
  NEXUS_GIS.SPRLINKS L
WHERE
  ARO.ID=AE.AFFECT_ID
  AND AE.ELEMENT_ID=O.OBJECTNAMEID
  AND O.OBJECTID=L.OBJECTID
  and ARO.DOCUMENT_ID in (
                            SELECT ID
                          FROM (
                              SELECT 
                                D.ID, 
                                D.NAME, 
                                D.TYPE_ID, 
                                D.CREATION_TIME, 
                                (SELECT MIN(ARO.TIME) FROM NEXUS_GIS.OMS_AFFECT_RESTORE_OPERATION ARO, NEXUS_GIS.OMS_AFFECTED_ELEMENT AE WHERE AE.AFFECT_ID=ARO.ID AND ARO.DOCUMENT_ID=D.ID) INI,
                                (SELECT MIN(ARO.TIME) FROM NEXUS_GIS.OMS_AFFECT_RESTORE_OPERATION ARO, NEXUS_GIS.OMS_AFFECTED_ELEMENT AE WHERE AE.restore_id=ARO.ID AND ARO.DOCUMENT_ID=D.ID) FIN
                              FROM
                                NEXUS_GIS.OMS_DOCUMENT D
                              WHERE 
                                SUBSTR(D.NAME,1,7)='D-22-09'
                                AND D.TYPE_ID IN (3,4)
                          ) X
                          WHERE 
                            INI IS NOT NULL
                            AND ((FIN-INI)*60*24)<5

                  )  
  AND L.LOGIDTO=0
  AND L.LINKID=1018
  AND ARO.IS_RESTORE=0
  AND ARO.OPERATION_ID IS NOT NULL
;  