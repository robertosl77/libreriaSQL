/*
   PROCEDURE INSERTAR_MARCA (P_USER_ID       IN     VARCHAR2,
                             P_ID_MARCA      IN     VARCHAR2,
                             P_ID_SUBMARCA   IN     VARCHAR2,
                             P_CUENTA        IN     VARCHAR2,
                             P_NOTA          IN     VARCHAR2,
                             P_RESULTADO        OUT VARCHAR2)
*/
SET SERVEROUTPUT ON
DECLARE
  V_R VARCHAR(20);

BEGIN
    
    --GELEC.PKG_OTROS.
    GELEC.PKG_OTROS.INSERTAR_MARCA('RSLEIVA','7','18','8454412929','...',V_R);
--    EXECUTE GELEC.PKG_OTROS.INSERTAR_MARCA('ROBERTO','7','18','8454412929','PRUEBA',V_R);
    COMMIT;

END;


