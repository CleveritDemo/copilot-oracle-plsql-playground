DECLARE
    v_DNI VARCHAR2(20);
    v_ISBN VARCHAR2(20);
    v_CodigoBibliotecario NUMBER;
BEGIN
    -- Solicitar el DNI del usuario
    DBMS_OUTPUT.PUT_LINE('Ingrese el DNI del usuario:');
    v_DNI := '&DNI';

    -- Solicitar el ISBN del libro
    DBMS_OUTPUT.PUT_LINE('Ingrese el ISBN del libro:');
    v_ISBN := '&ISBN';

    -- Solicitar el código del bibliotecario
    DBMS_OUTPUT.PUT_LINE('Ingrese el código del bibliotecario:');
    v_CodigoBibliotecario := &CodigoBibliotecario;

    -- Llamar al procedimiento almacenado
    RegistrarPrestamo(v_DNI, v_ISBN, v_CodigoBibliotecario);

    DBMS_OUTPUT.PUT_LINE('Préstamo registrado exitosamente.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/