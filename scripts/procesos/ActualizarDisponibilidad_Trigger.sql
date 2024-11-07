CREATE OR REPLACE TRIGGER ActualizarDisponibilidad
AFTER INSERT ON PRESTAMOS
FOR EACH ROW
BEGIN
    UPDATE LIBROS
    SET Disponibles = Disponibles - 1
    WHERE LibroID = :NEW.LibroID;
END;
/