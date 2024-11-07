-- CREATE SEQUENCE PRESTAMOS_SEQ START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE PROCEDURE RegistrarPrestamo (
    p_DNI IN VARCHAR2,
    p_ISBN IN VARCHAR2,
    p_CodigoBibliotecario IN NUMBER
) AS
    v_UsuarioID USUARIOS.UsuarioID%TYPE;
    v_LibroID LIBROS.LibroID%TYPE;
    v_BibliotecarioID BIBLIOTECARIOS.BibliotecarioID%TYPE;
    v_Disponibles LIBROS.Disponibles%TYPE;
BEGIN
    -- Obtener el UsuarioID a partir del DNI
    SELECT UsuarioID INTO v_UsuarioID
    FROM USUARIOS
    WHERE DNI = p_DNI;

    -- Obtener el LibroID y la cantidad de disponibles a partir del ISBN
    SELECT LibroID, Disponibles INTO v_LibroID, v_Disponibles
    FROM LIBROS
    WHERE ISBN = p_ISBN;

    -- Verificar si hay ejemplares disponibles
    IF v_Disponibles <= 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'El libro solicitado no se encuentra disponible.');
    END IF;

    -- Obtener el BibliotecarioID a partir del Código
    SELECT BibliotecarioID INTO v_BibliotecarioID
    FROM BIBLIOTECARIOS
    WHERE Codigo = p_CodigoBibliotecario;

    -- Insertar el nuevo préstamo con FechaDevolucion
    INSERT INTO PRESTAMOS (PrestamoID, LibroID, UsuarioID, BibliotecarioID, FechaPrestamo, FechaDevolucion)
    VALUES (PRESTAMOS_SEQ.NEXTVAL, v_LibroID, v_UsuarioID, v_BibliotecarioID, SYSDATE, SYSDATE + 10);

    -- Confirmar la transacción
    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'Usuario, libro o bibliotecario no encontrado.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20002, 'Error al registrar el préstamo.' || SQLERRM);
END RegistrarPrestamo;
/