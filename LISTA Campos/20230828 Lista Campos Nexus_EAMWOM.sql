SET SERVEROUTPUT ON 
DECLARE


BEGIN
    FOR AA IN (SELECT TABLE_NAME FROM ALL_TABLES WHERE OWNER='NEXUS_EAMWOM') LOOP
        
        FOR BB IN (SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE FROM ALL_TAB_COLUMNS WHERE TABLE_NAME =AA.TABLE_NAME ORDER BY COLUMN_NAME) LOOP
        
            DBMS_OUTPUT.PUT_LINE(BB.TABLE_NAME||','||BB.COLUMN_NAME||','||BB.DATA_TYPE);
        
        END LOOP;
    
    END LOOP;

END;