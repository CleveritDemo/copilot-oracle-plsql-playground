# Potenciando PL/SQL con SQL Developer + Visual Studio y Github Copilot.

## 1. 💫 Información general
En este práctico trabajaremos sobre un modelo de biblioteca. En este escenario, nos volveremos los desarrolladores y mantenedores del sistema de base de datos de una biblioteca pública. Los administradores de la biblioteca quieren implementar un sistema de base de datos que permita las siguientes capacidades:
Registrar nuevos prestamos de libros.
Devolver los libros.
Identificar cuantos prestamos posee una persona.
Generar reportes de los libros mas prestados.

Para ello, se ha propuesto el siguiente modelo de base de datos para cumplir con el requerimiento solicitado. 

[Diagrama Entidad relacion](./copilot-library.md)

## 🎯️ Objetivos.
- Configurar SQL Developer Extension for Visual Studio Code.
- Construir base de datos mediante GH Copilot usando como base diagrama ER desde mermaid.
- Aprender como usar GH Copilot para la generación de procedimientos almacenados.
- Aprender como usar GH Copilot para la construcción de triggers de validación de datos. (UPDATE, INSERT, DELETE).
- Aprender a utilizar GH Copilot para la generación de reportes.
Optimización de consultas con GH Copilot.

## 🛠️ Requisitos de instalación.
- Visual Studio Code.
- Docker Desktop.
- Oracle SQL Developer Extension for VS Code
- Licencia de GitHub Copilot Activa.
- Extensión de GitHub Copilot para VS Code instalada.


# 🖥️ Ejecución paso a paso.

## 🔨 Paso 1. Configuración de la instancia Oracle Express Edition (si aplica)
Para ejecutar una instancia de Oracle SQL Express Edition (Oracle XE), emplearemos Docker. El cual es una herramienta para gestionar y ejecutar contenedores. Para instalar una imagen de Oracle XE debemos realizar los siguientes pasos:

- Descarga de Oracle XE: `docker pull container-registry.oracle.com/database/express:21.3.0-xe`
- Descargada la imagen, crea un nuevo contenedor que ejecute la instancia de Oracle XE con el siguiente comando:
```sh
docker run -d --name "oracle-xe" -p 1521:1521 -p 5500:5500 -e ORACLE_PWD="Password123" -e ORACLE_CHARACTERSET="AL32UTF8" container-registry.oracle.com/database/express:21.3.0-xe`
```

> **NOTA: Puertos Oracle XE**
> Recordemos que las bases de datos Oracle tienen una herramienta de administración web, la cual puede ser accedida mediante el puerto 5500. Es por esto por lo que se habilita el mapeo de dos puertos en este contenedor y la máquina host.

> **NOTA 2: Versiones de Oracle XE**
> En caso de querer descargar una imagen diferente, dirigirse al container registry público de Oracle y ubicar las distintas versiones de Oracle Express Edition disponibles.

## 🔨 Paso 2. Instalación de Oracle SQL Developer Extension for VS Code. (Si Aplica)

**Extension SQL Developer para VS Code:** https://marketplace.visualstudio.com/items?itemName=Oracle.sql-developers

**Pasos para la instalación.**
- Abrir Visual Studio Code.
- Dirigirse al panel de extensiones.
- Buscar la extensión: Oracle SQL Developer Extension for VS Code.
- Hacer click en Install.

> **ADVERTENCIA**  
> Esta extensión puede presentar conflictos con otras extensiones SQL similares dentro de Visual Studio Code como por ejemplo la extensión oficial de **Microsoft SQL Server** provista por Microsoft. Se aconseja deshabilitarlas para hacer uso de SQL Developer para Visual Studio Code.

## 🔨 Paso 3. Conexion a la base de datos

Para conectarnos, nos dirigimos directamente a la extension de **Oracle SQL Developer** y realizamos clic sobre el icono de **"+"** esto desplegara una pestaña donde introduciremos los parámetros de conexión. Estos parámetros, deben coincidir con los definidos en el **paso 1.**

**Parametros de Conexion:**
| Parámetro           | Valor         |
|---------------------|---------------|
| Connection Name     | SYSADMIN      |
| Authentication Type | Default       |
| Username            | SYS           |
| Password**          | YourPassword  |
| Connection Type     | Basic         |
| Hostname            | localhost     |
| Port                | 1521          |
| Type                | Service Name  |
| Service Name        | XE            |

(**) _El valor de la contraseña es sugerido pero puede modificarse por el valor que se necesite_

### 🚧 Resolucion de problemas
> **Error de conexion: SYSADMIN wrong role**  
> Cuando se realiza una conexion utilizando el usuario de sistema `SYS`, es requerido que se realize la conexion utilizando el rol de: `SYSDBA` ya que este usuario esta destinado a operaciones de administracion completa de la base de datos.

### 👤 Usuario administrador de la biblioteca AdminBL
Usaremos Copilot para pedirle que nos genere los scripts SQL que permitirán la creación de un usuario administrador de la biblioteca. Este usuario se encargará de la creación de las tablas y el manejo de procedimientos almacenados. Lo haremos mediante el siguiente prompt:

`Crea un usuario llamado AdminBL, que tenga permisos para crear, eliminar, consultar, actualizar tablas. Tambien debe tener permisos para crear, eliminar, ejecutar procedimientos almacenados y Crear, eliminar y modificar Triggers. Estos scrips deben ser creados para una base de datos Oracle XE.`

_Respuesta de Copilot:_

```SQL
-- Crear el usuario AdminBL
CREATE USER AdminBL IDENTIFIED BY your_password;

-- Otorgar permisos para crear, eliminar, consultar y actualizar tablas
GRANT CREATE TABLE TO AdminBL;
GRANT DROP TABLE TO AdminBL;
GRANT SELECT ANY TABLE TO AdminBL;
GRANT INSERT ANY TABLE TO AdminBL;
GRANT UPDATE ANY TABLE TO AdminBL;
GRANT DELETE ANY TABLE TO AdminBL;

-- Otorgar permisos para crear, eliminar y ejecutar procedimientos almacenados
GRANT CREATE PROCEDURE TO AdminBL;
GRANT DROP PROCEDURE TO AdminBL;
GRANT EXECUTE ANY PROCEDURE TO AdminBL;

-- Otorgar permisos para crear, eliminar y modificar triggers
GRANT CREATE TRIGGER TO AdminBL;
GRANT DROP TRIGGER TO AdminBL;
GRANT ALTER ANY TRIGGER TO AdminBL;

-- Otorgar permisos adicionales necesarios
GRANT CREATE SESSION TO AdminBL;
```

> **Troubleshooting - Error: ORA-65096**  
> Cuando intentamos crear el usuario de la biblioteca obtenemos el siguiente mensaje de error:  
> Error report - ORA-65096: invalid common user or role name https://docs.oracle.com/error-help/db/ora-65096/65096. 00000 - "common user or role name must start with prefix %s"  
> *Cause: An attempt is being made to create a common user or role without the correct prefix as specified in the COMMON_USER_PREFIX parameter.*
>
> Se debe a que estamos conectados a la instancia de la base de datos en entorno multitenant. Para solucionar esto, simplemente se deben editar los parámetros de la conexión hacia la base de datos y modificar el valor del **SERVICE NAME** al valor de: **XEPDB1**


> **Sustitución de Contraseña.**  
> Es necesario sustituir el valor de la contraseña en el script por el valor que queramos utilizar como clave. Para este caso usaremos biblioteca123 por lo que la instruccion deberia quedar asi:
> `CREATE USER AdminBL IDENTIFIED BY "biblioteca123";`

Una vez creado el nuevo usuario **AdminBL**. Nos conectaremos del mismo modo que realizamos la conexión anterior.

## 🔨 Paso 4. Creación del esquema

Disponemos el modelo entidad relación creado con Mermaid para poder generar las instrucciones SQL que creen el esquema en la base de datos utilizaremos Copilot para traducir el diagrama de Mermaid a código SQL compatible con Oracle SQL.

> **NOTA: Usuario AdminBL**  
> A partir de este punto todos los scripts seran ejecutados con el usuario **AdminBL**, no se debe usar el usuario SYS para continuar con las operaciones.

_Prompt para generar el esquema de tablas:_

`Hola copilot, para esta tarea te proporciono un archivo markdown el cual contiene un diagrama entidad relacion creado con la herramienta Mermaid. Tu objetivo es interpretar, entender y procesar ese diagrama. Una vez hayas procesado el diagrama, necesito que construyas los scrpts SQL que permitiran la creacion de las tablas, relaciones, restricciones y demas elementos que permitan la creacion de una base de datos basada 100% en ese diagrama. Es indispensable que todos los scripts que generes sean 100% compatibles con bases de datos Oracle SQL Xpress Edition. #file:biblioteca-bd.md`

Le indicamos a copilot que ajuste un poco el script para que modifique el tamaño de algunos campos: 

`Realiza algunas modificaciones al script. El ISBN en la tabla LIBROS es un codigo alfanumerico que maximo ocupa 25 caracteres. El campo del  nombre de usuario en la tabla USUARIO puede contener hasta maximo de 20 caracteres. El codigo numerico de los bibliotecarios es un codigo numerico unico que puede tener un tamaño de 8 digitos.`

_Salida generada por GitHub Copilot:_

```SQL
CREATE TABLE LIBROS (
    LibroID NUMBER PRIMARY KEY,
    ISBN VARCHAR2(13) UNIQUE,
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
```

## 🔨 Paso 5. Generación de datos.

Procedemos a llenar de datos la base de datos de la biblioteca. Utilizando GitHub Copilot, se construirán scripts SQL que cargarán de información las tablas.

_Prompt para generar los datos de prueba:_

`@workspace /new Genera una carpeta llamada data, que contenga scripts SQL de insersion de datos para las tablas existentes en el archivo #file:schema.sql La tabla LIBROS debe contener 10 diferentes libros ningun libro puede repetirse. La tabla Usuarios debe tener al menos 20 usuarios. La tabla bibliotecarios debe contener 7 bibliotecarios. Para la tabla prestamos, no insertes ningun registro. La carpeta data es la carpeta principal del proyecto, los scripts deben colocarse dentro de esa carpeta. Un usuario no puede ser bibliotecario y viceversa. Todos los scripts deben ser creados con la sintaxis de Oracle SQL y en idioma español.`

Con `@workspace /new` se generará una estructura de archivos nueva. Se debe hacer clic en el botón **Create Workspace** y colocar la estructura generada en el directorio raíz del repositorio de trabajo actual.

La salida de este script debe retornar una carpeta llamada Data la cual contiene tres scripts SQL de inserción de datos para las tablas **USUARIOS**, **LIBROS** y **BIBLIOTECARIOS**.

Hecho esto, simplemente debemos ejecutar los scripts en la base de datos usando el usuario **AdminBL**.

> **ERROR: Cuota en inserción de datos.**  
> Si se presenta el error de cuota no disponible para el usuario logueado al momento de insertar datos, se solventa con la siguiente instrucción SQL:  
> `ALTER USER AdminBL QUOTA UNLIMITED ON USERS;`  
> Esta instruccion permite una cuota ilimitada al usuario AdminBL.

## 🔨 Paso 6. Procedimiento de Registro de prestamos.

La principal operación de la biblioteca es prestar libros, usaremos a GitHub Copilot para generar un procedimiento que permita registrar prestamos de libros en la biblioteca mediante el siguiente prompt:

`Quiero crear un nuevo procedimiento almacenado en PL/SQL que me permita registrar prestamos de libros. Quiero que el procedimiento reciba como parametros de entrada el DNI del usuario que solicita el prestamo, el codigo ISBN del libro y el codigo del bibliotecario que autoriza/realiza el prestamo. #file:schema.sql. Este prodecimiento se llamada RegistrarPrestamo`

_Codigo sugerido por Copilot:_

```SQL
-- Se genera una secuencia autoincrementada en valores de 1 llamada PRESTAMOS_SEQ
CREATE SEQUENCE PRESTAMOS_SEQ START WITH 1 INCREMENT BY 1;
```

```SQL
-- Codigo del procedimiento almacenado para registrar prestamo.
CREATE OR REPLACE PROCEDURE RegistrarPrestamo (
    p_DNI IN VARCHAR2,
    p_ISBN IN VARCHAR2,
    p_CodigoBibliotecario IN NUMBER
) AS
    v_UsuarioID USUARIOS.UsuarioID%TYPE;
    v_LibroID LIBROS.LibroID%TYPE;
    v_BibliotecarioID BIBLIOTECARIOS.BibliotecarioID%TYPE;
BEGIN
    -- Obtener el UsuarioID a partir del DNI
    SELECT UsuarioID INTO v_UsuarioID
    FROM USUARIOS
    WHERE DNI = p_DNI;

    -- Obtener el LibroID a partir del ISBN
    SELECT LibroID INTO v_LibroID
    FROM LIBROS
    WHERE ISBN = p_ISBN;

    -- Obtener el BibliotecarioID a partir del Código
    SELECT BibliotecarioID INTO v_BibliotecarioID
    FROM BIBLIOTECARIOS
    WHERE Codigo = p_CodigoBibliotecario;

    -- Insertar el nuevo préstamo
    INSERT INTO PRESTAMOS (PrestamoID, LibroID, UsuarioID, BibliotecarioID, FechaPrestamo)
    VALUES (PRESTAMOS_SEQ.NEXTVAL, v_LibroID, v_UsuarioID, v_BibliotecarioID, SYSDATE);

    -- Confirmar la transacción
    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'Usuario, libro o bibliotecario no encontrado.');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20002, 'Error al registrar el préstamo.');
END RegistrarPrestamo;
/
```

Para emplear el procedimiento almacenado basta con invocarlo desde una consulta o un bloque anónimo. Le pediremos a Copilot que construya un bloque anónimo donde solicite datos de entrada al usuario para ejecutar el procedimiento.

_Prompt para generar bloque anonimo PL/SQL y ejecucion del procedimiento_

```
Construye un bloque anonimo de PL/SQL que ejecute el procedimiento almacenado que acabamos de generar. Y que solicite al usuario los parametros necesarios para que el procedimiento almacenado funcione correctamente.
```
_Codigo generado por Copilot:_

```SQL
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
```

### Ajustes de validacion

#### Fecha de vencimiento del préstamo.
Si se observa bien, Copilot, no esta generando la inserción de valores en el campo FechaDevolucion de la tabla PROCEDIMIENTOS. Por lo que le solicitaremos que la fecha de devolucion de un préstamo sea 10 días después de la fecha de creación de este. (Es posible definir un parámetro para ingresar una fecha cualquiera, pero para simplificar las cosas usaremos una ventana de 10 días). Lo haremos mediante el siguiente prompt:

`Modifica el procedimiento RegistrarPrestamo para que el campo FechaDevolucion definido en la tabla PRESTAMOS en el esquema #file:schema.sql tenga como valor la fecha de creacion del prestamo + 10 dias.`

Ese prompt generará como salida el procedimiento almacenado con el cambio aplicado al momento de Insertar un préstamo en la base de datos.

#### Validación del préstamo.
Debemos también incluir una validación que permita verificar si existe disponibilidad de libros antes de ejecutar un préstamo. Se logra mediante el siguiente prompt:

`Modifica el procedimiento RegistrarPrestamo para que incluya una condicion o validacion donde se verifique que el campo de DISPONIBLE del libro que se prestara no sea cero. Si el valor de ese campo es CERO, levantar un error con el mensaje de: Libro no disponible.`

Esto modificara el procedimiento almacenado para que incluya una validacion en donde se verifique que el libro a prestar se encuentre disponible.

> **NOTA: Compilacion de procedimientos PL/SQL**  
> Siempre que se modifique un procedimiento almacenado, este debe ser reejecutado para que se re-compile y quede actualizado en la base de datos. De lo contrario las modificaciones no se veran reflejadas.

## 🔨 Paso 7. Trigger para actualizar disponibilidad después de un préstamo.

El procedimiento de registrar prestamos funciona perfectamente, sin embargo, no esta controlando el conteo de la disponibilidad de los libros cada vez que ocurre un préstamo. Esta funcionalidad la ocuparemos con un trigger que cada vez que ocurra una inserción en la tabla de prestamos. Actualizará la cantidad de libros disponibles según el libro que corresponda.

`Necesito que desarrolles un TRIGGER llamado ActualizarDisponibilidad. Este trigger se encargara de actualizar la disponibilidad de un libro cada vez que se realice un prestamo, es decir cada vez que se inserte un nuevo registro de prestamo. La disponibilidad de cada libro se controla con un campo llamado DISPONIBILIDAD en la tabla LIBROS. Por cada prestamo realizado deberia disminuir en 1 el valor de este campo. #file:schema.sql`

_Codigo sugerido por Copilot:_

```SQL
CREATE OR REPLACE TRIGGER ActualizarDisponibilidad
AFTER INSERT ON PRESTAMOS
FOR EACH ROW
BEGIN
    UPDATE LIBROS
    SET Disponibles = Disponibles - 1
    WHERE LibroID = :NEW.LibroID;
END;
/
```
Este trigger, permitirá actualizar la disponibilidad cada vez que se inserte un nuevo registro de préstamo.

## 🔨 Paso 8. Procedimiento para devolución de libro.

Tambien es necesario crear un procedimiento que permita registrar cuando los usuarios devuelven un libro a la biblioteca. Para ello necesitaremos modificar la tabla de prestamos y agregar un nuevo campo llamado. Devolucion el cual sera un booleano que indicara si un préstamo ha sido regresado o no.
Posteriormente usaremos Github Copilot para generar el codigo del procedimiento PL/SQL que se encargara de esta tarea.

_Prompt para la modificacion de la tabla Prestamos:_

`Modifica la tabla Prestamos para que incluya ahora un campo booleano llamado Devolucion, el valor por defecto de ese campo es false. Este campo existe para validar si un prestamo ha sido retornado no.`

```SQL
ALTER TABLE PRESTAMOS ADD (Devolucion CHAR(1) DEFAULT 'F' CHECK (Devolucion IN ('T', 'F')));
```

_Prompt para la creación del procedimiento almacenado de devolución de libros:_

`Quiero crear un procedimiento almacenado en PL/SQL que me permita registrar las devoluciones de los libros que habian sido prestados por la biblioteca. Este procedimiento debe validar que el prestamo se encuentre activo. Y recibira como parametro el ID del prestamo. #file:schema.sql`

```SQL
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
    SET FechaDevolucion = SYSDATE, Devolucion = 'T'
    WHERE PrestamoID = p_PrestamoID;

    -- Incrementar la disponibilidad del libro en la tabla LIBROS
    UPDATE LIBROS
    SET Disponibles = Disponibles + 1
    WHERE LibroID = v_LibroID;

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
```

> **Actualización de la disponibilidad**  
> Si se observa bien la respuesta dada por Copilot, en este procedimiento almacenado, se ha incluido la lógica para implementar la actualización de la disponibilidad. En este caso la suprimiremos ya que crearemos un trigger que se ejecutará específicamente para esta tarea. En el ejemplo anterior **se suprime el código de la línea 22 hasta la línea 25**.

### Usamos comment driven development para ejecutar el procedimiento.
1. Creamos un nuevo archivo llamado `devolucion.sql`.
2. Escribimos el siguiente comentario dentro del archivo SQL creado: `-- Crea un bloque anonimo que ejecute el procedimiento almacenado RegistrarDevolucion`.
3. Presionamos `Enter` y `Tab` para ir aceptando las sugerencias que GitHub Copilot nos proporciona.

_Bloque de codigo resultante:_
```SQL
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
```

## 🔨 Paso 9. Trigger para actualizar disponibilidad después de una devolución.

Construiremos un trigger similar al de los prestamos, pero con la diferencia que este trigger detectará los cambios de los registros cuando ocurra una devolución. Aumentando nuevamente el conteo de ejemplares de libros disponibles.

_Prompt para generar el trigger:_

`Necesito que desarrolles un TRIGGER llamado RecuperarDisponibilidad. Este trigger se encargara de actualizar la disponibilidad de un libro cada vez que se realice una devolucion, es decir cada vez que se actualice el campo Devolucion de la tabla prestamo al valor de 'T'.  La disponibilidad de cada libro se controla con un campo llamado DISPONIBILIDAD en la tabla LIBROS. Por cada devolucion de libro  realizada se debe incrementar en 1 el valor de este campo. #file:schema.sql`

_Codigo sugerido por GitHub Copilot_

```SQL
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
```

## 👾 Bonus.!!

Ya en este punto hemos completado las funcionalidades básicas del modelo de biblioteca propuesto, sin embargo, se puede agregar algo mas de visibilidad. Es por eso que se propone apoyarnos con copilot para generar las siguientes consultas.

- Obtener el listado de usuarios morosos: Usuarios que poseen prestamos pendientes.
- Obtener el listado de libros mas prestados.
- Crear un procedimiento para el registro de nuevos libros.


