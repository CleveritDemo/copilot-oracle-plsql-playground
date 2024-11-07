CREATE TABLE LIBROS (
    LibroID NUMBER PRIMARY KEY,
    ISBN VARCHAR2(22) UNIQUE,
    Titulo VARCHAR2(255),
    Autor VARCHAR2(255),
    Genero VARCHAR2(100),
    Disponibles NUMBER
);

CREATE TABLE USUARIOS (
    UsuarioID NUMBER PRIMARY KEY,
    DNI VARCHAR2(20) UNIQUE,
    Nombre VARCHAR2(255),
    Email VARCHAR2(255) UNIQUE,
    Telefono VARCHAR2(20),
    NombreUsuario VARCHAR2(20) UNIQUE
);

CREATE TABLE BIBLIOTECARIOS (
    BibliotecarioID NUMBER PRIMARY KEY,
    Nombre VARCHAR2(255),
    Email VARCHAR2(255),
    Codigo NUMBER(8) UNIQUE
);

CREATE TABLE PRESTAMOS (
    PrestamoID NUMBER PRIMARY KEY,
    LibroID NUMBER,
    UsuarioID NUMBER,
    BibliotecarioID NUMBER,
    FechaPrestamo DATE,
    FechaDevolucion DATE,
    CONSTRAINT fk_libro FOREIGN KEY (LibroID) REFERENCES LIBROS(LibroID),
    CONSTRAINT fk_usuario FOREIGN KEY (UsuarioID) REFERENCES USUARIOS(UsuarioID),
    CONSTRAINT fk_bibliotecario FOREIGN KEY (BibliotecarioID) REFERENCES BIBLIOTECARIOS(BibliotecarioID)
);

-- Modifca la tabla LIBROS para cambiar la longitud de la columna ISBN a 22
ALTER TABLE LIBROS MODIFY ISBN VARCHAR2(22);

-- Modifica la tabla PRESTAMOS para agregar la columna Devolucion
ALTER TABLE PRESTAMOS ADD (Devolucion CHAR(1) DEFAULT 'F' CHECK (Devolucion IN ('T', 'F')));