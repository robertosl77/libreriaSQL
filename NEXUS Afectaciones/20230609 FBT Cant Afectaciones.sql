	SELECT od.id, od.name, trunc(count(ae.id)/5)
		  FROM nexus_gis.oms_document od,
			   nexus_gis.oms_affect_restore_operation op,
			   nexus_gis.oms_affected_element ae
		 WHERE od.ID = op.DOCUMENT_ID
		   AND op.ID = ae.AFFECT_ID
		   AND OD.TYPE_ID = 1
       AND SUBSTR(OD.NAME,1,7)='D-22-09'
    group by od.id, od.name   
       ;