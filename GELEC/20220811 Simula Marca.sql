SET SERVEROUTPUT ON
DECLARE
    P_USER_ID       GELEC.ED_NOTAS.USUARIO%TYPE:='PRUEBA';
    P_ID_MARCA      GELEC.ED_MARCA_CLIENTE.ID_MARCA%TYPE:='7';
    P_ID_SUBMARCA   GELEC.ED_MARCA_CLIENTE.ID_SUBMARCA%TYPE:='18';
    P_CUENTA        GELEC.ED_MARCA_CLIENTE.CUENTA%TYPE:='8454412929';
    P_NOTA          GELEC.ED_NOTAS.OBSERVACIONES%TYPE:='NOTA PRUEBA';
    P_RESULTADO     NUMBER;

      CURSOR C_MARCAS
      IS
         SELECT MC.ID, MC.ID_MARCA, MC.ID_SUBMARCA
           FROM GELEC.ED_MARCA_CLIENTE MC
          WHERE     MC.CUENTA = P_CUENTA
                AND MC.ID_MARCA = P_ID_MARCA
                AND MC.LOG_HASTA IS NULL;

      V_FLAG               NUMBER;
      V_LOG_ID             NUMBER;
      V_ID_MARCA_CLIENTE   NUMBER;
      V_ID_NOTA            NUMBER;

   BEGIN
      V_FLAG := 0;
      V_LOG_ID :=
         GELEC.INSERT_LOG (
               'Modifica marca: '
            || P_ID_MARCA
            || ' | Submarca: '
            || P_ID_SUBMARCA
            || ' | en cuenta nro: '
            || P_CUENTA,
            P_USER_ID);

      V_ID_NOTA := GELEC.SEQ_NOTAS.NEXTVAL ();

      -- INSERTO LA NOTA
      INSERT INTO GELEC.ED_NOTAS (ID_NOTA,
                                  USUARIO,
                                  IDDESTINO,
                                  FECHAHORA,
                                  OBSERVACIONES,
                                  EFECTIVO,
                                  LOG_DESDE,
                                  LOG_HASTA,
                                  ID_TIPO_NOTA)
           VALUES (V_ID_NOTA,
                   P_USER_ID,
                   NULL,
                   SYSDATE,
                   P_NOTA,
                   NULL,
                   V_LOG_ID,
                   NULL,
                   '3');


      FOR MARCA IN C_MARCAS
      LOOP
         -- CASO 1:
         -- MARCA Y SUBMARCA COINCIDEN, TIPO REVISION DE RED
         -- CASO 2:
         -- MARCA COINCIDE, DIFERENTE A REVISION DE RED
         IF P_ID_MARCA = 5 OR P_ID_MARCA = 4
         THEN
            IF P_ID_SUBMARCA = MARCA.ID_SUBMARCA
            THEN
               UPDATE GELEC.ED_MARCA_CLIENTE MC
                  SET MC.LOG_HASTA = V_LOG_ID
                WHERE MC.ID = MARCA.ID;

               V_FLAG := 1;
            END IF;
         ELSE
            IF P_ID_SUBMARCA = MARCA.ID_SUBMARCA
            THEN
               V_FLAG := 1;
            END IF;

            UPDATE GELEC.ED_MARCA_CLIENTE MC
               SET MC.LOG_HASTA = V_LOG_ID
             WHERE MC.ID = MARCA.ID;
         END IF;
      END LOOP;

      -- GENERO NUEVO REGISTRO SI NO ES EL MISMO TIPO DE SUBMARCA (EN ESE CASO SOLO LA REMUEVO)
      IF V_FLAG = 0
      THEN
         V_ID_MARCA_CLIENTE := GELEC.SEQ_MARCA_CLIENTE.NEXTVAL ();

         INSERT INTO GELEC.ED_MARCA_CLIENTE MC (ID,
                                                CUENTA,
                                                ID_MARCA,
                                                ID_SUBMARCA,
                                                LOG_DESDE,
                                                LOG_HASTA)
              VALUES (V_ID_MARCA_CLIENTE,
                      P_CUENTA,
                      P_ID_MARCA,
                      P_ID_SUBMARCA,
                      V_LOG_ID,
                      NULL);
      END IF;

      --COMMIT;
      P_RESULTADO := V_ID_NOTA;
   END;
