-- Crear usuario
CREATE USER AdminBL IDENTIFIED BY "biblioteca123";

-- Otorgar permisos al usuario
GRANT CONNECT, RESOURCE TO AdminBL;

-- Otorgar permisos específicos sobre las tablas del esquema de biblioteca
GRANT ALL ON LIBROS TO AdminBL;
GRANT ALL ON USUARIOS TO AdminBL;
GRANT ALL ON BIBLIOTECARIOS TO AdminBL;
GRANT ALL ON PRESTAMOS TO AdminBL;

-- Otorgar permisos para crear, eliminar y manipular procedimientos almacenados, triggers y funciones
GRANT CREATE PROCEDURE TO AdminBL;
GRANT CREATE TRIGGER TO AdminBL;
GRANT CREATE ANY PROCEDURE TO AdminBL;
GRANT DROP ANY PROCEDURE TO AdminBL;
GRANT EXECUTE ANY PROCEDURE TO AdminBL;
GRANT ALTER ANY PROCEDURE TO AdminBL;
