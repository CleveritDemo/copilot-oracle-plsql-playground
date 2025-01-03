# Installation of Oracle Express Edition on Apple Silicon systems

As we know, it is not possible to run an Oracle Express Edition image directly on systems with Apple Silicon processors because Oracle Express Edition is designed for x86_64 architectures. Apple Silicon processors use an ARM architecture, which is different from the x86_64 architecture. This means that software compiled for x86_64 cannot run natively on ARM processors without a compatibility or emulation layer that translates instructions from one architecture to another. Therefore, we need tools like QEMU and Colima to emulate the x86_64 architecture and allow Oracle Express Edition to run on Apple Silicon systems.

- **[QEMU](https://www.qemu.org/)**: It is an open-source hardware emulator and virtualizer that allows running programs and operating systems designed for a different hardware architecture than the host. It can also be used to create and manage virtual machines.

- **[Colima](https://github.com/abiosoft/colima#installation)**: It is a tool that facilitates running Docker containers on macOS, especially on systems with Apple Silicon chips (M1, M2, etc.). It uses QEMU to emulate the x86_64 architecture, thus allowing compatibility with container images that are not natively compatible with the ARM architecture. Colima provides a user experience similar to Docker Desktop but optimized for Apple Silicon environments.

To run an Oracle XE (Express Edition) image, we will follow these steps:

## ⚙️ 1. Installation of QEMU virtualization environment

To install QEMU, we will use the `homebrew` package manager. We run the following command to install QEMU:

```sh
brew install qemu
```

The software installation will begin, and it may take a few minutes to complete.

Once finished, we verify that the `qemu-system-x86_64` binary is registered in the `$PATH` variable. To check this, we run the following command:

```sh
which qemu-system-x86_64
```
If the previous command does not return a path, it means that QEMU is not in the `$PATH`. Make sure that the directory where QEMU is located is included in your `$PATH` environment variable.

If the previous command returns the installation path, QEMU is correctly installed.

## 🖥️ 2. Installation of Colima

To install Colima, we run the following command using `homebrew`:

```bash
brew install colima
```
This will install the package on our system. Once installed, we will proceed with the configuration of a virtual environment so that Docker can run on Colima.

To initialize a new environment that allows running Docker, we run the following command:

```bash
colima start --arch x86_64 --memory 4
```
_The previous command creates a new virtual environment that emulates the x64 architecture and assigns 4GB of RAM to run applications. 4GB is enough to comfortably handle the Oracle instance._

You can check the running status of Colima with the following command:

```bash
colima status
```

Once this is done, it is now possible to run the Docker container creation command as we usually would.

## 🚀 3. Running Oracle Express via Docker

With all the previous steps executed, it is now possible to run the Docker command to create the container that will run an Oracle XE instance.

```bash
docker run -d --name "oracle-xe" -p 1521:1521 -p 5500:5500 -e ORACLE_PWD="Password123" -e ORACLE_CHARACTERSET="AL32UTF8" container-registry.oracle.com/database/express:21.3.0-xe
```
_The previous command will download an Oracle Express image in version 21.3.0 and generate a container with an Oracle database instance with the password Password123._

Once the container is up, we can verify it by running the command:

```bash
docker ps
```

The terminal output should look similar to this:

```bash
user@localhost $ docker ps
CONTAINER ID   IMAGE                                                      COMMAND                  CREATED        STATUS                  PORTS                                                                                  NAMES
5de20f8603bf   container-registry.oracle.com/database/express:21.3.0-xe   "/bin/bash -c $ORACL…"   12 hours ago   Up 12 hours (healthy)   0.0.0.0:1521->1521/tcp, :::1521->1521/tcp, 0.0.0.0:5500->5500/tcp, :::5500->5500/tcp   oracle-xe
```

### Validate the connection to the database

To test that we can connect to the DB, we can use [SQL Developer extension tools](https://marketplace.visualstudio.com/items?itemName=Oracle.sql-developer) for Visual Studio Code. (It is installed from the VS Code extensions panel).

And we create a new connection following these parameters:

**Connection Parameters:**
| Parameter           | Value         |
|---------------------|---------------|
| Connection Name     | SYSADMIN      |
| Authentication Type | Default       |
| Username            | SYS           |
| Password            | YourPassword  |
| Connection Type     | Basic         |
| Hostname            | localhost     |
| Port                | 1521          |
| Type                | Service Name  |
| Service Name        | XEPDB1        |

Once entered, we must click the **Test** button, and it should show a successful connection to the instance.

# 🧠 Troubleshooting and reverting settings

## 🚫 Database connection failed

Sometimes, the Oracle database connection fails. At this point, x64 emulation is not perfect with Colima and can sometimes result in failures. In this case, just wait a few additional minutes for the container to stabilize its internal initialization and try again.

If this still does not work, it is suggested to delete the container and delete the virtual environment created with Colima and recreate it.

## ⛑️ Deleting the environment

To delete a created environment, we must perform additional steps because when running the container through Colima, we will not have visibility of it through Docker Desktop.

**Stop and delete the Oracle container**: 

To stop the container, we run the following commands:

```sh
docker ps
```
_We get the list of active containers and note the ID of the Oracle instance container._

Then, with the container ID, we can run the following commands to stop it and then delete it.

```sh
docker stop <<container_id>>   # Stops the running container
docker rm <<container_id>>     # Deletes the container
```

**Stop and delete the Colima virtual environment**

To stop and delete the Colima virtual environment, we run the following commands:

```bash
colima stop   # This will stop any virtual instance we have created directly with Colima.
```

```bash
colima delete # This will delete any virtual instance we have created directly with Colima.
```

Once both the Docker container and the Colima virtual environment are stopped and deleted, we repeat the installation steps to have a new environment and install an Oracle Express instance.

> **NOTE: Oracle XE image download**  
> The Oracle XE image will always be downloaded again each time we recreate the virtual environment, so it is necessary to consider the download times according to our internet connection.

> **NOTE: Colima version**  
> If we had Colima installed on our machines previously, it is advisable to update this package by running the following command `brew upgrade colima`.
