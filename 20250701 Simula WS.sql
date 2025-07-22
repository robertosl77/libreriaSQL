SET SERVEROUTPUT ON
DECLARE
    CURSOR c_afectaciones IS
        SELECT NRO_DOCUMENTO,
               CT_AFECTADO,
               ESTADO
        FROM NEXUS_GIS.TABLA_ENREMTAT_DET
        WHERE CIERRE_EMITIDO IS NULL
          AND FECHA_DOCUMENTO IS NOT NULL
          AND CT_AFECTADO IS NOT NULL;

    v_nro_documento  VARCHAR2(100);
    v_ct_afectado    VARCHAR2(100);
    v_estado         VARCHAR2(100);
BEGIN
    FOR r IN c_afectaciones LOOP
        v_nro_documento := r.NRO_DOCUMENTO;
        v_ct_afectado   := r.CT_AFECTADO;
        v_estado        := r.ESTADO;

        IF v_estado = 'Cerrado' OR v_estado = 'Cancelado' THEN
            UPDATE NEXUS_GIS.TABLA_ENREMTAT_DET
            SET CIERRE_EMITIDO   = 'Emitido',
                FECHA_INV_ENRE   = SYSDATE
            WHERE NRO_DOCUMENTO  = v_nro_documento
              AND CT_AFECTADO    = v_ct_afectado;
        ELSE
            UPDATE NEXUS_GIS.TABLA_ENREMTAT_DET
            SET FECHA_INV_ENRE   = SYSDATE
            WHERE NRO_DOCUMENTO  = v_nro_documento
              AND CT_AFECTADO    = v_ct_afectado;
        END IF;
    END LOOP;

    COMMIT;
END;
/
