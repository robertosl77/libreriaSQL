--    PROCESO: 
--      > FILTRA REGISTROS DONDE NO HAYA EXCLUSIVAMENTE 4 NUMERALES (SEPARA X CAMPO)
--      > FILTRA AQUELLOS REGISTROS DONDE LA CADENA ESTA OK
--      > AGRUPA LAS CADENAS ERRONEAS OBTENIDAS 
--      > SEPARA POR CAMPOS Y BUSCA EN EL PRIMER CAMPO SI ESTA EL CT, SINO BUSCA EN EL 3ro
--      > SI NO SE ENCUENTRA CT SE EXCLUYE PARA ESTE PL
--      > las cadenas corregidas se actualizan para todas las cuentas con las mismas cadenas erroneas
--BD: CALPR01
--Tabla: CS10_SEM
SPOOL C:\TEMP\CADENAS.TXT;
SET serveroutput on size unlimited
DECLARE
    
    V_C1 VARCHAR(5);
    V_C2 VARCHAR(3);
    V_C3 VARCHAR(9);
    V_C4 VARCHAR(2);
    V_C5 VARCHAR(4);
    V_CADENA VARCHAR(30);
    V_CT VARCHAR(5);
    V_SQL VARCHAR(1000);
    V_FIL VARCHAR(90);
    V_SINCT_C NUMBER:=0;
    V_SINCO_C NUMBER:=0;
    V_CONCT_C NUMBER:=0;
    V_CONER_C NUMBER:=0;
    V_SINCT_S NUMBER:=0;
    V_SINCO_S NUMBER:=0;
    V_CONCT_S NUMBER:=0;
    V_CONER_S NUMBER:=0;
    
BEGIN

    DBMS_OUTPUT.PUT_LINE('CADENA,FINAL');
    
    FOR CUR IN (
                SELECT * FROM (
                    SELECT 
                        ROW_NUMBER() OVER (ORDER BY CEN_MTBT) FILA,  
                        TRIM(CEN_MTBT) CADENA, 
                        COUNT(1) CANTIDAD
                    FROM SISENRE.CDS10_SEM
                    WHERE
                        1=1
                        AND LENGTH(CEN_MTBT)-LENGTH(REPLACE(CEN_MTBT,'#',''))=4
                        AND CEN_MTBT NOT LIKE '%____#B_#%_%#_#_%'
                        AND CEN_MTBT NOT LIKE '%____#B_#%_%#__#_%'
                        AND NVL(OPERACION,'X')<>'B'
                        AND PERIODO = 'SEM_52'
                    GROUP BY
                        CEN_MTBT
                ) F --WHERE FILA BETWEEN 1 AND 30000
    ) LOOP
        begin
        --SEPARO LA CADENA EN LOS 5 CAMPOS: CT, BARRA, TRAFO, TABLERO Y SALIDA
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
    
        --TOMO EL CT A ANALIZAR, O CANCELA SI NO ENCUENTRA NINGUNO
        V_CT:=NULL;
        IF LENGTH(V_C1)>0 THEN 
          V_CT:= V_C1;
        ELSIF LENGTH(V_C3)>0 THEN
          V_C3:= SUBSTR(V_C3,1,INSTR(V_C3,'-')-1);
          V_CT:= V_C3;
        END IF;
    
        --ANALIZO SI TENGO EL CT EN C1 O C3
        IF V_CT IS NULL THEN
          V_SINCT_C:= V_SINCT_C+1;
          V_SINCT_S:= V_SINCT_S+CUR.CANTIDAD;
        ELSE
        
          --SETEO EL SELECT PARA BUSCAR LA CADENA
          V_SQL:= 'SELECT CEN_MTBT FROM SISENRE.CDS10_SEM WHERE ROWNUM=1 ';
    
          --ARMO EL FILTRO DEPENDIENDO SI HAY VALORES EN OTROS CAMPOS
          V_FIL:= 'AND CEN_MTBT LIKE '''||V_CT||'#B_#'||RPAD('_',LENGTH(V_CT),'_')||'-TR_#'||NVL(V_C4,'_')||'#'||NVL(V_C5,'_')||'''';
    
          --BUSCO SI HAY UNA CADENA CON LA QUERY DINAMICA
          BEGIN
            EXECUTE IMMEDIATE V_SQL||V_FIL INTO V_CADENA;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              V_CADENA:=NULL;
          END;  
    
          --SI NO ENCONTRO CADENA BUSCO CON UN QUERY CON MENOS FILTROS
          IF V_CADENA IS NULL THEN 
            BEGIN
              V_FIL:= 'AND CEN_MTBT LIKE '''||V_CT||'#B_#%-TR_#_#_''';
              EXECUTE IMMEDIATE V_SQL||V_FIL INTO V_CADENA; 					
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                V_CADENA:=NULL;				
            END;
          END IF;
          
          --SI NO ENCONTRO LA CADENA, BUSCA POR UN CT CORTANDO 1 DIGITO DE DERECHA
          IF V_CADENA IS NULL THEN
            BEGIN
                V_FIL:= 'AND CEN_MTBT LIKE '''||SUBSTR(V_CT,1,LENGTH(V_CT)-1)||'_#B_#%-TR_#'||NVL(V_C4,'_')||'#'||NVL(V_C5,'_')||'''';
                EXECUTE IMMEDIATE V_SQL||V_FIL INTO V_CADENA;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    V_CADENA:=NULL;
                END;
          END IF;          
    
          --SI NO ENCONTRO CADENA CONTABILIZA SINO ACTUALIZA
          IF V_CADENA IS NULL THEN
            V_SINCO_C:= V_SINCO_C+1;
            V_SINCO_S:= V_SINCO_S+CUR.CANTIDAD;                      
          ELSE
            V_CONCT_C:= V_CONCT_C+1;
            V_CONCT_S:= V_CONCT_S+CUR.CANTIDAD;  
            
--            DBMS_OUTPUT.PUT_LINE(CUR.CADENA||','||V_CADENA);
    
--            UPDATE SISENRE.CDS10_SEM SET CEN_MTBT=V_CADENA WHERE CEN_MTBT=CUR.CADENA;
--            COMMIT;
          
          END IF;
    
        END IF;
        EXCEPTION 
          WHEN OTHERS THEN
            V_CONER_C:= V_CONER_C+1;
            V_CONER_S:= V_CONER_S+CUR.CANTIDAD;
        END;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Cadenas sin CT: '||V_SINCT_C||' ('||V_SINCT_S||' clientes) ');
    DBMS_OUTPUT.PUT_LINE('Cadenas no encontradas: '||V_SINCO_C||' ('||V_SINCO_S||' clientes) ');
    DBMS_OUTPUT.PUT_LINE('Errores al generar cadena: '||V_CONER_C||' ('||V_CONER_S||' clientes) ');
    DBMS_OUTPUT.PUT_LINE('Cadenas Modificadas: '||V_CONCT_C||' ('||V_CONCT_S||' clientes) ');
END;
/
spool off;