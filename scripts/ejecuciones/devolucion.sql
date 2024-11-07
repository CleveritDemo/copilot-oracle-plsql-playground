-- Crea un bloque anonimo que ejecute el procedimiento almacenado RegisrarDevolucion

DECLARE
    v_PrestamoID NUMBER := &PrestamoID;
BEGIN
    -- Llamar al procedimiento almacenado
    RegistrarDevolucion(v_PrestamoID);
    DBMS_OUTPUT.PUT_LINE('Devolución registrada exitosamente.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;