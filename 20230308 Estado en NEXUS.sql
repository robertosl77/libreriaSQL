    SELECT DISTINCT LAST_STATE_ID FROM NEXUS_GIS.OMS_DOCUMENT;
    
    SELECT distinct 
      OMS_DOCUMENT.LAST_STATE_ID, 
      OMS_DOCUMENT_STATE.DESCRIPTION
    FROM 
      NEXUS_GIS.OMS_DOCUMENT,
      NEXUS_GIS.OMS_DOCUMENT_STATE
    WHERE
      OMS_DOCUMENT_STATE.ID = OMS_DOCUMENT.LAST_STATE_ID
--      and OMS_DOCUMENT.LAST_STATE_ID= 1
    ;
    
    /*
    OMS_DOCUMENT.LAST_STATE_ID
      1 Pendiente
      2 En tratamiento
      3 Despachado
      4 Con anomalías F/S
      5 Cierre provisorio
      6 Cierre definitivo
      7 Cancelado
    */
