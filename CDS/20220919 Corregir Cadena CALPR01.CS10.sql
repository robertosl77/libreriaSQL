--BD: CALPR01
--Tabla: CS10
SET SERVEROUTPUT ON 
DECLARE

    V_C1 VARCHAR(30);
    V_C2 VARCHAR(30);
    V_C3 VARCHAR(30);
    V_C4 VARCHAR(30);
    V_C5 VARCHAR(30);
    V_CADENA VARCHAR(50);
    V_CT VARCHAR(30);
    V_SQL VARCHAR(1000);
    V_FIL VARCHAR(90);
    
BEGIN
--    PROCESO: 
--      > FILTRA REGISTROS DONDE NO HAYA EXCLUSIVAMENTE 4 NUMERALES (SEPARA X CAMPO)
--      > FILTRA AQUELLOS REGISTROS DONDE LA CADENA ESTA OK
--      > AGRUPA LAS CADENAS ERRONEAS OBTENIDAS 
--      > SEPARA POR CAMPOS Y BUSCA EN EL PRIMER CAMPO SI ESTA EL CT, SINO BUSCA EN EL 3ro
--      > SI NO SE ENCUENTRA CT SE EXCLUYE PARA ESTE PL
--      > las cadenas corregidas se actualizan para todas las cuentas con las mismas cadenas erroneas

    DBMS_OUTPUT.PUT_LINE('CADENA,REPETICIONES,CT,BARRA,TRAFO,A,SALIDA,FINAL');
    
    FOR CUR IN (
        --BUSCO LAS CADENAS QUE NO PRESENTAN LA FIRMA CORRECTA
        SELECT 
            CEN_MTBT CADENA, 
            COUNT(1) CANTIDAD
        FROM SISENRE.CDS10
        WHERE
            1=1
            AND LENGTH(CEN_MTBT)-LENGTH(REPLACE(CEN_MTBT,'#',''))=4
            AND CEN_MTBT NOT LIKE '%____#B_#%_%#_#_%'
            AND NVL(OPERACION,'X')<>'B'
            AND PERIODO IN ('202208')
--            AND ROWNUM<2000
        GROUP BY
            CEN_MTBT    
    ) LOOP
    
        BEGIN
            --SEPARO LA CADENA EN 4 VARIABLES
            V_CADENA:=CUR.CADENA;
            V_C1:= SUBSTR(V_CADENA,1, INSTR(V_CADENA,'#')-1);
            V_CADENA:= SUBSTR(V_CADENA,INSTR(V_CADENA,'#')+1,LENGTH(V_CADENA));
            V_C2:= SUBSTR(V_CADENA,1, INSTR(V_CADENA,'#')-1);
            V_CADENA:= SUBSTR(V_CADENA,INSTR(V_CADENA,'#')+1,LENGTH(V_CADENA));
            V_C3:= SUBSTR(V_CADENA,1, INSTR(V_CADENA,'#')-1);
            V_CADENA:= SUBSTR(V_CADENA,INSTR(V_CADENA,'#')+1,LENGTH(V_CADENA));
            V_C4:= SUBSTR(V_CADENA,1, INSTR(V_CADENA,'#')-1);
            V_CADENA:= SUBSTR(V_CADENA,INSTR(V_CADENA,'#')+1,LENGTH(V_CADENA));
            V_C5:= V_CADENA;
            
            --TOMO EL CT A ANALIZAR
            V_CT:= NULL;
            IF LENGTH(V_C1)>0 THEN 
                V_CT:= V_C1;
            ELSIF LENGTH(V_C3)>0 THEN
                V_C3:= SUBSTR(V_C3,1,INSTR(V_C3,'-')-1);
                V_CT:= V_C3;
            END IF;
    
            --ANALIZO SI TENGO EL CT EN C1 O C3
            IF V_CT IS NULL THEN
                DBMS_OUTPUT.PUT_LINE(CUR.CADENA||','||CUR.CANTIDAD||','||V_C1||','||V_C2||','||V_C3||','||V_C4||','||V_C5||','||'Sin CT');
            ELSE
                --BUSCO SI HAY UNA CADENA ARMADA CON EL CT
                BEGIN
                    V_SQL:= 'SELECT CEN_MTBT FROM SISENRE.CDS10_SEM WHERE ROWNUM=1 ';

                    --ARMO EL FILTRO DEPENDIENDO SI HAY VALORES EN OTROS CAMPOS
                    IF V_C4 IS NOT NULL AND V_C5 IS NOT NULL THEN
                        V_FIL:= 'AND CEN_MTBT LIKE '''||V_CT||'#B_#%_%#'||V_C4||'#'||V_C5||'''';
                    ELSIF V_C4 IS NOT NULL THEN
                        V_FIL:= 'AND CEN_MTBT LIKE '''||V_CT||'#B_#%_%#'||V_C4||'#_''';                        
                    ELSIF V_C5 IS NOT NULL THEN
                        V_FIL:= 'AND CEN_MTBT LIKE '''||V_CT||'#B_#%_%#_#'||V_C5||'''';
                    ELSE
                        V_FIL:= 'AND CEN_MTBT LIKE '''||V_CT||'#B_#%_%#_#_''';
                    END IF;
                    
                    --EJECUTO DINAMICAMENTE LA CONSULTA
                    EXECUTE IMMEDIATE V_SQL||V_FIL INTO V_CADENA; 
                    
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        NULL;
                END;                
                
                BEGIN
                    --SI NO DEVOLVIO RESULTADO PRUEBO SOLO FILTRANDO EL CT
                    IF V_CADENA IS NULL THEN 
                        V_FIL:= 'AND CEN_MTBT LIKE '''||V_CT||'#B_#%_%#_#_';
                        EXECUTE IMMEDIATE V_SQL||V_FIL INTO V_CADENA; 
                    END IF;
                    
                    DBMS_OUTPUT.PUT_LINE(CUR.CADENA||','||CUR.CANTIDAD||','||V_C1||','||V_C2||','||V_C3||','||V_C4||','||V_C5||','||V_CADENA);
                    
    --                AQUI ACTUALIZARIA LA CADENA
    
    
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        DBMS_OUTPUT.PUT_LINE(CUR.CADENA||','||CUR.CANTIDAD||','||V_C1||','||V_C2||','||V_C3||','||V_C4||','||V_C5||','||'Sin CT');
                END;        
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE(CUR.CADENA||','||CUR.CANTIDAD||','||V_C1||','||V_C2||','||V_C3||','||V_C4||','||V_C5||','||'Sin Coincidencias');
        END;
--        DBMS_OUTPUT.PUT_LINE('-------------------------------------------------------------');
    END LOOP;
END;

