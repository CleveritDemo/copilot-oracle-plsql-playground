-- Crear tabla LIBROS
CREATE TABLE LIBROS (
    LibroID NUMBER PRIMARY KEY,
    Titulo VARCHAR2(255),
    Autor VARCHAR2(255),
    Genero VARCHAR2(255),
    Disponibles NUMBER
);

-- Crear tabla USUARIOS
CREATE TABLE USUARIOS (
    UsuarioID NUMBER PRIMARY KEY,
    Nombre VARCHAR2(255),
    Email VARCHAR2(255)
);

-- Crear tabla BIBLIOTECARIOS
CREATE TABLE BIBLIOTECARIOS (
    BibliotecarioID NUMBER PRIMARY KEY,
    Nombre VARCHAR2(255),
    Email VARCHAR2(255)
);

-- Crear tabla PRESTAMOS
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