# Proyecto de Biblioteca

Este proyecto contiene scripts SQL para insertar datos en las tablas de una base de datos de biblioteca. Los scripts están organizados en la carpeta `data` y están diseñados para poblar las siguientes tablas:

1. **LIBROS**: Contiene un script para insertar 10 libros diferentes. Cada libro tiene un ISBN único, título, autor, género y un conteo de disponibilidad.

2. **USUARIOS**: Incluye un script para insertar al menos 20 usuarios. Cada usuario tiene un DNI único, nombre, correo electrónico, número de teléfono y nombre de usuario.

3. **BIBLIOTECARIOS**: Contiene un script para insertar 7 bibliotecarios. Cada bibliotecario tiene un ID único, nombre, correo electrónico y código.

## Ejecución de los Scripts

Para ejecutar los scripts, se recomienda utilizar un cliente SQL compatible con Oracle. Asegúrese de tener acceso a la base de datos y los permisos necesarios para realizar inserciones.

1. Conéctese a la base de datos.
2. Ejecute el script `insert_libros.sql` para agregar los libros.
3. Ejecute el script `insert_usuarios.sql` para agregar los usuarios.
4. Ejecute el script `insert_bibliotecarios.sql` para agregar los bibliotecarios.

Asegúrese de verificar que no haya errores durante la ejecución de los scripts y que los datos se hayan insertado correctamente.