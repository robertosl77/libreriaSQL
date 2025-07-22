SELECT
    cols.owner                      AS schema,
    cols.table_name                 AS tabla,
    cols.column_name                AS columna,
    CASE 
        WHEN pk.constraint_type = 'P' THEN 'S' 
        ELSE '' 
    END                             AS es_pk,
    CASE 
        WHEN fk.constraint_type = 'R' THEN 'S' 
        ELSE '' 
    END                             AS es_fk,
    CASE 
        WHEN fk.constraint_type = 'R' THEN 
            rcons.owner || '.' || rcons.table_name || '.' || rcols.column_name 
        ELSE '' 
    END                             AS referencia_fk
FROM all_tab_columns cols
LEFT JOIN all_cons_columns pkcols 
    ON cols.owner = pkcols.owner 
    AND cols.table_name = pkcols.table_name 
    AND cols.column_name = pkcols.column_name
LEFT JOIN all_constraints pk 
    ON pkcols.owner = pk.owner 
    AND pkcols.constraint_name = pk.constraint_name 
    AND pk.constraint_type = 'P'
LEFT JOIN all_cons_columns fkcols 
    ON cols.owner = fkcols.owner 
    AND cols.table_name = fkcols.table_name 
    AND cols.column_name = fkcols.column_name
LEFT JOIN all_constraints fk 
    ON fkcols.owner = fk.owner 
    AND fkcols.constraint_name = fk.constraint_name 
    AND fk.constraint_type = 'R'
LEFT JOIN all_cons_columns rcols 
    ON fk.r_owner = rcols.owner 
    AND fk.r_constraint_name = rcols.constraint_name 
    AND fkcols.position = rcols.position
LEFT JOIN all_constraints rcons 
    ON rcols.owner = rcons.owner 
    AND rcols.constraint_name = rcons.constraint_name
WHERE cols.owner = 'NEXUS_GIS'
ORDER BY cols.table_name, cols.column_id;
