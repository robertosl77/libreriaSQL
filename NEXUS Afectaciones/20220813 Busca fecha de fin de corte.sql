
         SELECT 
                (CASE
                    WHEN (SELECT MIN (dcp.fecha)
                            FROM nexus_gis.doc_cierre_provisorio dcp
                           WHERE dcp.document_id = d.id)
                            IS NULL
                    THEN
                       d.last_state_change_time
                    ELSE
                       (SELECT MIN (dcp.fecha)
                          FROM nexus_gis.doc_cierre_provisorio dcp
                         WHERE dcp.document_id = d.id)
                 END)
                   AS fecha_cierre_documento
           FROM nexus_gis.oms_document d, nexus_gis.oms_document_state ds
          WHERE 
                1=1
                AND d.last_state_id > 4
                AND DS.ID = D.LAST_STATE_ID
                AND D.ID = 8280647


;