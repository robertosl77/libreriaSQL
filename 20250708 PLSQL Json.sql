SET SERVEROUTPUT ON 
DECLARE
    TYPE t_email_record IS RECORD (
        id_personal NUMBER,
        email VARCHAR2(255)
    );
    TYPE t_email_table IS TABLE OF t_email_record;
    
    v_emails t_email_table;
    v_json CLOB;
    v_region_json CLOB;
    v_zona_json CLOB;
BEGIN
    -- Obtener los correos electrónicos (skill = 3)
    SELECT id_personal, dato AS email
    BULK COLLECT INTO v_emails
    FROM GELEC.ED_PERSONAL_DATOS
    WHERE id_skill = 3;

    -- Construir el JSON
    v_json := '[';

    FOR i IN 1 .. v_emails.COUNT LOOP
        -- Obtener la región como JSON_ARRAY
        SELECT JSON_ARRAYAGG(dato) INTO v_region_json
        FROM GELEC.ED_PERSONAL_DATOS
        WHERE id_personal = v_emails(i).id_personal AND id_skill = 5;

        -- Obtener la zona como JSON_ARRAY
        SELECT JSON_ARRAYAGG(dato) INTO v_zona_json
        FROM GELEC.ED_PERSONAL_DATOS
        WHERE id_personal = v_emails(i).id_personal AND id_skill = 4;

        -- Construir el objeto JSON con los valores ya asignados
        v_json := v_json || JSON_OBJECT(
            'id_personal' VALUE v_emails(i).id_personal,
            'email' VALUE v_emails(i).email,
            'region' VALUE TO_CLOB(v_region_json) FORMAT JSON,
            'zona' VALUE TO_CLOB(v_zona_json) FORMAT JSON
        ) || ',';
    END LOOP;

    -- Eliminar la última coma y cerrar el array
    v_json := RTRIM(v_json, ',') || ']';

    -- Mostrar el JSON
    DBMS_OUTPUT.PUT_LINE(v_json);
END;
/
