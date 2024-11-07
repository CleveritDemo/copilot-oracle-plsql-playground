CREATE OR REPLACE PROCEDURE RegistrarDevolucion (
    p_PrestamoID IN NUMBER
) AS
    v_LibroID LIBROS.LibroID%TYPE;
    v_Devolucion PRESTAMOS.Devolucion%TYPE;
BEGIN
    -- Verificar que el préstamo existe y está activo
    SELECT LibroID, Devolucion INTO v_LibroID, v_Devolucion
    FROM PRESTAMOS
    WHERE PrestamoID = p_PrestamoID;

    IF v_Devolucion = 'T' THEN
        RAISE_APPLICATION_ERROR(-20004, 'El préstamo ya ha sido devuelto.');
    END IF;

    -- Actualizar la tabla PRESTAMOS para marcar la devolución
    UPDATE PRESTAMOS
    SET Devolucion = 'T'
    WHERE PrestamoID = p_PrestamoID;

    -- Confirmar la transacción
    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'Préstamo no encontrado.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20002, 'Error al registrar la devolución.');
END RegistrarDevolucion;
/