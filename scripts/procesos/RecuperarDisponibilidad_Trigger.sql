CREATE OR REPLACE TRIGGER RecuperarDisponibilidad
AFTER UPDATE OF Devolucion ON PRESTAMOS
FOR EACH ROW
WHEN (NEW.Devolucion = 'T' AND OLD.Devolucion = 'F')
BEGIN
    UPDATE LIBROS
    SET Disponibles = Disponibles + 1
    WHERE LibroID = :NEW.LibroID;
END;
/