# Inception
### A 42-school project designated to create an application infrastructure using Docker and Docker compose
In this essay, I wrote down a walkthrough of the Inception project; an exercise focused on building a modular application using Docker and Docker Compose. The goal of the project is to deepen your understanding of containerization by setting up an environment composed of several services.

This document serves as a complete guide, walkthrough and documentation about the project, including:
- Explanations of the key theoretical concepts needed to solve the project.
- Step-by-step instructions to set up each component of the infrastructure.
- All the project bonuses and their solutions / explanations.
- Errors encountered during the implementation, and their solution.
- All external resources that helped resolve the project.
- Useful tips to complete the project and troubleshoot it.

Whether you are just starting the project or looking to set up some trobulesome service, you can find the solution here. <br/>
This is the project's infrastructure that we will achieve at the end of the project:

![Inception infrastructure](https://github.com/user-attachments/assets/8177d9a1-82d8-4e28-8e48-d02189a92a91)

## Index
[1. Concepts](#1-Concepts) <br/>
&ensp;&ensp;[1.1 Docker](#11-Docker) <br/>
&ensp;&ensp;&ensp;&ensp;[1.1.1 What is Docker?](#111-What-is-Docker-) <br/>
&ensp;&ensp;&ensp;&ensp;[1.1.2 How does Docker work?](#112-How-does-Docker-work-) <br/>
&ensp;&ensp;&ensp;&ensp;[1.1.3 Virtual Machine vs Docker](#113-Virtual-Machine-vs-Docker-) <br/>
&ensp;&ensp;&ensp;&ensp;[1.1.4 Docker tools](#114-Docker-tools-) <br/>



## 1. Concepts
In this section, you will learn all the key concepts to face this project. You will find information and explanations about Docker, Docker Compose, and all the services you need to set up and how the work together, such as MariaDB, php-fpm, nginx, and more.

### 1.1 Docker
#### 1.1.1 What is Docker? 🐳📦:
Docker is a software platform that automates the deployment of applications. Docker creates lightweight isolated environments called `containers`, separating them from your infrastructure (host machine). A `container` is an environment with OS-level isolation and applications running, independent from the host machine (see section [1.1.3 Virtual Machine vs Docker](#113-Virtual-Machine-vs-Docker-)). <br/>
To understand why Docker is really powerful, let's imagine you have built a Java application using Java 17 in your Debian environment. All works as expected. You are really proud of your work, so you want to share your feats with your partners. They clone the repo and try to use your application, but, oh no, surprise, it does not even compile. Why? Because they do not use Debian, but Ubuntu (some environment variables changed). Moreover, they do not even have Java 17 installed on their PC, but Java 12, and your application fails to run correctly. This is a classical problem known as "It works on my machine". <br/>
Here is where Docker comes in handy . Using Docker, you can create an isolated environment for your application, with the operating system and the system requirements that you need (Debian and Java 17 in our case). You would build a Debian container, install Java 17 on it, and copy your application files inside of it. Then, you would execute your container, and you would have your application running smoothly, as it isolates itself from the host machine (so it does not share neither the operating system nor system requirements).

#### 1.1.2 How does Docker work? 💻🔧:
Docker is more than just a program; it's a software platform. It uses a client-server architecture, where the client sends requests to the server (Docker Host) via a REST API, and the server processes them. Under the hood, we can differentiate 3 key components: The Docker Client, the Docker Host and the Docker Registry.
1. Docker Client: The Docker Client is a CLI (Command Line Interface) program. It's the program that you, as a user, would interact with to manage all the docker-related operations, such as building images, executing containers, and more. With it, you can execute commands like `docker run`, `docker build`, `docker pull`... Docker Compose has its own CLI tool, `docker compose`, which we will cover later.
2. Docker Host: The Docker Host is the server-side of Docker. It contains the images, containers, and most important, the Docker Daemon `dockerd`, a background service that listens to the Docker Client API requests. When a user executes a command (for example, `docker pull`) with the Docker Client, it sends an API request that `dockerd` listens to, and then it does the necessary operations (in our example, pulls an image from the requested registry).
3. Docker Registry: The Docker Registry is just a storage for Docker images. In a Docker Registry, you can pull created images, like Debian or Ubuntu base images, or push your own built images. Docker Hub is the official public Docker Registry. By default, the docker daemon pulls / pushes images from it when requested with the `FROM` keyword, but you can configure it so it pulls / pushes images to your own private registry.

The Docker Host (server-side of docker) can be on the same host machine as the client, but also can be in a different one. With your Docker Client, you can execute docker operations on a remote host machine via a TCP connection.

![Docker architecture](https://github.com/user-attachments/assets/2273b38b-c7aa-440e-85ee-19ad2ecd9be2)

To work with Docker, we will use at least 3 different elements: the Dockerfile, a Docker image and a Docker container.
1. Dockerfile: This is where we write our docker code to create a Docker image. There are a bunch of different keywords, like `FROM` to build our image based on another one, `RUN` to run some code on our image (like installing some packages with apt), `COPY` to copy files from the host machine to the container, and more.
2. Docker image: A Docker image is like a snapshot. When we execute `docker build path/to/Dockerfile`, the docker daemon reads and executes the code in the Dockerfile, and saves an immutable state of the Dockerfile. When we run a container, it's executed from an image.
3. Docker container: It's the actual software running from a docker image, which we can interact with. Containers run independently from one another and isolated from the host machine, but there are ways to communicate with each other.

To understand it better, think of it as a C program. The Dockerfile is like a .c file, with the code to execute. The Docker image would be the executable (a.out), a compiled version of the .c file and it's immutable. And the Docker container would be like the actual program running, with its own PID, memory and dynamic content. The same way you could have multiple programs running from the same executable, you could have multiple containers running from the same image, isolated from one another. See section [1.1.4 Docker tools](#114-Docker-tools-) for more information.

![Dockerfile, docker image and docker container](https://github.com/user-attachments/assets/54fe709a-aed6-4816-8c65-a935b54d2268)

#### 1.1.3 Virtual Machine vs Docker 💻​🆚​🐳​:
Now that we understand how Docker works, we should ask ourselves the next question: Why should we use Docker if we have virtual machines (VM)? Don't we get the same result using them? To answer it, we should understand how VMs work behind the scenes. <br/>
First of all, let's take a look at how computers work under the surface. A computer has two main components: the physical part (hardware), which includes the CPU, RAM, disk, and more; and the logical part (software), such as applications, libraries, and other system tools. But, how do applications communicate with the hardware? It would be pretty messy (and dangerous) to let the apps communicate themselves with it. Here is where the `kernel` comes in. The `kernel` is software that sits between the applications and the hardware, and helps with the communication of these two (similar to an API with the frontend and the backend). <br/>
When an app wants to access some hardware (for example, we want to print a letter 'A' into the screen), we would run some "high-level" code, like the C function `write`. Then, the OS would make a `syscall`, a "low-level" function call that tells the kernel the operation we want to do. Then, the kernel would execute the proper function to do what we asked it to do. This way, we managed to go from code on our app to printing a letter into our screen. <br/>
Applications rarely call syscalls directly. Instead, they use higher-level wrappers, like shells or library functions (such as `write`, `read`, `open`...), which internally perform the syscalls.

![PC Architecture](https://github.com/user-attachments/assets/87398e99-0c01-4a49-a0e7-47fd16071dbf)

Then, what is the difference between a kernel and an OS? The kernel is the basic component you need to communicate between software and hardware. But it's almost unusable without tools like a shell or libraries like we saw. An OS brings you different tools so you can work with your kernel in a much friendly way. These include daemons, init systems, shells, libraries, basic utilities (ls, cat, mv...), and more. Think of the kernel as the engine of a car; it is essential, but unusable alone. The OS includes the kernel and other tools that make the system and pc usable.

As we already stated, Docker containers run in isolated environments. VMs work in a similar way, with key differences. A VM virtualizes everything: The applications you run inside them, the libraries it contains, and the operating system. And here is the key part. It also virtualizes the kernel of the distro you are using. If you have a Windows and Debian distro, and your host machine has an Ubuntu OS, then the VMs would virtualize the Windows and Debian kernel. Docker, on the other hand, uses the same kernel as the host machine, and only isolates OS-level applications (shells, utilities, libraries...). This is the reason that you cannot run Windows kernel containers on Linux and vice versa; containers share the host machine's kernel, making cross-kernel compatibility impossible. This makes Docker significantly faster and more efficient compared to a VM, especially for development and deployment. <br/>
Another key difference is how Docker consumes resources. A VM always has the resources that you give them. For example, if you give a VM 4 cpu cores and 4 GB of RAM, even if your VM is idle, those resources remain reserved for the VM. Docker, on the other hand, manages the resources dynamically. The docker daemon tracks how many resources the containers need, and frees / reserves resources on the go.
In summary, while both VMs and Docker offer isolation, Docker is a much faster and more efficient solution, especially for development and deployment, by only isolating OS-level applications, sharing the host machine's kernel and allocating resources dinamically.

![Docker vs VM](https://github.com/user-attachments/assets/4673b5b7-9f3b-4620-a162-7b91222f9085)

#### 1.1.4 Docker tools 📃​📦​:
Docker provides many tools that help us develop and deploy applications more easily and quickly. In this section, we will explore the most important ones and their purposes, such as Dockerfile, volumes, networks, and more. Every tool has an ID associated with it (imageID, containerID, volumeID...).
##### Dockerfile:
The Dockerfile is a text file that contains a set of instructions to build an image. These are written by the user and they correspond to the instructions you would normally execute with the Docker client, conventionally written in uppercase. <br/>
A key concept to understand about Dockerfiles is the build context. Instructions inside a Dockerfile cannot access files outside this context. Consider the following directory structure: `srcs/requirements/nginx/Dockerfile`. Every instruction written in the Dockerfile has `srcs/requirements/nginx/` as the working directory, and can access every file and directory inside of it, but no instruction can access files or directories outside it (e.g., `srcs/requirements/mariadb/tools/script.sh`). This is intentional, since containers (built from images) are isolated from one another and with the host, so it wouldn't make much sense to let a container (or a Dockerfile) access files that don't belong to them. This is also the reason why the Inception subject requires this directory structure; every configuration file and script should be saved at the same level (or below) as its corresponding Dockerfile. <br/>
There are many instructions you can use, but here are the ones we will use for Inception:
  - `FROM image`: This keyword is used to set the `image` argument as the base image for your build. Docker first pulls the base image from the configured registry, and runs the remaining Dockerfile instructions on top of that one. Every valid Dockerfile should start with the `FROM` keyword (with some exceptions).
  - `RUN command`: The `RUN` keyword lets you execute a shell command during the image build. This instruction is isolated from the host machine; this means that you cannot `RUN` a command to do something related to the host (for example, copying a file from the host to the image). If you want to install the SSH package inside the image, you would write `RUN apt install ssh`.
  - `WORKDIR image/path`: The `WORKDIR` instruction sets the current working directory inside the image. All paths specified from this will be relative to it. If no `WORKDIR` is specified, the default is `/`. 
  - `COPY host/path image/path`: This instruction is used to copy files from the host machine to the image. The `host/path` argument has the Dockerfile's build context, meaning if you write `COPY . image/path`, the `.` path is equivalent to the Dockerfile's directory path. The `image/path` argument has the `WORKDIR` instruction context, but you can specify an absolute path. For example, if you want to copy a configuration file you wrote to the image, you would run `COPY ./path/to/conf/file.conf /etc/conf/file.conf`.
  - `EXPOSE port`: This instruction tells Docker which ports our container is expected to publish. This keyword is merely informative; it doesn't actually open nor publish any port. It is used as a type of documentation to know which ports are intended to be published when running the container. To read about publishing ports, see the Docker Container section.
  - `ENTRYPOINT [ "exec", "arg1", ... ]` and `CMD [ "exec", "arg1", ... ]`: The `ENTRYPOINT` instruction specifies the command or script that is executed every time the container runs. When you run a container with `docker run`, regardless of it being the first time running or a re-run on a stopped container, the `ENTRYPOINT` will be executed. Docker keeps the container alive as long as the executable is running; once it stops, the container exits (see [1.1.5 The Docker entrypoint command and PID 1](#115-The-Docker-entrypoint-command-and-PID-1-)). <br/>
  The `CMD` keyword's function depends on whether `ENTRYPOINT` is present or not: If the `ENTRYPOINT` is not present in the Dockerfile, then the `CMD` specifies the same as `ENTRYPOINT` (the command or script to execute). But if the `ENTRYPOINT` is present, the `CMD` will specify the arguments of the `ENTRYPOINT` executable. <br/>
At least one of these two is needed to write a valid Dockerfile. To specify the executable and / or arguments you can either use the exec form (`[ "exec", "arg1", ... ]`) or the shell form (`exec arg1 ...`), though the exec form is preferred as it avoids an extra shell process. 

![ENTRYPOINT and CMD](https://github.com/user-attachments/assets/2a30bdd5-0050-40f5-ab42-1722bb2d02ef)

There are other keywords, like `USER user` to specify which user should execute the `ENTRYPOINT`, or `ENV key=VAR` to specify environment variables, but I will not cover them here. <br/>
To build an image from a Dockerfile, use the `docker build -t image_name -f path/to/Dockerfile path/to/build/context`, where the `-t` flag defines the image tag (or name) and the `-f` specifies the path to the Dockerfile you want to build (You can omit the `-f` flag if you are currently inside the Dockerfile's directory).

##### Docker image:
A Docker image is a package that includes all the files, binaries, and dependencies required to run a container. If you want to run a MariaDB container, its corresponding image would contain the mariadb-server binary, its configuration files, and its dependencies to ensure MariaDB runs correctly. For a Node.js application, the image would include the preferred Node.js version, the application's code, and other dependencies. An image is like a snapshot: an immutable object that contains the complete environment needed to run a designated application. Once an image is created, it cannot be modified. If you want to make changes to an image, you must either create a new one from scratch or add changes to an existing one (creating a new one in the process). <br/>
An important concept you should know about is image composition. Docker images are built in layers, where every instruction written in the Dockerfile is an image layer. A layer represents a set of changes inside the image and its file system, such as adding, removing or modifying files. Docker uses a build cache, where each image layer is cached and reused if possible. When you modify a Dockerfile instruction, or the file associated with it (e.g. changing the content of `main.c` used in `COPY ./main.c /srcs/`), Docker rebuilds that layer and the subsequent ones, reusing the cache for the ones that remain unchanged. This avoids redundant rebuilds, making the build process much faster. <br/>

![Docker build cache](https://github.com/user-attachments/assets/1c3c9a63-9906-47e3-8630-d0cd0854d73f)

When you build an image, it is saved on the host machine. If you want to use that image on multiple computers, or publish it so other people can use it, you need to store it in a Docker registry. The same applies if you want to use an already created image, like Debian or Ubuntu base images. When you are building an image, the `FROM` keyword pulls the base image from the configured Docker registry (Docker Hub by default), and builds the rest on top of it. Here are a few useful commands related to images:
  - `docker pull image[:tag]`: Pulls an image from the configured registry.
  - `docker push image[:tag]`: Pushes an image to a registry.
  - `docker rmi image1 [...]`: Removes one or more images.
  - `docker build -t image_name path/to/build/context`: Build an image from a Dockerfile (specifying the context).

To run a container from an image, use the command `docker run --name container_name image_name`, where the `--name` flag specifies the container name (it cannot be another container with the same name) and the image_name is the image you want to run the container from. By default, containers run as a foreground process, meaning the terminal remains occupied until the container exits. If you want to run the container as a background process (detached mode), you can add the `-d` or `--detach` flag. 

##### Docker container:
A Docker container is the isolated process that runs with the required dependencies to execute a designated application. The main difference between a Docker image and a Docker container is that a container is a running instance of an image (a mutable process), while the image is just the package that contains binaries and dependencies to run an application (it's an immutable file, not a process). <br/>
A container is self-contained and isolated, meaning it has minimal influence on the host machine and other containers, and it doesn't rely on any host machine dependencies to work or execute their designated application (a container doesn't need the host machine to have python installed for it to execute a python application). This increases security and makes them more portable, as containers only need to have Docker installed on the host machine to work. They are also independent from one another, meaning that stopping or deleting a container won't affect others. <br/>
However, sometimes you need to enable communication between containers and with the host machine. For example, in a microservices architecture (the one that the Inception project uses), every service, such as the frontend, the backend or the database, is run in a different server (or container when using Docker), and they communicate with each other via TCP connections. This ensures scalability, as each service is encapsulated and easier to troubleshoot or scale independently. For Inception project, you must set one container per service (Nginx, Wordpress, MariaDB...). As containers are isolated from each other, we need to find a way to communicate MariaDB's container with Wordpress's container, and so on. We can achieve this using Docker networks and publishing ports, which I will cover later in this section. <br/>
Something to be also aware of is data persistence inside a container. Containers are designed to be ephemeral; if something breaks in your application and the container results unusable, you only need to fix your application, rebuild the image and run a container. In other words, the only useful thing inside a container is your application. Containers are primarily a tool for deployment, not as a long-term data storage. This is why any data stored inside a container is lost when the container is deleted; it's not considered useful. Nevertheless, data persistence is important in many applications and services, like a database. To prevent data loss, you can set up Docker volumes, which I will cover later in this section. <br/>
Here is a list of useful Docker client commands you can use related to containers:
  - `docker ps`: This command lists all the running containers and their information (ID, name, `ENTRYPOINT`, status...). Add the `-a` flag to also list stopped and exited containers.
  - `docker logs container_name`: Prints the logs of a container (messages printed by the `ENTRYPOINT` command).
  - `docker run -d --name container_name image_name`: Runs a container from an image.
  - `docker stop containerID`: Stops a container. A stopped container can be run again with `docker start`.
  - `docker start containerID`: Starts a stopped container.
  - `docker rm containerID`: Removes a container from the host machine. Add the `-v` to also remove the anonymous volumes associated with it.
  - `docker exec container_name command arg1 [...]`: Executes a command inside a container. The output of the command is printed to `stdout`. A really useful way to use this command is executing `docker exec -it container_name bash`. The `-i` flag activates interactive mode, meaning it keeps STDIN open even if the container is not attached to the terminal (`docker run -d`), and the `-t` allocates a pseudo-tty (pseudo-terminal) inside the container. In other words, this command allows us to interact with the container file system via bash, and lets us debug possible errors, misconfigurations, and more.

![Analogy Docker - C program](https://github.com/user-attachments/assets/c2b7b6fe-8c24-41b8-b285-a6e2fd3e0c8c)

#### 1.1.5 The Docker entrypoint command and PID 1 👑⚡:


## Concepts
### Docker
#### What is Docker
#### How Docker works
#### VM vs Docker
#### Docker elements
##### Common instructions (FROM, RUN...)
#### Why is PID 1 important
### Docker Compose
#### What is Docker Compose
#### Differences between using only Docker or Docker Compose
#### The compose file
##### Top level instructions (version, name, services, volumes, networks, configs and secrets)
### Inception's infrastructure
#### MariaDB
#### PHP-FPM
##### What is a CGI
##### How does a CGI work
##### Differences between CGI and FastCGI
##### What is PHP-FPM
#### Wordpress
##### How does wordpress work with a CGI (PHP-FPM)
#### Nginx + TLS
##### What is Nginx and how does it work
##### What is SSL and TLS
##### How does it work
##### Things you need to know (RSA)
#### Adminer
#### Redis
##### What means to use cache in a website
##### Why is useful to use cache in a website
##### What is redis object cache
#### FTP server
##### What is FTP
##### How does FTP work
## Walkthrough
### MariaDB
### Starting the compose file
### Wordpress and php-fpm
### Nginx
### Bonus
#### Redis cache
#### FTP server
#### Static web
#### Adminer
#### Custom service (Volume initializer)
## Useful tips
## Sources


# Docker
https://docs.docker.com/get-started/docker-overview/ <br/>
https://github.com/antontkv/docker-and-pid1


# How does Nginx + php-fpm + WordPress ecosystem works
What really is wordpress and how it works: https://en.wikipedia.org/wiki/WordPress <br/>
Wordpress builds only dynamic websites: https://www.liquidweb.com/wordpress/php/ <br/>
How nginx works with php-fpm to return static AND dynamic websites: https://www.sitepoint.com/lightning-fast-wordpress-with-php-fpm-and-nginx/ <br/>
How does wordpress, php-fpm and nginx work together: https://flywp.com/blog/9281/optimize-php-fpm-settings-flywp/ <br/>
PHP workers: https://spinupwp.com/doc/how-php-workers-impact-wordpress-performance/ <br/>
Differences between CGI, FastCGI and FPM: <br/>
1. https://help.quickhost.uk/index.php/knowledge-base/whats-the-difference-between-cgi-dso-suphp-and-lsapi-php <br/>
2. https://serverfault.com/questions/645755/differences-and-dis-advanages-between-fast-cgi-cgi-mod-php-suphp-php-fpm <br/>
3. https://www.basezap.com/difference-php-cgi-php-fpm/

# MariaDB
https://github.com/MariaDB/mariadb-docker/blob/2d5103917774c4c53ec6bf3c6fdfc7b210e85690/11.8/Dockerfile <br/>
AND Executing a simple Dockerfile with mariadb and seeing what's wrong:
~~~
FROM debian:bullseye

RUN apt update \
    && apt install -y --no-install-recommends mariadb-server

ENTRYPOINT ["mariadbd"]
~~~
MARIADB-SERVER => Program with all the database management (the only one needed) <br/>
MARIADB-CLIENT => CLI program with a SQL syntax shell to interact with the server

This doesn't work. On docker logs, you can read that you need this:
~~~
FROM debian:bullseye

RUN apt update \
    && apt install -y --no-install-recommends mariadb-server

RUN mkdir -p /run/mysqld && \
   chown mysql:mysql /run/mysqld && \
   chmod 777 /run/mysqld

ENTRYPOINT ["mariadbd"]
~~~
Why: https://superuser.com/questions/980841/why-is-mysqld-pid-and-mysqld-sock-missing-from-my-system-even-though-the-val <br/>
/var/run is a symlink to /run in modern OS, so the mysqld directory should be under /run (ls -la /var/run) <br/>
/run is a tmpfs (mounted on the RAM) folder that stores runtime-files, so everytime mariadbd is executed it stores its files there


## Config file
Why are there so many configuration folders?: <br/>
https://mariadb.com/kb/en/configuring-mariadb-with-option-files/ <br/>
https://www.baeldung.com/linux/mysql-find-my-cnf-command-line <br/>
AND Executing a simple Dockerfile with mariadb and read all the configuration files in /etc/mysql (/etc/mysql/*)

When you install MariaDB, every tool installed named mysql... is a symlink to its version of mariadb (configuration, binaries...) <br/>
https://mariadb.com/kb/en/mysql_secure_installation/ <br/>
https://mariadb.com/kb/en/mysql_install_db/

### Why is it called 50-server.cnf
50: Load order (if you have a 10-server.cnf, some of its configuration may be overriden by 50-server.cnf, as its loaded later) <br/>
Server: Arbitrary name, you can name it as you want (but it should make sense) <br/>
https://askubuntu.com/questions/1271400/unknown-variable-pid-file-run-mysqld-mysqld-pid-when-setting-50-server-cnf

### Server system variables
https://mariadb.com/kb/en/server-system-variables/#basedir

### Character-encoding config
https://stackoverflow.com/questions/30074492/what-is-the-difference-between-utf8mb4-and-utf8-charsets-in-mysql <br/>
https://stackoverflow.com/questions/766809/whats-the-difference-between-utf8-general-ci-and-utf8-unicode-ci <br/>

### Failed to configure mariadb without writting "user" variable in mariadb.conf
It tries to execute mariadbd as root and fails <br/>
https://stackoverflow.com/questions/25700971/fatal-error-please-read-security-section-of-the-manual-to-find-out-how-to-run

After configuration:
~~~
FROM debian:bullseye

RUN apt update \
    && apt install -y --no-install-recommends mariadb-server

COPY ./conf/mariadb.conf /etc/mysql/mariadb.conf.d/50-server.cnf

RUN mkdir -p /run/mysqld && \
    chown mysql:mysql /run/mysqld && \
    chmod 777 /run/mysqld

ENTRYPOINT [ "mariadbd" ]
~~~


## Where does MariaDB saves its databases as default (storage directory)
https://mariadb.com/kb/en/default-data-directory-for-mariadb/


## MariaDB Server and Client differences
mariadbd: server (daemon process that manages all the databases) <br/>
mariadb: client (CLI program that gives you a SQL shell to interact with the server via queries) <br/>
https://mariadb.com/docs/server/connect/clients/mariadb-client/

Why do we have mariadb installed?: Because its impossible to interact with the server (and databases) without one. The package
mariadb-server depends on mariadb-client, so it's installed at the same time. <br/>
Proof: apt show mariadb-server and then apt show mariadb-server-x.x.x (the version that appears in DEPENDS)


## MariaDB system databases
https://mariadb.com/kb/en/understanding-mariadb-architecture/ <br/>
https://mariadb.com/kb/en/the-mysql-database-tables/ <br/>
https://mariadb.com/kb/en/use-database/


## What should you do after installing mariadb-server package?
After installing the package and successfully configuring it with 50-server.cnf: <br/>
https://greenwebpage.com/community/how-to-install-mariadb-on-ubuntu-24-04/ <br/>
https://mariadb.com/kb/en/mariadb-install-db/

But, it is necessary to run mariadb-install-db if you already have a working datadir and system databases? NO: <br/>
https://serverfault.com/questions/1015287/is-mysql-install-db-needed-to-install-mariadb

But mariadb-secure-installation it's still recommended as it's for security concerns, so: <br/>
https://mariadb.com/kb/en/mariadb-secure-installation/ <br/>
https://mariadb.org/authentication-in-mariadb-10-4/


## Creating the script init_mariadb.sh
### Mariadb secure installation
1. Install the secure policies:
~~~
#! /bin/bash

install_secure_policies()
{
	mariadb-secure-installation <<- _EOF_

		y
		y
		$MARIADB_ROOT_PASSWORD
		$MARIADB_ROOT_PASSWORD
		y
		y
		y
		y
	_EOF_
}

install_secure_policies
mariadbd
~~~
2. Copying it to the /root folder
~~~
FROM debian:bullseye

RUN apt update \
    && apt install -y --no-install-recommends mariadb-server

COPY ./conf/mariadb.conf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY ./tools/init_mariadb.sh /root

RUN mkdir -p /run/mysqld && \
    chown mysql:mysql /run/mysqld && \
    chmod 777 /run/mysqld

ENTRYPOINT [ "/root/init_mariadb.sh" ]
~~~
3. Can't execute the container due to permission denied (missing execution permissions)
~~~
COPY --chmod=700 ./tools/init_mariadb.sh /root
~~~
4. Doesn't work because it cannot establish connection, as the socket is not initialized. To do so, we need to enable the service: <br/>
https://discourse.ubuntu.com/t/mariadb-error-2002-hy000-cant-connect-to-local-server-through-socket-run-mysqld-mysqld-sock-2/53941 <br/>
https://discourse.ubuntu.com/t/mariadb-error-2002-hy000-cant-connect-to-local-server-through-socket-run-mysqld-mysqld-sock-2/53941
~~~
[...]

service mariadb start
install_secure_policies
service mariadb stop
mariadbd
~~~
5. Now doesn't work because mariadb-secure-installation expects a tty and not a heredoc. So we need to do the operations manually: <br/>
https://stackoverflow.com/questions/24270733/automate-mysql-secure-installation-with-echo-command-via-a-shell-script <br/>
and going to mariadb container and doing cat /usr/bin/mariadb-secure-installation, copying the queries <br/>
https://mariadb.com/kb/en/authentication-plugin-unix-socket/ <br/>
As the unix_socket is now enabled by default, there is no need to enable it again <br/>
Final result:
~~~
#! /bin/bash

intialize_service()
{
    service mariadb start
    sleep 1
}

install_secure_policies()
{
    # Remove anonymous users
    mariadb -e "DELETE FROM mysql.user WHERE User='';"

    # Disallow remote root login
    mariadb -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"

    # Remove test database and privileges on this database
    mariadb -e "DROP DATABASE IF EXISTS test;"
    mariadb -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'"

    # Reload privilege tables
    mariadb -e "FLUSH PRIVILEGES;"
}

intialize_service
install_secure_policies
service mariadb stop

mariadbd
~~~

# Create a simple compose file with only mariadb
https://docs.docker.com/reference/compose-file/ <br/>
https://docs.docker.com/reference/compose-file/services/ <br/>
https://docs.docker.com/reference/compose-file/build/ <br/>
https://docs.docker.com/reference/compose-file/volumes/ <br/>
https://docs.docker.com/engine/storage/volumes/#mounting-a-volume-over-existing-data <br/>
https://docs.docker.com/engine/extend/legacy_plugins/ <br/>
https://docs.docker.com/reference/compose-file/networks/ <br/>

## Creating wordpress database volume
Having this simple docker-compose.yml:
~~~
name: inception

services:
  mariadb:
    container_name: mariadb
    build: requirements/mariadb
    restart: always

~~~
We need to create the database volume.
~~~
volumes:
  database:
    driver: local
    driver_opts:
      type: none
      device: ${VOLUMES_PATH}database
      o: bind
~~~
https://stackoverflow.com/questions/74079078/what-is-the-meaning-of-the-type-o-device-flags-in-driver-opts-in-the-docker-comp <br/>
https://stackoverflow.com/questions/71660515/docker-compose-how-to-remove-bind-mount-data <br/>
https://docs.docker.com/compose/how-tos/environment-variables/variable-interpolation/

Final result:
~~~
name: inception

services:
  mariadb:
    container_name: mariadb
    build: requirements/mariadb
    volumes:
      - database:/var/lib/mysql
    restart: always

volumes:
  database:
    driver: local
    driver_opts:
      type: none
      device: ${VOLUMES_PATH}database
      o: bind
~~~


## Creating initial queries
As wordpress will connect to create the necessary tables, should we create the database or its created by default?: YES <br/>
https://wpdataaccess.com/docs/remote-databases/mysql-mariadb/ <br/>
https://www.sitepoint.com/community/t/how-does-wordpress-automatically-create-a-database-on-installation/112298 <br/>
https://ubuntu.com/tutorials/install-and-configure-wordpress#5-configure-database

Steps:
1. Create database: https://mariadb.com/kb/en/create-database/ <br/>
2. Create user to handle the database: <br/>
https://mariadb.com/kb/en/create-user/ <br/>
https://stackoverflow.com/questions/12931991/mysql-what-does-stand-for-in-host-column-and-how-to-change-users-password <br/>
3. Grant privileges on the database: https://mariadb.com/kb/en/grant/ <br/>
4. Refresh
~~~
[...]

initial_transaction()
{
    mariadb -e "CREATE DATABASE IF NOT EXISTS $DATABASE_NAME;"
    mariadb -e "CREATE USER IF NOT EXISTS '$DATABASE_USER_NAME'@'%' IDENTIFIED BY '$DATABASE_USER_PASSWORD';"
    mariadb -e "GRANT ALL ON $DATABASE_NAME.* TO '$DATABASE_USER_NAME'@'%';"
    mariadb -e "FLUSH PRIVILEGES;"
}

intialize_service
install_secure_policies
initial_transaction
service mariadb stop
~~~

Final init_mariadb.sh result:
~~~
#! /bin/bash

intialize_service()
{
    service mariadb start
    sleep 1
}

install_secure_policies()
{
    # Remove anonymous users
    mariadb -e "DELETE FROM mysql.user WHERE User='';"

    # Disallow remote root login
    mariadb -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"

    # Remove test database and privileges on this database
    mariadb -e "DROP DATABASE IF EXISTS test;"
    mariadb -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'"

    # Reload privilege tables
    mariadb -e "FLUSH PRIVILEGES;"
}

initial_transaction()
{
    mariadb -e "CREATE DATABASE IF NOT EXISTS $DATABASE_NAME;"
    mariadb -e "CREATE USER IF NOT EXISTS '$DATABASE_USER_NAME'@'%' IDENTIFIED BY '$DATABASE_USER_PASSWORD';"
    mariadb -e "GRANT ALL ON $DATABASE_NAME.* TO '$DATABASE_USER_NAME'@'%';"
    mariadb -e "FLUSH PRIVILEGES;"
}

intialize_service
install_secure_policies
initial_transaction
service mariadb stop

mariadbd
~~~


# Wordpress and php-fpm
## Installing php-fpm
We need to install wordpress and php-fpm (PHP fastcgi process manager). <br/>
PHP package tries to install Apache2 (even some modules of PHP try to install it too), so we need to install php-fpm alone <br/>
https://askubuntu.com/questions/1160433/how-to-install-php-without-apache-webserver <br/>
Starting Dockerfile with only php-fpm
~~~
FROM debian:bullseye

RUN apt update && \
    apt install -y --no-install-recommends php-fpm

EXPOSE 9000

ENTRYPOINT [ "tail", "-f", "/dev/null" ]
~~~
The <code>tail -f /dev/null</code> it's temporal, we will override it at the end


## Install and configure wordpress
### Install wp-cli
As wordpress must be installed and configured from start, without admin panel, we have to install wp-cli to install wordpress with it <br/>
https://make.wordpress.org/cli/handbook/guides/installing/
~~~
[...]

RUN apt update && \
    apt install -y --no-install-recommends php-fpm curl

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

[...]
~~~
It fails: curl: (77) error setting certificate verify locations:  CAfile: /etc/ssl/certs/ca-certificates.crt CApath: /etc/ssl/certs <br/>
https://askubuntu.com/questions/1390288/curl-77-error-setting-certificate-verify-locations-ubuntu-20-04-3-lts <br/>
So we need to install ca-certificates
~~~
[...]

RUN apt update && \
    apt install -y --no-install-recommends php-fpm curl ca-certificates

[...]
~~~
We can enter the container with a shell and execute wp --info to see it's installed properly. <br/>
Final result:
~~~
FROM debian:bullseye

RUN apt update && \
    apt install -y --no-install-recommends php-fpm curl ca-certificates

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

EXPOSE 9000

ENTRYPOINT [ "tail", "-f", "/dev/null" ]
~~~
If we try to enter the container and execute wp core --help, it will deny because we are not root. So from now on, we will have to add
--allow-root to all the queries <br/>
https://www.reddit.com/r/Wordpress/comments/dwukz2/running_wpcli_commands_as_root/


### Install and configure wordpress using wp-cli
First, we need to add the wordpress service, volume and network to compose so we can fully test it works with mariadb container and .env
~~~
name: inception

services:
  mariadb:
    container_name: mariadb
    build: requirements/mariadb
    volumes:
      - database:/var/lib/mysql
    networks:
      - backend
    env_file: .env
    restart: always
  wordpress:
    container_name: wordpress
    build: requirements/wordpress
    volumes:
      - website:/var/www/html
    networks:
      - backend
    env_file: .env
    restart: always
    depends_on:
      - mariadb

networks:
  backend:
    driver: bridge

volumes:
  database:
    driver: local
    driver_opts:
      type: none
      device: ${VOLUMES_PATH}database
      o: bind
  website:
    driver: local
    driver_opts:
      type: none
      device: ${VOLUMES_PATH}website
      o: bind
~~~
Then, we download, configure and install wordpress with wp-cli: <br/>
https://make.wordpress.org/cli/handbook/how-to/how-to-install/ <br/>
We also need to create a non-admin user so: <br/>
https://developer.wordpress.org/cli/commands/user/create/

For it, we create init_wordpress.sh: <br/>
~~~
#! /bin/bash

install_and_configure_wordpress()
{
    if [ -f wp-config.php ]; then return 0; fi

    wp core download --allow-root
    wp config create --dbname=$DATABASE_NAME --dbuser=$DATABASE_USER_NAME --dbpass=$DATABASE_USER_PASSWORD --allow-root
    wp core install --url=$DOMAIN_NAME --title="$WEBSITE_TITLE" --admin_user=$WEBSITE_ADMIN_USER --admin_password=$WEBSITE_ADMIN_PASSWORD --allow-root
    wp user create $WEBSITE_AUTHOR_USER $WEBSITE_AUTHOR_EMAIL --role=author --user_pass=$WEBSITE_AUTHOR_PASSWORD --allow-root
}

install_and_configure_wordpress
tail -f /dev/null
~~~
And as we want to execute the php-fpm as daemon, we need to execute it with the flag -F: <br/>
https://stackoverflow.com/questions/37313780/how-can-i-start-php-fpm-in-a-docker-container-by-default
~~~
[...]

php-fpm7.4 -F
~~~
Also, wordpress must be installed in the root directory of nginx, so we set the workdir there: <br/>
https://serverfault.com/questions/718449/default-directory-for-nginx
~~~
[...]

WORKDIR /var/www/html

[...]
~~~

We see 2 errors: <br/>
1. Undefined function mysqli_init(): <br/>
https://serverfault.com/questions/971430/wordpress-php-uncaught-error-call-to-undefined-function-mysql-connect <br/>
We need to install the minimum equired php extensions for wordpress to work properly, which includes php-mysqli: <br/>
https://make.wordpress.org/hosting/handbook/server-environment/#php-extensions
~~~
[...]

RUN apt update && \
    apt install -y --no-install-recommends php-fpm curl ca-certificates php-mysqli php-json

[...]
~~~
2. Unable to bind socket for address /run/php/php7.4-fpm.sock <br/>
Similar to how we fixed it in mariadb container, we need to create /run/php: <br/>
~~~
[...]

RUN mkdir -p /run/php && \
    chmod 777 /run/php

[...]
~~~
Final result of Dockerfile:
~~~
FROM debian:bullseye

RUN apt update && \
    apt install -y --no-install-recommends php-fpm curl ca-certificates php-mysqli php-json

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

RUN mkdir -p /run/php && \
    chmod 777 /run/php

COPY --chmod=700 ./tools/init_wordpress.sh /root/init_wordpress.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT [ "/root/init_wordpress.sh" ]
~~~
This also fails because it tries to send an email to the admin_email. We can prevent it with --skip-email <br/>
https://github.com/wp-cli/wp-cli/issues/1172 <br/>
Final result:
~~~
#! /bin/bash

install_and_configure_wordpress()
{
    if [ -f wp-config.php ]; then return 0; fi

    wp core download --allow-root
    wp config create --dbname=$DATABASE_NAME --dbuser=$DATABASE_USER_NAME --dbpass=$DATABASE_USER_PASSWORD --allow-root
    wp core install --url=$DOMAIN_NAME --title="$WEBSITE_TITLE" --admin_user=$WEBSITE_ADMIN_USER --admin_password=$WEBSITE_ADMIN_PASSWORD --skip-email --allow-root
    wp user create $WEBSITE_AUTHOR_USER $WEBSITE_AUTHOR_EMAIL --role=author --user_pass=$WEBSITE_AUTHOR_PASSWORD --allow-root
}

install_and_configure_wordpress
php-fpm7.4 -F
~~~


## Configure php-fpm pools
https://www.digitalocean.com/community/tutorials/php-fpm-nginx <br/>
https://www.php.net/manual/en/install.fpm.configuration.php <br/>
and going to the wordpress container and reading the configuratin under /etc/php/x.x/fpm/pool.d/www.conf <br/>
What is the user www-data: https://askubuntu.com/questions/873839/what-is-the-www-data-user <br/>
Final result (remind that ; are comments here):
~~~
[inception]
; User and group that will execute the pool of processes
user = www-data
group = www-data

; What interfaces (IPs) and port should listen
listen = 0.0.0.0:9000

; How will fpm manage the pool processes: Dynamic means the number of
; processes will fluctuate, but there will be at least one children
pm = dynamic

; Maximum of processes alive (in other words, maximum of requests handled at the same time)
pm.max_children = 20

; Number of processes at start
pm.start_servers = 10

; Minimum 'idle' processes (waiting for process). If there are less 'idle' processes than
; this directive, some children processes will be created
pm.min_spare_servers = 1

; Maximum 'idle' processes (waiting for process). If there are more 'idle' processes than
; this directive, some children processes will be killed
pm.max_spare_servers = 15
~~~
How does php-fpm differentiate which pool configuration use on every request?: <br/>
Answer: By the listen directive. Every request coming in a concrete tcp / unix socket will
use the pool directive configured for that listen directive <br/>
https://www.tecmint.com/connect-nginx-to-php-fpm/

On the Dockerfile, we need to copy the configuration:
~~~
[...]

COPY ./conf/inception_pool.conf /etc/php/7.4/fpm/pool.d/inception.conf

[...]
~~~
Final result:
~~~
FROM debian:bullseye

RUN apt update && \
    apt install -y --no-install-recommends php-fpm curl ca-certificates php-mysqli php-json

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

RUN mkdir -p /run/php && \
    chmod 777 /run/php

COPY ./conf/inception_pool.conf /etc/php/7.4/fpm/pool.d/inception.conf

COPY --chmod=700 ./tools/init_wordpress.sh /root/init_wordpress.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT [ "/root/init_wordpress.sh" ]
~~~


# Nginx
Create a Dockerfile and install nginx only <br/>
To run nginx as a foreground process: https://www.uptimia.com/questions/how-to-run-nginx-in-the-foreground-within-a-docker-container
~~~
FROM debian:bullseye

RUN apt update && \
	apt install -y --no-install-recommends nginx

ENTRYPOINT [ "nginx", "-g", "daemon off;" ]
~~~
## Add nginx service to docker-compose
Is the same as the other services but we need to add port forwarding (publishing ports). <br/>
For testing purposes, we will map the container port 80 with the host port 80 (when we add the
SSL certificate we will map both 443): <br/>
https://docs.docker.com/reference/compose-file/services/#ports <br/>
We do this because the browser expects a secure connection on the port 443, and if the server can't
handle it (as we didn't configure nginx, neither create a certificate), it returns a connection reset error: <br/>
You can check this on /etc/nginx/sites-available/default and https://serverfault.com/questions/842779/set-nginx-https-on-port-443-without-the-certificate <br/>
We also need to create a new network for the "frontend" part of the app (wordpress - nginx) <br/>
docker-compose.yml:
~~~
[...]
  nginx:
    container_name: nginx
    build: requirements/nginx
    volumes:
      - website:/var/www/html
    networks:
      - frontend
    ports:
      - "80:80"
    restart: always
    depends_on:
      - wordpress

networks:
  [...]
  frontend:
    driver: bridge

[...]
~~~
Nginx Dockerfile:
~~~
[...]

EXPOSE 80

[...]
~~~

## Configure Nginx to redirect the requests to our wordpress container
We need to create the configuration to listen on port 80 (we will change it to 443 later), with the
login.42.fr as domain, and to serve both static and dynamic files (using php-fpm on wordpress container) <br/>
https://nginx.org/en/docs/beginners_guide.html <br/>
https://nginx.org/en/docs/http/request_processing.html <br/>
https://nginx.org/en/docs/http/ngx_http_core_module.html
~~~
server {
    # Listen to specific port for IPv4 and IPv6
    listen 80;
    listen [::]:80;

    # Listen to requests that comes from this specific domain
    server_name cfidalgo.42.fr;

    # Set the root directory of every file (request of index.php will return /var/www/html/index.php).
    # The root must much with the wordpress files volume
    root /var/www/html;

    # Directive for every request that starts with / (every request, its a catch-all location)
    # setting the index file (the main file)
    location / {
        index index.html index.php;
    }

    # Directive for every request that finishes with .php
    location ~ \.php$ {
        # Pass the .php files to the FPM listening on this address
        fastcgi_pass  wordpress:9000;

        # FPM variables that set the full path to the file (/var/www/html/index.php) and the
        # file name itself (/index.php)
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param QUERY_STRING    $query_string;
    }
}
~~~
Where do we need to paste this config? Answer: /etc/nginx/sites-available and make a link to
it in sites-enabled (better practice). Or just in sites-enabled / conf.d directories if you are too lazy: <br/>
https://www.fegno.com/nginx-configuration-file-to-host-website-on-ubuntu/
~~~
[...]

COPY ./conf/inception_server.conf /etc/nginx/sites-available/

RUN ln -s /etc/nginx/sites-available/inception_server.conf /etc/nginx/sites-enabled/

EXPOSE 80

WORKDIR /var/www/html

[...]
~~~
This fails. All pages appears to be blank. This is caused because we need to pass more fastcgi_param variables to the php server. <br/>
https://nginx.org/en/docs/http/ngx_http_fastcgi_module.html <br/>
https://developer.wordpress.org/advanced-administration/server/web-server/nginx/ <br/>
If we also go to the container of nginx and cat /etc/nginx/fastcgi.conf, we can see it contains all necessary variables for us
~~~
[...]

    # Directive for every request that finishes with .php
    location ~ \.php$ {
        # Pass the .php files to the FPM listening on this address
        fastcgi_pass  wordpress:9000;

        # Include the necessary variables
        include fastcgi.conf;
    }

[...]
~~~
This works, but we can improve this with some small details. <br/>
First, add the index directive to the server context directly (instead of the location) to get an index in every location. <br/>
https://nginx.org/en/docs/http/ngx_http_index_module.html <br/>
We can also add try_files directive to try the existence of the static files and process the request with them, or define another behavior <br/>
https://nginx.org/en/docs/http/ngx_http_core_module.html#try_files <br/>
https://en.wikipedia.org/wiki/Uniform_Resource_Identifier <br/>
Final result:
~~~
server {
    # Listen to specific port for IPv4 and IPv6
    listen 80;
    listen [::]:80;

    # Listen to requests that comes from this specific domain
    server_name cfidalgo.42.fr;

    # Set the root directory of every file (request of index.php will return /var/www/html/index.php)
    root /var/www/html;

    # Set the index file (the main file) globally, for every location
    index index.html index.php;

    # Directive for every request that starts with / (every request, its a catch-all location)
    location / {
        # Check if the static file exists. If not, check if the index file at that directory exists.
        # If neither exists, error 404 not found
        try_files $uri $uri/ =404;
    }

    # Directive for every request that finishes with .php
    location ~ \.php$ {
        # Check if php file exists; if not, error 404 not found
        try_files $uri =404;

        # Pass the .php files to the FPM listening on this address
        fastcgi_pass  wordpress:9000;

        # Include the necessary variables
        include fastcgi.conf;
    }
}
~~~


## TLS certificate
What is SSL and TLS: <br/>
https://www.cloudflare.com/learning/ssl/what-is-ssl/ <br/>
https://www.cloudflare.com/learning/ssl/what-happens-in-a-tls-handshake/ <br/>
https://www.cloudflare.com/learning/ssl/how-does-ssl-work/ <br/>
https://blog.cloudflare.com/rfc-8446-aka-tls-1-3/ <br/>
Why using RSA as the encrypting algorithm is dangerous:
https://crypto.stackexchange.com/questions/47512/why-plain-rsa-encryption-does-not-achieve-cpa-security <br/>

We need to create a self-signed certificate, with both it's public and private key: <br/>
https://dev.to/techschoolguru/how-to-create-sign-ssl-tls-certificates-2aai <br/>
https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-nginx-in-ubuntu <br/>
We will create it in the create_tls_cert.sh script:
~~~
#! /bin/bash

create_tls_cert()
{
    if [ -f /etc/ssl/certs/inception.crt ] && [ -f /etc/ssl/private/inception.key ]; then return 0; fi;

    openssl req -x509 \
                -nodes \
                -days 365 \
                -newkey rsa:4096 \
                -keyout /etc/ssl/private/inception.key \
                -out /etc/ssl/certs/inception.crt \
                -subj "/C=SP/ST=Barcelona/L=Barcelona/O=42bcn/OU=42bcn/CN=cfidalgo.42.fr/emailAddress=cfidalgo@gmail.com"
}

create_tls_cert
nginx -g 'daemon off;'
~~~
Then, in Dockerfile:
~~~
[...]

COPY --chmod=700 ./tools/create_tls_cert.sh /root/

[...]

ENTRYPOINT [ "/root/create_tls_cert.sh" ]
~~~

Then, we need to adapt our nginx server to accept SSL connections: <br/>
http://nginx.org/en/docs/http/configuring_https_servers.html <br/>
On our nginx configuration:
~~~
server {
    # Listen to specific port for IPv4 and IPv with TLS connections
    listen 443 ssl;
    listen [::]:443 ssl;

    # Listen to requests that comes from this specific domain
    server_name cfidalgo.42.fr;

    # Locations of the SSL cert and key
    ssl_certificate     /etc/ssl/certs/inception.crt;
    ssl_certificate_key /etc/ssl/private/inception.key;

    # Which TLS protocol is active
    ssl_protocols       TLSv1.3;

   [...]

}
~~~
We also need to expose the port 443 and publish it too on the docker-compose.yml: <br/>
Dockerfile
~~~
[...]

EXPOSE 443

[...]
~~~
docker-compose.yml
~~~
[...]
    ports:
      - "443:443"
[...]
~~~


# Add Docker secrets
In a production environment, you would use secrets for sensitive data: <br/>
https://docs.docker.com/reference/compose-file/services/#secrets <br/>
https://docs.docker.com/reference/compose-file/secrets/ <br/>
We need to create a secret for every sensitive variable, and replace that .env variable for the path to their
relative secret <br/>
.env before:
~~~
VOLUMES_PATH=PATH_TO_VOLUMES_DIRECTORY
DOMAIN_NAME=YOUR_DOMAIN_NAME

DATABASE_NAME=THE_MARIADB_DATABASE_NAME
DATABASE_USER_NAME=THE_MARIADB_DATABASE_USER_NAME
DATABASE_USER_PASSWORD=THE_MARIADB_DATABASE_USER_PASSWORD

DATABASE_HOST=THE_SERVICE_NAME_OF_THE_DATABASE
WEBSITE_TITLE=THE_WEBSITE_TITLE
WEBSITE_AUTHOR_USER=THE_WORDPRESS_AUTHOR_USER
WEBSITE_AUTHOR_PASSWORD=THE_WORDPRESS_AUTHOR_PASSWORD
WEBSITE_AUTHOR_EMAIL=THE_WORDPRESS_AUTHOR_EMAIL
WEBSITE_ADMIN_USER=THE_WORDPRESS_ADMIN_USER
WEBSITE_ADMIN_PASSWORD=THE_WORDPRESS_ADMIN_PASSWORD
WEBSITE_ADMIN_EMAIL=THE_WORDPRESS_ADMIN_EMAIL
~~~
and .env after
~~~
VOLUMES_PATH=PATH_TO_VOLUMES_DIRECTORY
DOMAIN_NAME=YOUR_DOMAIN_NAME

DATABASE_NAME_SECRET_PATH=PATH_TO_THE_SECRET                # Extracted to a secret; Now the variable contains the secret path
DATABASE_USER_NAME_SECRET_PATH=PATH_TO_THE_SECRET           # Extracted to a secret; Now the variable contains the secret path
DATABASE_USER_PASSWORD_SECRET_PATH=PATH_TO_THE_SECRET       # Extracted to a secret; Now the variable contains the secret path

DATABASE_HOST=THE_SERVICE_NAME_OF_THE_DATABASE
WEBSITE_TITLE=THE_WEBSITE_TITLE
WEBSITE_AUTHOR_USER=THE_WORDPRESS_AUTHOR_USER
WEBSITE_AUTHOR_PASSWORD_SECRET_PATH=PATH_TO_THE_SECRET      # Extracted to a secret; Now the variable contains the secret path
WEBSITE_AUTHOR_EMAIL=THE_WORDPRESS_AUTHOR_EMAIL
WEBSITE_ADMIN_USER_SECRET_PATH=PATH_TO_THE_SECRET           # Extracted to a secret; Now the variable contains the secret path
WEBSITE_ADMIN_PASSWORD_SECRET_PATH=PATH_TO_THE_SECRET       # Extracted to a secret; Now the variable contains the secret path
WEBSITE_ADMIN_EMAIL_SECRET_PATH=PATH_TO_THE_SECRET          # Extracted to a secret; Now the variable contains the secret path

SECRETS_PREFIX=/run/secrets                                 # New variable; Secrets directory inside a container
~~~

Then, on the docker-compose.yml, we create the secrets directive:
~~~
[...]

secrets:
  database_name:
    file: ${DATABASE_NAME_SECRET_PATH}
  database_user_name:
    file: ${DATABASE_USER_NAME_SECRET_PATH}
  database_user_password:
    file: ${DATABASE_USER_PASSWORD_SECRET_PATH}
  website_admin_email:
    file: ${WEBSITE_ADMIN_EMAIL_SECRET_PATH}
  website_admin_password:
    file: ${WEBSITE_ADMIN_PASSWORD_SECRET_PATH}
  website_admin_user:
    file: ${WEBSITE_ADMIN_USER_SECRET_PATH}
  website_author_password:
    file: ${WEBSITE_AUTHOR_PASSWORD_SECRET_PATH}
~~~
And also add the necessary secrets to each service:
~~~
name: inception

services:
  mariadb:
    container_name: mariadb
    build: requirements/mariadb
    volumes:
      - database:/var/lib/mysql
    networks:
      - backend
    secrets:
      - database_name
      - database_user_name
      - database_user_password
    env_file: .env
    restart: always
  wordpress:
    container_name: wordpress
    build: requirements/wordpress
    volumes:
      - website:/var/www/html
    networks:
      - backend
      - frontend
    secrets:
      - database_name
      - database_user_name
      - database_user_password
      - website_admin_email
      - website_admin_password
      - website_admin_user
      - website_author_password
    env_file: .env
    restart: always
    depends_on:
      - mariadb
    [...]
~~~

Lastly, replace the variables in the scripts for the secrets: <br/>
In init_mariadb.sh:
~~~
[...]

initial_transaction()
{
    local DATABASE_NAME=$(cat $SECRETS_PREFIX/database_name)
    local DATABASE_USER_NAME=$(cat $SECRETS_PREFIX/database_user_name)
    local DATABASE_USER_PASSWORD=$(cat $SECRETS_PREFIX/database_user_password)

    mariadb -e "CREATE DATABASE IF NOT EXISTS $DATABASE_NAME;"
    mariadb -e "CREATE USER IF NOT EXISTS '$DATABASE_USER_NAME'@'%' IDENTIFIED BY '$DATABASE_USER_PASSWORD';"
    mariadb -e "GRANT ALL ON $DATABASE_NAME.* TO '$DATABASE_USER_NAME'@'%';"
    mariadb -e "FLUSH PRIVILEGES;"
}

[...]
~~~
And in init_wordpress.sh:
~~~
[...]

install_and_configure_wordpress()
{
    if [ -f wp-config.php ]; then return 0; fi

    local DATABASE_NAME=$(cat $SECRETS_PREFIX/database_name)
    local DATABASE_USER_NAME=$(cat $SECRETS_PREFIX/database_user_name)
    local DATABASE_USER_PASSWORD=$(cat $SECRETS_PREFIX/database_user_password)
    local WEBSITE_ADMIN_USER=$(cat $SECRETS_PREFIX/website_admin_user)
    local WEBSITE_ADMIN_PASSWORD=$(cat $SECRETS_PREFIX/website_admin_password)
    local WEBSITE_ADMIN_EMAIL=$(cat $SECRETS_PREFIX/website_admin_email)
    local WEBSITE_AUTHOR_PASSWORD=$(cat $SECRETS_PREFIX/website_author_password)

    wp core download --allow-root
    wp config create --dbname=$DATABASE_NAME --dbuser=$DATABASE_USER_NAME --dbpass=$DATABASE_USER_PASSWORD --dbhost=$DATABASE_HOST --allow-root
    wp core install --url=$DOMAIN_NAME --title="$WEBSITE_TITLE" --admin_user=$WEBSITE_ADMIN_USER --admin_password=$WEBSITE_ADMIN_PASSWORD --admin_email=$WEBSITE_ADMIN_EMAIL --skip-email --allow-root
    wp user create $WEBSITE_AUTHOR_USER $WEBSITE_AUTHOR_EMAIL --role=author --user_pass=$WEBSITE_AUTHOR_PASSWORD --allow-root
}

[...]
~~~


# Bonus
## Redis cache for Wordpress
Redis is a NoSQL in-memory database used primarly as a cache app. It can be use in different ways, but with wordpress is used to speed up the
pages loading times. It saves in cache the database queries, so next time the same query is requested (same admin-panel, or same post), it will 
build the page with cache info, and will be a lot faster. It also solves some problems of the default cache plugins <br/>
https://www.ibm.com/think/topics/redis <br/>
https://wetopi.com/redis-object-cache-for-wordpress/ <br/>
We start with a simple Dockerfile: <br/>
https://themeisle.com/blog/wordpress-redis-cache <br/>
https://stackoverflow.com/questions/14816892/how-to-keep-redis-server-running <br/>
As docker needs a foreground process, use --daemonize no (daemonize yes its default)
~~~
FROM debian:bullseye

RUN apt update && \
    apt install -y --no-install-recommends redis-server

EXPOSE 6379

ENTRYPOINT [ "redis-server", "--daemonize", "no" ]
~~~
Now if we enter in the container and execute redis-cli ping, we should get PONG <br/>

Now we create the config file for the redis-server to work with our wordpress container <br/>
https://redis.io/learn/operate/redis-at-scale/talking-to-redis/configuring-a-redis-server <br/>
https://raw.githubusercontent.com/redis/redis/6.0/redis.conf
~~~
# Listen to any address on port 6379
bind 0.0.0.0
port 6379

# Run redis-server in protected-mode, to prevent dangerous connections (listening to 0.0.0.0 without password)
protected-mode yes

# Disable timeout kick for redis clients
timeout 0

# Execute redis-server in foreground, so docker can grant it PID 1
daemonize no

# Ensure redis doesn't interact with the supervision tree (systemd)
supervised no

# Defines how verbose is redis with its logs
loglevel notice

# Print logs to standard output
logfile ""

# Number of databases
databases 16

# Save changes every 300 seconds (5 minutes) if at least 1 key is changed
save 300 1

# Name of the db file and the directory where its gonna be stored
dbfilename inception_dump.rdb
dir /etc/redis/inception
~~~

Now, we modify the redis Dockerfile to add the configuration file. As we wrote the "daemonize no" directive in the
configuration file, there is no need to pass it as argument to redis-server anymore:
~~~
[...]

COPY ./conf/redis_cache.conf /etc/redis/inception/inception.conf

[...]

ENTRYPOINT [ "redis-server", "/etc/redis/inception/inception.conf" ]
~~~

Then, we modify our docker-compose.yml to add the new redis service:
~~~
services:
  mariadb:
    [...]
  wordpress:
    [...]
    networks:
      - backend
      - frontend
      - redis
    [...]
    depends_on:
      - mariadb
      - redis
  nginx:
    [...]
  redis:
    container_name: redis
    build: requirements/bonus/redis
    networks:
      - redis
    env_file: .env
    restart: always

networks:
  [...]
  redis:
    driver: bridge

[...]
~~~

Finally, we will install the redis-cache wordpress plugin via wp-cli <br/>
https://wordpress.org/plugins/redis-cache/  <br/>
https://github.com/rhubarbgroup/redis-cache/blob/develop/INSTALL.md <br/>
https://github.com/rhubarbgroup/redis-cache/#configuration <br/>
https://developer.wordpress.org/cli/commands/plugin/install/ <br/>
First, install the redis php extension in the wordpress Dockerfile
~~~
[...]

RUN apt update && \
    apt install -y --no-install-recommends php-fpm curl ca-certificates php-mysqli php-json php-redis

[...]
~~~
And on init_wordpress.sh:
https://developer.wordpress.org/cli/commands/plugin/is-installed/
~~~
[...]

# Bonus: Install and configure redis-cache plugin
install_and_configure_redis_plugin()
{
    # Check if redis-cache plugin is installed
    wp plugin is-installed redis-cache --allow-root
    
    # If the last command returns 0, means is installed, so return
    if [ $? -eq 0 ]; then return 0; fi;

    # Install plugin
    wp plugin install redis-cache --activate --allow-root
    
    # Set redis configurations in wp-config.php
    wp config set WP_REDIS_HOST "redis" --allow-root
    wp config set WP_REDIS_PORT "6379" --allow-root
    wp config set WP_REDIS_PREFIX "inception" --allow-root
    wp config set WP_REDIS_DATABASE "0" --allow-root
    wp config set WP_REDIS_TIMEOUT "1" --allow-root
    wp config set WP_REDIS_READ_TIMEOUT "1" --allow-root

    # Enable object cache
    wp redis enable --allow-root
}

install_and_configure_wordpress
install_and_configure_redis_plugin
php-fpm7.4 -F
~~~

This works. But if you go to the plugins site on your wordpress admin panel, you can see its not writeable.
This is because the php-fpm is executed as www-data user, but the /var/www/html is created by root. We need to change
the permissons of the /var/www/html directory:
https://wordpress.org/support/topic/redis-object-cache-filesystem-not-writeable-fault/
~~~
[...]

install_and_configure_wordpress
install_and_configure_redis_plugin
chown -R www-data:www-data ./ && chmod -R 755 ./
php-fpm7.4 -F
~~~
Now it fully works


## FTP server
A FTP server is a program that serves files using file transport protocol <br/> 
https://en.wikipedia.org/wiki/File_Transfer_Protocol <br/>
https://documentation.ubuntu.com/server/how-to/networking/ftp/index.html <br/>
https://www.mvps.net/docs/what-is-vsftpd-or-very-secure-ftp-daemon/ <br/>
https://linux.die.net/man/8/vsftpd <br/>
https://www.jscape.com/blog/active-v-s-passive-ftp-simplified <br/>
https://www.plesk.com/kb/support/how-to-configure-the-passive-ports-range-for-proftpd-on-a-plesk-server-behind-a-firewall/ <br/>
We will use vsftpd with pasive mode. We Lets start with the Dockerfile, copying the configuration file and the script directly
~~~
FROM debian:bullseye

RUN apt update && \
    apt install -y --no-install-recommends vsftpd

COPY ./conf/ftp.conf /etc/vsftpd/ftp_inception.conf

COPY --chmod=700 tools/init_ftp.sh /root/init_ftp.sh

RUN mkdir -p /run/vsftpd/empty

WORKDIR /var/www/html

EXPOSE 21
EXPOSE 49152-49162

ENTRYPOINT [ "/root/init_ftp.sh" ]
~~~
Then create the configuration file: <br/>
http://ftp.pasteur.fr/mirrors/centos-vault/3.6/docs/html/rhel-rg-en-3/s1-ftp-vsftpd-conf.html <br/>
https://askubuntu.com/questions/413677/vsftpd-530-login-incorrect
~~~
# Run vsftpd in standalone mode (doesnt need a superdaemon to accept connections)
# And prevent to run it as a daemon (so docker can track it with PID 1)
listen=YES
background=NO

# Deny anonymous users (connections without user and password) and enable local users
anonymous_enable=NO
local_enable=YES

# Root of the server
local_root=/var/www/html/files

# Enable write operations, like delete, rename... on the files AND the server root
write_enable=YES
allow_writeable_chroot=YES

# Set de permissions mask. This mask will substract permissions from de uploaded files (in this
# case, 777 - 033 = 744, so we have all permissions an others only read)
local_umask=033

# Use PC localtime when listing directories
use_localtime=YES

# Activate logging of uploads/downloads.
xferlog_enable=YES

# Security mesures. Jail the user to the server root (/var/www/html/files)
# And an empty directory for jailing securities
chroot_local_user=YES
secure_chroot_dir=/var/run/vsftpd/empty

# The name of the PAM service vsftpd will use (in /etc/pam.d/).
pam_service_name=vsftpd

# Prevent from using active mode
connect_from_port_20=NO

# Use passive mode connection, with the minimum and maximum port and the address
pasv_enable=YES
pasv_min_port=49152
pasv_max_port=49162
pasv_address=127.0.0.1
~~~
And we create the init_ftp.sh script:
~~~
#! /bin/bash

create_ftpuser()
{
    local FTP_USER=$(cat $SECRETS_PREFIX/ftp_user)
    local FTP_PASSWORD=$(cat $SECRETS_PREFIX/ftp_password)

    if [ ! -z "$(cat /etc/passwd | grep $FTP_USER)" ]; then return 0; fi

    useradd -s /bin/bash -m $FTP_USER
    echo "$FTP_USER":"$FTP_PASSWORD" | chpasswd
}

create_files_directory()
{
    local FTP_USER=$(cat $SECRETS_PREFIX/ftp_user)

    mkdir -p ./files && chown -R "$FTP_USER":"$FTP_USER" ./files
}

create_ftpuser
create_files_directory
vsftpd /etc/vsftpd/ftp_inception.conf
~~~

Finally, add the new service to docker-compose.yml and the new secrets
~~~
services:
  [...]
  ftp:
    container_name: ftp
    build: requirements/bonus/ftp
    volumes:
      - website:/var/www/html
    ports:
      - "21:21"
      - "49152-49162:49152-49162"
    restart: always
    secrets:
      - ftp_user
      - ftp_password
    env_file: .env
    depends_on:
      - wordpress
  [...]

secrets:
  [...]
  ftp_user:
    file: ${FTP_USER_SECRET_PATH}
  ftp_password:
    file: ${FTP_PASSWORD_SECRET_PATH}
~~~


## Static website
https://blog.hubspot.com/website/static-vs-dynamic-website <br/>
Create a simple static website in any language except PHP. We will use HTML, CSS and Javascript <br/>
Everyone should build its own website. But for testing, this temporary HTML will do:
~~~
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Test web</title>
	<link rel="stylesheet" href="style/index.css">
	<script defer src="script/index.js"></script>
</head>
<body>
	<h1>Testing the web</h1>
	<p>
		Test!
	</p>
	<button id="testBtn" class="button">Click me!</button>
</body>
</html>
~~~
Javascript:
~~~
const testButton = document.getElementById('testBtn');

testButton.addEventListener('click', () => {
	console.log('I have been clicked!');
});
~~~
CSS:
~~~
.button {
	background-color: darkblue;
	color: white;
}
~~~
Then, in our nginx Dockerfile, we need to copy the web files to the container. But, because volumes erase
any data that was in the directory, we need to copy it first to a non-mounted directory and move the files 
on the entrypoint: <br/>
https://docs.docker.com/engine/storage/volumes/#mounting-a-volume-over-existing-data
~~~
[...]

WORKDIR /var/www/html

# Bonus: Static website
COPY ../bonus/web/ /root/web

[...]
~~~
And on the script (rename it from create_tls_cert.sh to init_nginx.sh)
~~~
[...]

# Bonus: Static website
copy_web_files()
{
    if [ -d ./web ]; then return 0; fi;

    cp -rf /root/web ./
}

create_tls_cert
copy_web_files
nginx -g 'daemon off;'
~~~

This fails because it can't find /bonus/web. That is caused by the Dockerfile context (srcs/requirements/nginx. Here,
it doesnt exist bonus/web). We can't go before that context. So for make it work we need to specify a context in the docker-compose.yml: <br/>
https://stackoverflow.com/questions/24537340/docker-adding-a-file-from-a-parent-directory
~~~
[...]
  nginx:
    container_name: nginx
    build:
      context: ./requirements
      dockerfile: ./nginx/Dockerfile
[...]
~~~
And now, we need to change every path (mostly de COPY's ones) to the according context in the nginx Dockerfile (and change the script name)
~~~
[...]

COPY ./nginx/conf/inception_server.conf /etc/nginx/sites-available/

[...]

COPY --chmod=700 ./nginx/tools/init_nginx.sh /root/

[...]

# Bonus: Static website
COPY ./bonus/web/ /root/web

ENTRYPOINT [ "/root/init_nginx.sh" ]
~~~


## Adminer
Adminer is really similar to wordpress; a php file that dynamically represents a database <br/>
https://en.wikipedia.org/wiki/Adminer <br/>
https://www.adminer.org/en/ <br/>
Adminer is just a php file, so it doesnt need installation, just download. We will download it with curl. <br/>
To know its dependencies, we can execute apt show adminer | grep "Depends" (php-fpm and php-mysqli). <br/>
The Dockerfile will be very similar to wordpress's one, since it works the same way
~~~
FROM debian:bullseye

RUN apt update && \
    apt install -y --no-install-recommends ca-certificates php-fpm php-mysqli curl

COPY ./conf/adminer_pool.conf /etc/php/7.4/fpm/pool.d/adminer.conf

RUN curl -o /root/adminer.php https://github.com/vrana/adminer/releases/download/v5.3.0/adminer-5.3.0.php

RUN mkdir -p /run/php && \
    chmod 777 /run/php

COPY --chmod=700 ./tools/init_adminer.sh /root/

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT [ "/root/init_adminer.sh" ]
~~~
The init_adminer.sh script:
~~~
#! /bin/bash

copy_adminer_file()
{
    if [ -d ./adminer ]; then return 0; fi;

    mkdir ./adminer
    cp /root/adminer.php ./adminer/index.php
}

copy_adminer_file
php-fpm7.4 -F
~~~
And the adminer_pool.conf:
~~~
[adminer]
; User and group that will execute the pool of processes
user = www-data
group = www-data

; What interfaces (IPs) and port should listen
listen = 0.0.0.0:9000

; How will fpm manage the pool processes: Dynamic means the number of
; processes will fluctuate, but there will be at least one children
pm = dynamic

; Maximum of processes alive (in other words, maximum of requests handled at the same time)
pm.max_children = 20

; Number of processes at start
pm.start_servers = 10

; Minimum 'idle' processes (waiting for process). If there are less 'idle' processes than
; this directive, some children processes will be created
pm.min_spare_servers = 1

; Maximum 'idle' processes (waiting for process). If there are more 'idle' processes than
; this directive, some children processes will be killed
pm.max_spare_servers = 15
~~~

This fails because curl doesn't follow redirections: <br/>
https://askubuntu.com/questions/1036484/curl-o-stores-an-empty-file-though-wget-works-well
~~~
[...]

RUN curl -L -o /root/adminer.php https://github.com/vrana/adminer/releases/download/v5.3.0/adminer-5.3.0.php

[...]
~~~

Now we add a new service in docker-compose.yml, that uses the wordpress volume and both frontend and backend networks. <br/>
~~~
  [...]
  adminer:
    container_name: adminer
    build: requirements/bonus/adminer
    volumes:
      - website:/var/www/html
    networks:
      - adminer_backend
      - adminer_frontend
    restart: always
    depends_on:
      - mariadb

[...]
~~~
Make nginx depend from adminer service:
~~~
    [...]
    depends_on:
      - wordpress
      - adminer
    [...]
~~~
We also need to create a new pair of networks, adminer_frontend and adminer_backend (and rename backend and frontend
networks to wordpress_backend and wordpress_frontend)
~~~
services:
  mariadb:
    [...]
    networks:
      - wordpress_backend
      - adminer_backend
    [...]
  wordpress:
    [...]
    networks:
      - wordpress_backend
      - wordpress_frontend
      - redis
    [...]
  nginx:
    [...]
    networks:
      - wordpress_frontend
      - adminer_frontend
    [...]
  redis:
    [...]
    networks:
      - redis
    [...]
  ftp:
    [...]
  adminer:
    [...]
    networks:
      - adminer_backend
      - adminer_frontend
    [...]

networks:
  wordpress_frontend:
    driver: bridge
  wordpress_backend:
    driver: bridge
  redis:
    driver: bridge
  adminer_frontend:
    driver: bridge
  adminer_backend:
    driver: bridge

[...]
~~~

Finally, we add a new location at the end of our nginx configuration to catch every .php request under /adminer/ path
~~~
    [...]

    # BONUS: ADMINER
    # Directive for every request that starts with /adminer/ and finishes with .php
    location ~ ^/adminer/.*\.php$ {
        # Check if php file exists; if not, error 404 not found
        try_files $uri =404;

        # Pass the .php files to the FPM listening on this address
        fastcgi_pass adminer:9000;

        # Include the necessary variables
        include fastcgi.conf;
    }
}
~~~


## Custom service: Volume initializer
To prevent changing volume permissions in every container and getting errors due to that, we create a
container that initializes the website volume with the necessary permissions<br/>
Dockerfile:
~~~
FROM debian:bullseye

COPY --chmod=700 ./tools/init_volumes.sh /root/init_volumes.sh

WORKDIR /var/www/html

ENTRYPOINT [ "/root/init_volumes.sh" ]
~~~
We add it to the docker-compose.yml, and make the necessary services be dependant of this new service.
This time, the container wont be restarting always. It will only execute one time
~~~
services:
  mariadb:
    [...]
  wordpress:
    [...]
    depends_on:
      - mariadb
      - redis
      - init-volumes
  nginx:
    [...]
  init-volumes:
    container_name: init-volumes
    build: requirements/bonus/init-volumes
    volumes:
      - website:/var/www/html
    secrets:
      - ftp_user
    env_file: .env
    restart: no
  redis:
    [...]
  ftp:
    [...]
    depends_on:
      - init-volumes
  adminer:
    [...]
    depends_on:
      - mariadb
      - init-volumes
~~~
We create the init_volumes.sh script, where we give the permissions to the volume and create the necessary
directories (adminer and files) with the necessary permissions:
~~~
#!/bin/bash

create_adminer_directory()
{
    mkdir -p ./adminer
    chown -R www-data:www-data ./adminer
    chmod -R 2755 ./adminer
}

create_ftp_directory()
{
    local FTP_USER=$(cat $SECRETS_PREFIX/ftp_user)

    if [ -z "$(cat /etc/passwd | grep $FTP_USER)" ]
    then
        useradd -s /bin/bash -m $FTP_USER
    fi

    mkdir -p ./files
    chown -R "$FTP_USER":"www-data" ./files
    chmod -R 2755 ./files
}

change_root_owner()
{
    chown -R www-data:www-data ./
    chmod -R 755 ./
}

change_root_owner
create_adminer_directory
create_ftp_directory
~~~

This gives us the chance to clean the other services and centralize the permissions here. <br/>
In init_adminer.sh, we no longer need to create the adminer folder, neither give it permissions. Just copy the files
(preserving the folder ownership, www-data)
~~~
#! /bin/bash

copy_adminer_file()
{
    if [ -f ./adminer/index.php ]; then return 0; fi;

    cp --no-preserve=ownership /root/adminer.php ./adminer/index.php
}

copy_adminer_file
php-fpm7.4 -F
~~~
In init_ftp.sh, we can eliminate "create_files_directory" function:
~~~
#! /bin/bash

create_ftpuser()
{
    local FTP_USER=$(cat $SECRETS_PREFIX/ftp_user)
    local FTP_PASSWORD=$(cat $SECRETS_PREFIX/ftp_password)

    if [ ! -z "$(cat /etc/passwd | grep $FTP_USER)" ]; then return 0; fi

    useradd -s /bin/bash -m $FTP_USER
    echo "$FTP_USER":"$FTP_PASSWORD" | chpasswd
}

create_ftpuser
vsftpd /etc/vsftpd/ftp_inception.conf
~~~
And in init_wordpress.sh, we will execute the commands as www-data using su. So bye bye to --allow-root, and
bye bye to changing ownership and permissions:
~~~
#! /bin/bash

# Bonus: init-volumes service
execute_as_www_data()
{
    # Execute as www-data every wp command using bash
    su -s /bin/bash www-data -c "$1"
}

install_and_configure_wordpress()
{
    if [ -f wp-config.php ]; then return 0; fi

    local DATABASE_NAME=$(cat $SECRETS_PREFIX/database_name)
    local DATABASE_USER_NAME=$(cat $SECRETS_PREFIX/database_user_name)
    local DATABASE_USER_PASSWORD=$(cat $SECRETS_PREFIX/database_user_password)
    local WEBSITE_ADMIN_USER=$(cat $SECRETS_PREFIX/website_admin_user)
    local WEBSITE_ADMIN_PASSWORD=$(cat $SECRETS_PREFIX/website_admin_password)
    local WEBSITE_ADMIN_EMAIL=$(cat $SECRETS_PREFIX/website_admin_email)
    local WEBSITE_AUTHOR_PASSWORD=$(cat $SECRETS_PREFIX/website_author_password)

    execute_as_www_data "wp core download"
    execute_as_www_data "wp config create --dbname=$DATABASE_NAME --dbuser=$DATABASE_USER_NAME --dbpass=$DATABASE_USER_PASSWORD --dbhost=$DATABASE_HOST"
    execute_as_www_data "wp core install --url=$DOMAIN_NAME --title=$WEBSITE_TITLE --admin_user=$WEBSITE_ADMIN_USER --admin_password=$WEBSITE_ADMIN_PASSWORD --admin_email=$WEBSITE_ADMIN_EMAIL --skip-email"
    execute_as_www_data "wp user create $WEBSITE_AUTHOR_USER $WEBSITE_AUTHOR_EMAIL --role=author --user_pass=$WEBSITE_AUTHOR_PASSWORD"
}

# Bonus: Install and configure redis-cache plugin
install_and_configure_redis_plugin()
{
    # Check if redis-cache plugin is installed
    execute_as_www_data "wp plugin is-installed redis-cache"
    
    # If the last command returns 0, means is installed, so return
    if [ $? -eq 0 ]; then return 0; fi;

    # Install plugin
    execute_as_www_data "wp plugin install redis-cache --activate"
    
    # Set redis configurations in wp-config.php
    execute_as_www_data "wp config set WP_REDIS_HOST \"redis\""
    execute_as_www_data "wp config set WP_REDIS_PORT \"6379\""
    execute_as_www_data "wp config set WP_REDIS_PREFIX \"inception\""
    execute_as_www_data "wp config set WP_REDIS_DATABASE \"0\""
    execute_as_www_data "wp config set WP_REDIS_TIMEOUT \"1\""
    execute_as_www_data "wp config set WP_REDIS_READ_TIMEOUT \"1\""

    # Enable object cache
    execute_as_www_data "wp redis enable"
}

install_and_configure_wordpress
install_and_configure_redis_plugin
php-fpm7.4 -F
~~~


# TIPS
1. When debugging, remember to delete the physical volumes (/home/xxx/data), as the persisted data can show you fake results
even if you rebuild
2. Do not copy files to volumes in the Dockerfiles (image build time), specially if that volume is shared between containers.
You may end up erasing data when the volume is mounted on the containers
3. From time to time, build without cache (remove images and build, or build --no-cache). There can be some configurations that
show fake results between builds
