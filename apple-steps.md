# Instalacion de Oracle Express Edition en sistemas Apple Silicon.

Como bien sabemos, no es posible ejecutar una imagen Oracle Express Edition directamente en sistemas con procesadores Apple Silicon porque Oracle Express Edition está diseñado para arquitecturas x86_64. Los procesadores Apple Silicon utilizan una arquitectura ARM, que es diferente de la arquitectura x86_64. Esto significa que el software compilado para x86_64 no puede ejecutarse nativamente en procesadores ARM sin una capa de compatibilidad o emulación que traduzca las instrucciones de una arquitectura a otra. Por eso, necesitamos herramientas como QEMU y Colima para emular la arquitectura x86_64 y permitir la ejecución de Oracle Express Edition en sistemas Apple Silicon.

- **[QEMU](https://www.qemu.org/)**: Es un emulador y virtualizador de hardware de código abierto que permite ejecutar programas y sistemas operativos diseñados para una arquitectura de hardware diferente a la del host. También puede ser utilizado para crear y gestionar máquinas virtuales.

- **[Colima](https://github.com/abiosoft/colima#installation)**: Es una herramienta que facilita la ejecución de contenedores Docker en macOS, especialmente en sistemas con chips Apple Silicon (M1, M2, etc.). Utiliza QEMU para emular la arquitectura x86_64, permitiendo así la compatibilidad con imágenes de contenedores que no son nativamente compatibles con la arquitectura ARM. Colima proporciona una experiencia de usuario similar a Docker Desktop, pero optimizada para entornos Apple Silicon.

Para lograr ejecutar una imagen de Oracle XE (Express Edition), realizaremos los siguientes pasos:

## ⚙️ 1. Instalacion de entorno de virtualizacion QEMU

Para instalar QEMU usaremos el manejador de paquetes de `homebrew`. Ejecutamos el siguiente comando para instalar QEMU

```sh
brew install qemu
```

Se comenzara a instalar el software, puede tomar unos cuantos minutos antes de finalizar la instalacion.

Una vez finalizado verifcamos que el binario `qemu-system-x86_64` se encuentre registrado en la variable `$PATH`. Para verificarlo ejecutamos el siguiente comando.

```sh
which qemu-system-x86_64
```
Si el comando anterior no devuelve una ruta, significa que QEMU no está en el `$PATH`. Asegúrate de que el directorio donde se encuentra QEMU esté incluido en tu variable de entorno `$PATH`.

Si el comando anterior devuelve la ruta de instalacion, QEMU esta correctamente instalado.

## 🖥️ 2. Instalacion de Colima.

Para instalar Colima ejecutamos el siguiente comando usando `homebrew`:

```bash
brew install colima
```
Esto instalara el paquete en nuestro sistema, una vez instalado procederemos con la configuracion de un entorno virtual para que docker pueda ejecutarse sobre colima. 

Para inicializar un nuevo entorno que permita ejecutar docker ejecutamos el siguiente comando:

```bash
colima start --arch x86_64 --memory 4
```
_El comando anterior lo que esta haciendo es crear un nuevo entorno virtual que emula la arquitectura x64 y le asigna un espacio de memoria RAM de 4GB para ejecutar aplicaciones. 4GB son suficientes para manejar holgadamente la instancia de Oracle._

Puedes verificar el estado de ejecucion de colima con el siguiente comando:

```bash
colima status
```

Hecho esto ahora es posible ejecutar el comando de creacion del contenedor docker como usualmente lo hariamos.

## 🚀 3. Ejecucion de Oracle Express mediante Docker

Con todos los pasos anteriores ejecutados ahora es posible ejecutar el comando de docker para crear el contenedor que ejecutara una instancia de Oracle XE.

```bash
docker run -d --name "oracle-xe" -p 1521:1521 -p 5500:5500 -e ORACLE_PWD="Password123" -e ORACLE_CHARACTERSET="AL32UTF8" container-registry.oracle.com/database/express:21.3.0-xe
```
_El comando anterior descargara una imagen Oracle Express en su version 21.3.0 y generara un contenedor con una instancia de base de datos Oracle con la contraseña Password123_

Una vez levantado el contenedor podemos verificarlo ejecutando el comando

```bash
docker ps
```

La salida del terminal deberia verse similar a esta:

```bash
user@localhost $ docker ps
CONTAINER ID   IMAGE                                                      COMMAND                  CREATED        STATUS                  PORTS                                                                                  NAMES
5de20f8603bf   container-registry.oracle.com/database/express:21.3.0-xe   "/bin/bash -c $ORACL…"   12 hours ago   Up 12 hours (healthy)   0.0.0.0:1521->1521/tcp, :::1521->1521/tcp, 0.0.0.0:5500->5500/tcp, :::5500->5500/tcp   oracle-xe
```

### Validar la conexion con la base de datos.

Para probar que podamos conectarnos a la BD podemos usar [SQL Developer extension tools](https://marketplace.visualstudio.com/items?itemName=Oracle.sql-developer) para Visual Studio Code. (Se installa desde el panel de extensiones de VS Code).

Y generamos una nueva conexion siguiendo los siguientes parametros:

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
| Service Name        | XEPDB1        |

Una vez introducidos debemos hacer clic en el boton **Test** y deberia arrojarnos una conexion exitosa a la instancia.

# 🧠 Resolucion de problemas y reversión de ajustes.

## 🚫 Conxion de base de datos fallida.

En ocasiones la conexion de la base de datos de Oracle es fallida. En este punto la emulacion x64 no es perfecta con colima y en ocasiones puede resultar en fallos. Para este caso basta con esperar unos minutos adionales para que el contenedor estabilice su inicializacion interna y nuevamente ejecutar.

Si esto aun no funciona. Se sugiere eliminar el contenedor y eliminar el entorno de virtualizacion creado con Colima y volver a crearlo.

## ⛑️ Eliminacion de entorno

Para eliminar un entorno creado debemos realizar pasos adicionales a los usuales debido a que al ejecutar el conenedor mediante colima no tendremos visibilidad del mismo a través de Docker Desktop.

**Detener y eliminar el contenedor de oracle**: 

Para detener el conenedor realizamos la ejecucion de los siguientes comandos:

```sh
docker ps
```
_Obtenemos el listado de contenedores activos y tomamos nota del ID del contenedor de la instancia oracle_

Luego con el ID del contenedor podemos ejecutar los siguientes comandos y detenerlo para posteriorment eliminarlo.

```
docker stop <<container_id>>   # Detiene el contenedor en ejecucion
docker rm <<container_id>> # Elimina el contenedor
```

**Detener y eliminar el entorno virtual de colima**

Para poder detemer y eliminar el entorno virtual de colima ejecutaremos los siguientes comandos

```bash
colima stop # Esto detendra cualquier instancia virtual que hayamos creado directamente con colima.
```

```bash
colima delete # Esto eliminara cualquier instancia virutal que hayamos creado directamente con colima
```

Una vez detenido y eliminado tanto el contenedor de docker como el entorno virtual de colima, repetimos nuevamente los pasos de instalacion para tener un nuevo entorno y instalar una instancia de Oracle Express

> **NOTA: Descarga de imagen Oracle XE**  
> La imagen de Oracle XE siempre se volvera a descargar cada vez que recreemos el entorno virutal por lo que es necesario considerar los tiempos de descarga segun nuestra conexion de inernet.

> **NOTA: Version de colima**  
> Si teniamos colima instalado en nuestras maquinas previamente es conveniente realizar una actualizacion de este paquete ejecutando el siguiente comando `brew upgrade colima`
