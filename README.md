# Inception
### A 42-school project designated to create an application infrastructure using Docker and Docker compose
In this essay, I wrote down a full documentation of the Inception project; an exercise focused on building a modular application using Docker and Docker Compose. The goal of the project is to deepen your understanding of containerization by setting up an environment composed of several services.

This paper serves as a complete documentation about the project, including:
- Explanations of the key theoretical concepts needed to solve the project.
- My step-by-step journey to set up each component of the infrastructure.
- All the project bonuses and their explanations.
- Errors encountered during my journey, and their explanation.
- All external resources that helped resolve the project.
- Useful tips to complete the project and troubleshoot it.

Whether you are just starting the project or looking to set up some trobulesome service, you can find the documentation here. <br/>
This is the project's infrastructure that we will achieve at the end of the project:

![Inception infrastructure](https://github.com/user-attachments/assets/8177d9a1-82d8-4e28-8e48-d02189a92a91)

## Index
[1. Concepts](#1-Concepts) <br/>
&ensp;&ensp;[1.1 Docker](#11-Docker) <br/>
&ensp;&ensp;&ensp;&ensp;[1.1.1 What is Docker?](#111-What-is-Docker-) <br/>
&ensp;&ensp;&ensp;&ensp;[1.1.2 How does Docker work?](#112-How-does-Docker-work-) <br/>
&ensp;&ensp;&ensp;&ensp;[1.1.3 Virtual Machine vs Docker](#113-Virtual-Machine-vs-Docker-) <br/>
&ensp;&ensp;&ensp;&ensp;[1.1.4 Docker tools](#114-Docker-tools-) <br/>
&ensp;&ensp;&ensp;&ensp;[1.1.5 ENTRYPOINT and PID 1 in Docker](#115-ENTRYPOINT-and-PID-1-in-Docker-) <br/>
&ensp;&ensp;[1.2 Docker Compose](#12-Docker-Compose) <br/>
&ensp;&ensp;&ensp;&ensp;[1.2.1 What is Docker Compose?](#121-What-is-Docker-Compose-) <br/>
&ensp;&ensp;&ensp;&ensp;[1.2.2 The Compose file](#122-The-Compose-file-) <br/>
&ensp;&ensp;[1.3 Inception's services](#13-Inceptions-services) <br/>
&ensp;&ensp;&ensp;&ensp;[1.3.1 MariaDB](#131-MariaDB-%EF%B8%8F) <br/>
&ensp;&ensp;&ensp;&ensp;[1.3.2 PHP-FPM](#132-PHP-FPM-%EF%B8%8F) <br/>
&ensp;&ensp;&ensp;&ensp;[1.3.3 WordPress](#133-WordPress-) <br/>
&ensp;&ensp;&ensp;&ensp;[1.3.4 Nginx and TLS](#134-Nginx-and-TLS-%EF%B8%8F) <br/>
&ensp;&ensp;&ensp;&ensp;[1.3.5 Redis and Redis Object Cache](#135-Redis-and-Redis-Object-Cache-) <br/>
&ensp;&ensp;&ensp;&ensp;[1.3.6 FTP server](#136-FTP-server-) <br/>
&ensp;&ensp;&ensp;&ensp;[1.3.7 Adminer](#137-Adminer-%EF%B8%8F%EF%B8%8F) <br/>
[2. Walkthrough](#2-Walkthrough) <br/>

## 1. Concepts
In this section, you will learn all the key concepts to face this project. You will find information and explanations about Docker, Docker Compose, and all the services you need to set up and how they work together, such as MariaDB, PHP-FPM, Nginx, and more.

### 1.1 Docker
#### 1.1.1 What is Docker? 🐳📦:
Docker is a software platform that automates the deployment of applications. Docker creates lightweight isolated environments called `containers` that have OS-level isolation, independent from the host machine (see section [1.1.3 Virtual Machine vs Docker](#113-Virtual-Machine-vs-Docker-)).

To understand why Docker is really powerful, let's imagine you have built a Java application using Java 17 in your Debian environment. All works as expected. You are really proud of your work, so you want to share your feats with your partners. They clone the repo and try to use your application, but, oh no, surprise, it does not even compile. Why? Because they do not use Debian, but Ubuntu (some environment variables changed). Moreover, they do not even have Java 17 installed on their PC, but Java 12, and your application fails to run correctly. This is a classical problem known as "It works on my machine".

Here is where Docker comes in handy. Using Docker, you can create an isolated environment for your application, with the operating system and the system requirements that you need (Debian and Java 17 in our case). You would build a Debian container, install Java 17 on it, and copy your application files inside of it. Then, you would execute your container, and you would have your application running smoothly, as it isolates itself from the host machine (so it does not share neither the operating system nor system requirements).

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
Now that we understand how Docker works, we should ask ourselves the next question: Why should we use Docker if we have virtual machines (VM)? Don't we get the same result using them? To answer it, we should understand how VMs work behind the scenes.

First of all, let's take a look at how computers work under the surface. A computer has two main components: the physical part (hardware), which includes the CPU, RAM, disk, and more; and the logical part (software), such as applications, libraries, and other system tools. But, how do applications communicate with the hardware? It would be pretty messy (and dangerous) to let the apps communicate themselves with it. Here is where the `kernel` comes in. The `kernel` is software that sits between the applications and the hardware, and helps with the communication of these two (similar to an API with the frontend and the backend).

When an app wants to access some hardware (for example, we want to print a letter 'A' into the screen), we would run some "high-level" code, like the C function `write`. Then, the OS would make a `syscall`, a "low-level" function call that tells the kernel the operation we want to do. Then, the kernel would execute the proper function to do what we asked it to do. This way, we managed to go from code on our app to printing a letter into our screen.

Applications rarely call syscalls directly. Instead, they use higher-level wrappers, like shells or library functions (such as `write`, `read`, `open`...), which internally perform the syscalls.

![PC Architecture](https://github.com/user-attachments/assets/87398e99-0c01-4a49-a0e7-47fd16071dbf)

Then, what is the difference between a kernel and an OS? The kernel is the basic component you need to communicate between software and hardware. But it's almost unusable without tools like a shell or libraries like we saw. An OS brings you different tools so you can work with your kernel in a much friendly way. These include daemons, init systems, shells, libraries, basic utilities (ls, cat, mv...), and more. Think of the kernel as the engine of a car; it is essential, but unusable alone. The OS includes the kernel and other tools that make the system and pc usable.

As we already stated, Docker containers run in isolated environments. VMs work in a similar way, with key differences. A VM virtualizes everything: The applications you run inside them, the libraries it contains, and the operating system. And here is the key part. It also virtualizes the kernel of the distro you are using. If you have a Windows and Debian distro, and your host machine has an Ubuntu OS, then the VMs would virtualize the Windows and Debian kernel. Docker, on the other hand, uses the same kernel as the host machine, and only isolates OS-level applications (shells, utilities, libraries...). This is the reason that you cannot run Windows kernel containers on Linux and vice versa; containers share the host machine's kernel, making cross-kernel compatibility impossible. This makes Docker significantly faster and more efficient compared to a VM, especially for development and deployment. However, this also makes Docker less secure than VMs, as applications that run inside a container are executed on the host machine's kernel.

Another key difference is how Docker consumes resources. A VM always has the resources that you give them. For example, if you give a VM 4 cpu cores and 4 GB of RAM, even if your VM is idle, those resources remain reserved for the VM. Docker, on the other hand, manages the resources dynamically. The docker daemon tracks how many resources the containers need, and frees / reserves resources on the go.

In summary, while both VMs and Docker offer isolation, Docker is a much faster and more efficient solution, especially for development and deployment, by only isolating OS-level applications, sharing the host machine's kernel and allocating resources dinamically.

![Docker vs VM](https://github.com/user-attachments/assets/4673b5b7-9f3b-4620-a162-7b91222f9085)

#### 1.1.4 Docker tools 📃​📦​:
Docker provides many tools that help us develop and deploy applications more easily and quickly. In this section, we will explore the most important ones and their purposes, such as Dockerfile, volumes, networks, and more. Every tool has an ID associated with it (imageID, containerID, volumeID...).

##### Dockerfile:
The Dockerfile is a text file that contains a set of instructions to build an image. These are written by the user and they correspond to the instructions you would normally execute with the Docker client, conventionally written in uppercase.

A key concept to understand about Dockerfiles is the build context. Instructions inside a Dockerfile cannot access files outside this context. Consider the following directory structure: `srcs/requirements/nginx/Dockerfile`. Every instruction written in the Dockerfile has `srcs/requirements/nginx/` as the working directory, and can access every file and directory inside of it, but no instruction can access files or directories outside it (e.g., `srcs/requirements/mariadb/tools/script.sh`). This is intentional, since containers (built from images) are isolated from one another and with the host, so it wouldn't make much sense to let a container (or a Dockerfile) access files that don't belong to them. This is also the reason why the Inception subject requires this directory structure; every configuration file and script should be saved at the same level (or below) as its corresponding Dockerfile.

There are many instructions you can use, but here are the ones we will use for Inception:
  - `FROM image`: This keyword is used to set the `image` argument as the base image for your build. Docker first pulls the base image from the configured registry, and runs the remaining Dockerfile instructions on top of that one. Every valid Dockerfile should start with the `FROM` keyword (with some exceptions).
  - `RUN command`: The `RUN` keyword lets you execute a shell command during the image build. This instruction is isolated from the host machine; this means that you cannot `RUN` a command to do something related to the host (for example, copying a file from the host to the image). If you want to install the SSH package inside the image, you would write `RUN apt install ssh`.
  - `WORKDIR image/path`: The `WORKDIR` instruction sets the current working directory inside the image. All paths specified from this will be relative to it. If no `WORKDIR` is specified, the default is `/`. 
  - `COPY host/path image/path`: This instruction is used to copy files from the host machine to the image. The `host/path` argument has the Dockerfile's build context, meaning if you write `COPY . image/path`, the `.` path is equivalent to the Dockerfile's directory path. The `image/path` argument has the `WORKDIR` instruction context, but you can specify an absolute path. For example, if you want to copy a configuration file you wrote to the image, you would run `COPY ./path/to/conf/file.conf /etc/conf/file.conf`.
  - `EXPOSE port`: This instruction tells Docker which ports our container is expected to publish. This keyword is merely informative; it doesn't actually open nor publish any port. It is used as a type of documentation to know which ports are intended to be published when running the container. To read about publishing ports, see the Docker network section.
  - `ENTRYPOINT [ "exec", "arg1", ... ]` and `CMD [ "exec", "arg1", ... ]`: The `ENTRYPOINT` instruction specifies the command or script that is executed every time the container runs. When you run a container with `docker run`, regardless of it being the first time running or a re-run on a stopped container, the `ENTRYPOINT` will be executed. Docker keeps the container alive as long as the executable is running; once it stops, the container exits (see [1.1.5 ENTRYPOINT and PID 1 in Docker](#115-ENTRYPOINT-and-PID-1-in-Docker-)).

The `CMD` keyword's function depends on whether `ENTRYPOINT` is present or not: If the `ENTRYPOINT` is not present in the Dockerfile, then the `CMD` specifies the same as `ENTRYPOINT` (the command or script to execute). But if the `ENTRYPOINT` is present, the `CMD` will specify the arguments of the `ENTRYPOINT` executable.

At least one of these two is needed to write a valid Dockerfile. To specify the executable and / or arguments you can either use the exec form (`[ "exec", "arg1", ... ]`) or the shell form (`exec arg1 ...`), though the exec form is preferred as it avoids an extra shell process. 

![ENTRYPOINT and CMD](https://github.com/user-attachments/assets/2a30bdd5-0050-40f5-ab42-1722bb2d02ef)

There are other keywords, like `USER user` to specify which user should execute the `ENTRYPOINT`, or `ENV key=VAR` to specify environment variables, but I will not cover them here.

To build an image from a Dockerfile, use the `docker build -t image_name -f path/to/Dockerfile path/to/build/context`, where the `-t` flag defines the image tag (or name) and the `-f` specifies the path to the Dockerfile you want to build (You can omit the `-f` flag if you are currently inside the Dockerfile's directory).

##### Docker image:
A Docker image is a package that includes all the files, binaries, and dependencies required to run a container. If you want to run a MariaDB container, its corresponding image would contain the mariadb-server binary, its configuration files, and its dependencies to ensure MariaDB runs correctly. For a Node.js application, the image would include the preferred Node.js version, the application's code, and other dependencies. An image is like a snapshot: an immutable object that contains the complete environment needed to run a designated application. Once an image is created, it cannot be modified. If you want to make changes to an image, you must either create a new one from scratch or add changes to an existing one (creating a new one in the process).

An important concept you should know about is image composition. Docker images are built in layers, where every instruction written in the Dockerfile is an image layer. A layer represents a set of changes inside the image and its file system, such as adding, removing or modifying files. Docker uses a build cache, where each image layer is cached and reused if possible. When you modify a Dockerfile instruction, or the file associated with it (e.g., changing the content of `main.c` used in `COPY ./main.c /srcs/`), Docker rebuilds that layer and the subsequent ones, reusing the cache for the ones that remain unchanged. This avoids redundant rebuilds, making the build process much faster.

![Docker build cache](https://github.com/user-attachments/assets/1c3c9a63-9906-47e3-8630-d0cd0854d73f)

When you build an image, it is saved on the host machine. If you want to use that image on multiple computers, or publish it so other people can use it, you need to store it in a Docker registry. The same applies if you want to use an already created image, like Debian or Ubuntu base images. When you are building an image, the `FROM` keyword pulls the base image from the configured Docker registry (Docker Hub by default), and builds the rest on top of it. Here are a few useful commands related to images:
  - `docker pull image[:tag]`: Pulls an image from the configured registry.
  - `docker push image[:tag]`: Pushes an image to a registry.
  - `docker rmi image1 [...]`: Removes one or more images.
  - `docker image ls`: List the existing images.
  - `docker build -t image_name path/to/build/context`: Build an image from a Dockerfile (specifying the context).

To run a container from an image, use the command `docker run --name container_name image_name`, where the `--name` flag specifies the container name (it cannot be another container with the same name) and the image_name is the image you want to run the container from. By default, containers run as a foreground process, meaning the terminal remains occupied until the container exits. If you want to run the container as a background process (detached mode), you can add the `-d` or `--detach` flag. 

##### Docker container:
A Docker container is the isolated process that runs with the required dependencies to execute a designated application. The main difference between a Docker image and a Docker container is that a container is a running instance of an image (a mutable process), while the image is just the package that contains binaries and dependencies to run an application (it's an immutable file, not a process).

A container is self-contained and isolated, meaning it has minimal influence on the host machine and other containers, and it doesn't rely on any host machine dependencies to work or execute their designated application (a container doesn't need the host machine to have python installed for it to execute a python application). This increases security and makes them more portable, as containers only need to have Docker installed on the host machine to work. They are also independent from one another, meaning that stopping or deleting a container won't affect others.

However, sometimes you need to enable communication between containers and with the host machine. For example, in a microservices architecture (the one that the Inception project uses), every service, such as the frontend, the backend or the database, is run in a different server (or container when using Docker), and they communicate with each other via TCP connections. This ensures scalability, as each service is encapsulated and easier to troubleshoot or scale independently. For Inception project, you must set one container per service (Nginx, WordPress, MariaDB...). As containers are isolated from each other, we need to find a way to communicate MariaDB's container with WordPress's container, and so on. We can achieve this using Docker networks and publishing ports, which I will cover later in Docker network section.

Something to be also aware of is data persistence inside a container. Containers are designed to be ephemeral; if something breaks in your application and the container results unusable, you only need to fix your application, rebuild the image and run a container. In other words, the only useful thing inside a container is your application. Containers are primarily a tool for deployment, not a long-term data storage. This is why any data stored inside a container is lost when the container is deleted; it's not considered useful. Nevertheless, data persistence is important in many applications and services, like a database. To prevent data loss, you can set up Docker volumes, which I will cover later in its own section.

Here is a list of useful Docker client commands you can use related to containers:
  - `docker ps`: This command lists all the running containers and their information (ID, name, `ENTRYPOINT`, status...). Add the `-a` flag to also list stopped and exited containers.
  - `docker logs container_name`: Prints the logs of a container (messages printed by the `ENTRYPOINT` command).
  - `docker run -d --name container_name image_name`: Runs a container from an image.
  - `docker stop containerID`: Stops a container. A stopped container can be run again with `docker start`.
  - `docker start containerID`: Starts a stopped container.
  - `docker rm containerID`: Removes a container from the host machine. Add the `-v` to also remove the anonymous volumes associated with it.
  - `docker exec container_name command arg1 [...]`: Executes a command inside a container. The output of the command is printed to `stdout`. A really useful way to use this command is executing `docker exec -it container_name bash`. The `-i` flag activates interactive mode, meaning it keeps STDIN open even if the container is not attached to the terminal (`docker run -d`), and the `-t` allocates a pseudo-tty (pseudo-terminal) inside the container. In other words, this command allows us to interact with the container file system via bash, and lets us debug possible errors, misconfigurations, and more.

![Analogy Docker - C program](https://github.com/user-attachments/assets/c2b7b6fe-8c24-41b8-b285-a6e2fd3e0c8c)

##### Docker volume:
As we already stated, data stored inside a Docker container is lost when the container is deleted. To address this limitation, Docker offers two options: volumes and bind mounts. Both options involve mounting a directory into the container's filesystem, with some differences. Mounting involves linking two directories (when using Docker, one in the container and one on the host), so that their contents are synchronized in real time.

Here are the main differences between volumes and bind mounts:
- Docker volumes: Volumes are created and managed entirely by Docker. They are stored within a directory inside the Docker host (server-side component of Docker, which is not always the same as your host machine), usually under `/var/lib/docker/volumes`. Volumes are preferred in production environments, as they are more portable (they work on both Linux and Windows), easier to backup and migrate, and can be managed directly with the Docker client. For example, if you want to persist data inside the `/var/lib/mariadb/database` directory in a container, Docker can create a volume and mount it to that location. There are two types of Docker volumes: anonymous and named volumes.
  - Anonymous volumes: This type of volume is stored with a unique hashed ID inside Docker volume's directory. They are also called unnamed volumes. You can create one using the `VOLUME` keyword inside a Dockerfile, or by running a container with the `-v` flag: `docker run -v /container/directory/with/data image_name`.
  - Named volumes: These are stored with a volume name, so it can be referenced later by name. To create one, use the command `docker volume create volume_name`, or run a container specifying it with the `-v` flag: `docker run -v volume_name:/container/directory/with/data image_name`.
- Bind mounts: Bind mounts use a specific directory from the host machine. As they are not created nor managed by Docker, they are OS dependent (on Linux, it's the same as using the `mount` command), and the host machine's directory must exist for it to be mounted in the container. For example, if you want to persist and share a website's files (e.g., `/var/www/html/website`) between the container and the host machine's directory `/home/user/website`, you can use a bind mount to map the host machine's directory `/home/user/website` to the container's path, and you could access the website's files from both the host machine and the container. To use a bind mount, specify it with the `-v` flag when running a container: `docker run -v /host/path:/container/directory/with/data image_name`.

![Docker volumes and bind mount schema](https://github.com/user-attachments/assets/c24157eb-e257-4625-9890-afd89ebd5f85)

Something to be aware of is using a volume (or bind mount) to a non-empty directory. If the volume is empty, it will be populated with the container's initial data. However, if the volume already contains data, it will override the container's existing files in that path. This is important to consider when sharing the same volume across multiple containers; to prevent any data loss, mount the volume to an empty directory in the container, and then populate it with your application's data.

Docker volumes can also use plugins (also called volume drivers) to integrate with external storage systems like Amazon EBS, enabling data to persist beyond the lifetime of a single Docker host. You can specify the driver using the `-d` or `--driver` flag (the default is `local`, which stores data on the Docker host itself).

![Data loss when using volumes](https://github.com/user-attachments/assets/55d1283e-7dc1-4351-a465-f11c8b839028)

##### Docker network:
Container networking is key to ensuring our services and applications can connect with each other. For example, if we have a container running Nginx and another one running WordPress with PHP-FPM, we need a way to send requests from the Nginx container to the WordPress container, and receive the responses back. As containers are isolated from each other, this may seem impossible at first glance, but we can achieve it using Docker networks. By creating Docker networks, we can specify which containers are visible to one another. Once connected, containers can communicate with each other using the container's name or IP.

Containers can be connected to multiple networks. For example, if an Nginx container has to connect with a WordPress container, and the WordPress container needs to connect with a MariaDB container, you could create two networks (e.g., `frontend_network` and `backend_network`), instead of a big one that connects all three containers. This would be less prone to error and easier to troubleshoot, as containers would only see the services they need. This also follows Docker's philosophy of container isolation; don't give containers more tools or permissions than they need.

Docker networks work using plugins (also called drivers), software that provides networking functionality. Drivers make networks pluggable, meaning you can modify their behavior by selecting different drivers or installing third-party plugins. There are different types of network drivers:
- `bridge`: The default driver. Commonly used to connect containers on the same Docker host.
- `host`: Removes network isolation between the container and the host, and makes the container use the host's network stack directly.
- `overlay`: Enables communication between containers across multiple Docker hosts by connecting different Docker daemons together.
- `ipvlan`: Provides full control over both IPv4 and IPv6 addressing.
- `macvlan`: Assigns a MAC address to the container, making it appear as a physical device on the network.
- `none`: Completely isolates a container from others and the host machine, disabling all networking.

You can manage networks using the Docker client. Here are a few useful commands related to networks:
- `docker network create -d driver network_name`: Creates a network using the driver specified with the `-d` flag.
- `docker network connect network_name container_name`: Connects a container to a network. If you want to disconnect the container from the network, use `docker network disconnect network_name container_name`.
- `docker network ls`: Lists existing networks.
- `docker network rm network_name [...]`: Deletes one or more networks.

Nevertheless, even if Docker networks allow us to connect multiple containers, they are still isolated from the host (if you don't use the `host` network driver). If you need to access your application from the host (e.g., to view a website in a browser), you can publish ports. Publishing a port sets up a forwarding rule mapping a host machine port to a container port, meaning any traffic that would go to a specific host port will be redirected to the mapped container port. For example, if you have a container serving your website in the container's port 80, you can publish that port and map it to the host port 8080. Then, in your host browser, you can visit `http://localhost:8080` to view the site.

![Networks and port publishing](https://github.com/user-attachments/assets/014a3906-0328-4b29-9e1d-5b69b02ba59a)

##### Docker secrets and environment variables:
If your application uses variable configurations, such as the port it listens to (e.g., `3000` for development and `80` for production), you would need to change those values across multiple Dockerfiles, scripts, and more every time you make a configuration change (e.g., switching from development to production). This is slow, tedious and error-prone, as forgetting a single variable could cause everything to fail.

To avoid this issue, you can use key-value environment variables (like bash environment variables, e.g., `$HOME=/home/user`). You can set as many variables as you need (e.g., `PORT` and `DOMAIN_NAME`), and change their value according to your needs. You can use environment variables at build time or inside a running container. To specify an environment variable at build time (for use in a Dockerfile), use the `ARG key=value` and `ENV key=value` keywords. The `ARG` keyword defines an argument passed to the Dockerfile at build time. You can combine both keywords to define and use the variable at build time (e.g., `ARG PORT=3000` and `ENV PORT=${PORT}`. Then, when building the image with `docker build`, you can override the `ARG` value using `--build-arg PORT=PORT_VALUE`). To use an environment variable inside a container, use the `-e` flag (e.g., `docker run -e KEY=value image_name`).

However, managing multiple environment variables quickly becomes complicated, as you would need to update their value manually every time you run `docker build` or `docker run`. To bypass this limitation, you can use environment files. In an environment file (by default, `.env`) you can define multiple environment variables. You can have multiple environment files with the same variables but different values, and switch between these files according to your needs. For example, you can have `.env` for production with the variables `PORT=80` and `DOMAIN_NAME=my.website.com`, and `.env.development` for development with the variables `PORT=3000` and `DOMAIN_NAME=localhost`, and specify which one to use when running your container with the `--env-file` flag: `docker run --env-file .env (or .env.development) image_name`.

Environment variables and `.env` files are useful for managing configuration settings easily. Nevertheless, they are not secure; their value is saved as plain text, and they are visible using `docker inspect` or `env` (and susceptible to hijacking attacks). To save sensitive data, such as a website admin username and password, you can use Docker secrets. A secret is a file that contains sensitive data, stored on your host machine and can be passed to multiple containers. Inside the container, is mounted as a file at `/run/secrets/your_secret` (you would need to execute `cat /run/secrets/your_secret` inside the container to view the secret value). Secrets are more secure as they are not visible via `docker inspect`. However, using secrets with Docker or Docker Compose alone is still not completely secure, as they are still subject to hijacking. Using Docker Swarm (an orchestration tool like Kubernetes), Docker secrets are encrypted and only decrypted inside the target container at runtime, making them much more secure. To simulate Docker secrets without Docker Swarm, you can manually mount a file using `docker run -v ./my_secret.txt:/run/secrets/my_secret:ro image_name`.

Never store secrets or environment variables in public repositories like GitHub. These values are essential for the application to function correctly, but they are also private and sensitive; you should never commit any environment file or sensitive data to your public repository. A good practice is to include template files for both your environment files and secrets (e.g., `.env.template` and `secrets.template`). These templates should contain all your variable keys and secrets names, but without the real value. For example, your `.env.template` file might include `DOMAIN_NAME=YOUR_DOMAIN_NAME`, and your `secrets.template/database_admin_password.txt` file might include `YOUR_DATABASE_ADMIN_PASSWORD`. This allows anyone who uses your application to know which values they need to provide for the application to function properly without revealing the real sensitive data or configuration.

#### 1.1.5 ENTRYPOINT and PID 1 in Docker 👑⚡:
We have already seen how to run a container by creating a Dockerfile and building an image from it. Using the `ENTRYPOINT` keyword (or `CMD`), we can specify the script or program that will be executed as the main process inside the container. Docker will keep the container alive as long as that executable is running. But which conditions must that executable meet for the container to function properly?

To answer this question, we need to understand how processes work under the hood. In Linux, processes are created within namespaces, and their assigned PID value depends on the namespace in which they are created, receiving the lowest value available. Namespaces can be nested, meaning you can create a new process namespace inside another one, and the processes' PIDs created inside the inner namespace will start again from 1.

When Linux kernel boots up, it starts a process in user-space called `init` that always gets associated the PID 1. The job of `init` is to start other processes, act as the direct or indirect ancestor of all processes, adopt orphaned processes and terminate all processes on shutdown. In other words, the `init` process controls the lifecycle of all other processes, from start to finish, including reaping orphaned child processes to avoid zombies. PID 1 is special in Linux; it will never receive any signal if the process didn't explicitly create a handle for it, and will only receive `SIGKILL` or `SIGSTOP` if it comes from an ancestor namespace (in the case of `init` process, the ancestor namespace would be the kernel itself). To put it simply, you cannot kill or stop the PID 1 process like a regular one.

Docker runs container processes inside their own namespace (every container has a namespace associated to it). When you execute `docker stop`, a `SIGTERM` signal will be sent to the container's PID 1. As we already stated, if that process doesn't have a handle for that signal, it won't receive it. In that case, Docker will wait 10 seconds and send a `SIGKILL`. Since that last signal is coming from an ancestor namespace (the Docker daemon is outside the container), the container will be killed, therefore stopped. It's a good practice to have some sort of `init` process in your containers like Linux does, to ensure all processes are removed when you execute `docker stop`, even though it's not strictly necessary if your application doesn't spawn any children. For example, the `tini` program is a lightweight init system for containers. Some official images like `python` or `node` use `tini` to manage internal processes.

The PID 1 process inside a container is the `ENTRYPOINT` command. If the `ENTRYPOINT` is a script (e.g., `ENTRYPOINT [ "bash", "init_service.sh" ]`), then the script itself gets assigned the PID 1. If you want a specific command inside the script to run as the PID 1 process, you should use `exec "$@"` inside the script. The command `exec` replaces the current shell process for the one passed as argument (similar to `execve` in C), and `$@` expands to all the arguments of the script. Then, use the `CMD` instruction in the Dockerfile to specify those arguments. The executed command must be a foreground process, meaning it cannot be a daemon or run in the background. Docker relies on this process to properly manage the container's lifecycle.

![PID and namespaces](https://github.com/user-attachments/assets/9d2ba567-c598-4b28-bc27-df6005012da3)

### 1.2 Docker Compose
#### 1.2.1 What is Docker Compose? 🐙🐳:
We have already seen what Docker is and how we can work with it. But, as we saw, working with multi-container applications quickly becomes complicated. You would need to execute several Docker commands in the right order to ensure the application runs properly. For example, if we wanted to create the mandatory part of the Inception project, with Nginx, WordPress and MariaDB using volumes and networks, we would need to create two separate networks with `docker network create`, and run `docker build` and `docker run -v` once per service, in the right order (e.g., ensuring MariaDB starts before WordPress, which depends on it), while avoiding configuration errors (e.g., mistakenly linking Nginx to MariaDB instead of WordPress). Moreover, if you want to add new services, like an FTP server, you would need to repeat all of these steps, and add new ones, and every time you want to start or stop your application, execute the same commands over and over again. One potential solution is writing a shell script to automate these commands, but this still doesn't scale well, as you would need to update the script for every newly added service, maintaining different scripts for tasks like starting or stopping the containers.

This is where Docker Compose comes in handy. Docker Compose is a Docker container orchestration tool that lets you define and run multi-container applications in a faster and more efficient way than using only Docker. Under the hood, it's still Docker; it uses the same Docker daemon and Docker client, and the Dockerfiles, images, and every tool is the same, but Compose automates the management to solve all the issues we stated earlier. It lets you define and manage multiple services, containers, volumes and networks in a single YAML file. With a simple command, like `docker compose up`, you can set up all the services and volumes and connect the containers in the right way, or stop your application cleanly.

Here are a few useful commands you can use with the Docker Compose CLI:
- `docker compose -f path/to/docker-compose.yml`: For every command you run with `docker compose`, you can specify the Compose file path with the `-f` flag. Otherwise, the current working directory will act as the default path.
- `docker compose up`: Builds and runs all your images and containers, and sets ups all your defined services, volumes and networks.
- `docker compose stop`: Stops your running containers and services.
- `docker compose down`: Stops and removes your running containers and services.

#### 1.2.2 The Compose file 🐙📄:
Docker Compose's strength lies in the ability to define your entire project in a single file called a Compose file: a text file (written in the YAML format) where you define each tool you will use, along with its configuration and behavior. These definitions are called top-level elements (as their level of indentation is zero) and represent each main tool you will use for your application, such as the services, volumes, networks, and more. The preferred name for a Compose file is `compose.yaml`, though `compose.yml` is also correct. Also, `docker-compose.yaml` and `docker-compose.yml` are accepted for backward compatibility.

In this section, we will explore every top-level element you can find inside a Compose file, except the version attribute, since it's deprecated and no longer required, and the config attribute, since it's not needed for this project.

##### The `name` top-level element:
The `name` top-level element defines the project name. It's not needed explicitly, but it's a good practice to set it. Whenever the project name property is defined, an environment variable called `COMPOSE_PROJECT_NAME` is exposed with its value so it can be expanded in the Compose file. Also, if the project name is defined, the images created by the compose commands will have this name as a prefix (e.g., every image created from a project named `inception` will be prefixed with `inception_`, and will be named something like `inception_imageName`). The name property is set as follows:
~~~
# Name top-level element
name: inception

# Services top-level element (which we will cover in the next section)
services:

  # Example service which echoes the project name
  my_service:

    # Use Debian as base image
    image: Debian

    # Runs echo command that expands COMPOSE_PROJECT_NAME variable to "inception"
    command: echo "The project's name is ${COMPOSE_PROJECT_NAME}"
~~~

##### The `services` top-level element:
The `services` top-level element defines which services your application consists of. A service is an abstract definition of a resource that can be scaled or replaced independently from other components. For example, a service could be a database server, a web server, or an FTP service. If you decide to change your web server from Nginx to Apache, it doesn't affect your database or website; it's independent. A service has a container associated with it. Your application's architecture depends on how you distribute your services across containers: if you run all your services inside a single container (e.g., the frontend and the backend of a web application), you have a monolithic architecture, but if you have one container per service, then you have a microservices-based architecture (like the one used in the Inception project).

The `services` element has multiple attributes you can specify to configure your services as needed. Here are a few examples we will use for the project:
- `container_name`: Specifies the custom name for the associated container so it can be referenced later with that name.
- `build`: The `build` attribute specifies how to (re)build the image of the service. It can be defined as a simple string or as a detailed context. If defined as a simple string (`build: path/to/context`), it represents the path to the build context. If it's a detailed context (like a top-level element), you can specify multiple configurations, like the build context (`context: path/to/context`), the specific Dockerfile (`dockerfile: path/to/Dockerfile`), and more. Paths should be relative; using absolute paths reduces portability and triggers a warning from Docker.
- `volumes`: Specify the volumes the service will use. They are defined with the `volumes` top-level element.
- `networks`: Specify the networks the service will use. They are defined with the `networks` top-level element.
- `ports`: Specify which ports are published. The format is `ports: "HOST_PORT:CONTAINER_PORT"`. You can specify either a single port (e.g., `ports:  "80:80"`) or a range of them (e.g., `ports: "200-210:200-210"`, to expose from the port `200` to the port `210`).
- `secrets`: Specify which Docker secrets the service will use. They are defined with the `secrets` top-level element.
- `env_file`: Specify the path to the environment file.
- `depends_on`: Specifies which services are meant to be built before the one declaring it. For example, if WordPress needs MariaDB to function properly, in the WordPress service you would specify `depends_on: mariadb`. Something to be aware of when using `depends_on` is that by default it waits for the container to start, not for its `ENTRYPOINT` to be fully ready. This means that if MariaDB `ENTRYPOINT` command or script is slower than WordPress's, then it will fail. To avoid this issue, you can define what the service should wait for, for example, a `healthcheck` to determine when the service is properly functioning and ready.
- `restart`: Specifies when the container should be restarted. If you set `restart: no`, it will run only once automatically. If it's set to `restart: always`, every time the container exits (unless it was explicitly stopped using `docker compose stop` or `docker compose down`), it will automatically restart. This is useful to ensure every time you boot up your host machine, your containers are run automatically.

There are other attributes, like `environment` to specify concrete environment variables, or `entrypoint` to specify a container's `ENTRYPOINT` command or script.
~~~
# Monolithic architecture example

# All services are combined into a single container. We only declare one service, but inside its container we can find:
# - The database service (for the data)
# - WordPress service (for the website)
# - Nginx service (for the web serving and request handling)
services:
  application:
    container_name: application
    build: ./requirements/application
    volumes:
      [...]
    networks:
      [...]
    secrets:
      [...]
    env_file: .env
    ports:
      - "443:443"
    restart: always
~~~
~~~
# Microservices-based architecture example

# We have a different container per service. Every defined service represents a resource of our application:
# - The database (for the data)
# - WordPress (for the website)
# - Nginx (for the web serving and request handling)
services:
  mariadb:
    container_name: mariadb
    build: requirements/mariadb
    volumes:
      [...]
    networks:
      [...]
    secrets:
      [...]
    env_file: .env
    restart: always
  wordpress:
    container_name: wordpress
    build: requirements/wordpress
    volumes:
      [...]
    networks:
      [...]
    secrets:
      [...]
    env_file: .env
    restart: always
    depends_on:
      - mariadb
  nginx:
    container_name: nginx
    build:
      context: ./requirements
      dockerfile: ./nginx/Dockerfile
    volumes:
      [...]
    networks:
      [...]
    ports:
      - "443:443"
    restart: always
    depends_on:
      - wordpress
~~~

##### The `volumes` top-level element:
This element is used to define all the volumes that our application's containers will use to persist data. These are named volumes and can be configured using different attributes, such as the driver to use, driver options, and more. The default driver (`driver: local`) stores data on the host machine, and with the driver options you can define a named volume that acts as a bind mount under the hood. In other words, you can define a bind mount as a named volume.
~~~
# Example of volumes configuration in a Compose file

# Services: Database (mariadb), website (WordPress), web server (Nginx)
services:
  mariadb:
    container_name: mariadb
    build: requirements/mariadb
    # Mounts a host machine directory to the container's /var/lib/mysql directory (database files)
    volumes:
      - database:/var/lib/mysql
    networks:
      [...]
  wordpress:
    container_name: website
    build: requirements/wordpress
    # Mounts a host machine directory to the container's /var/www/html directory (dynamic website content)
    volumes:
      - website:/var/www/html
    networks:
      [...]
    depends_on:
      - mariadb
  nginx:
    container_name: nginx
    build: requirements/nginx
    # Mounts a host machine directory to the container's /var/www/html directory (static website content)
    volumes:
      - website:/var/www/html
    networks:
      [...]
    ports:
      - "443:443"
    depends_on:
      - wordpress

# The volumes top-level element
volumes:
  # The database volume, which contains all the database tables
  database:
    driver: local
    # Specifies a bind mount. These options are (more or less) equivalent to executing `mount -t type -o o device <docker_mounted_point>`:
    # - type: Specifies the filesystem type, such as ext4, tmpfs, or others
    # - o: Specifies the mount options
    # - device: Specifies where to mount the directory on the host machine
    driver_opts:
      type: none
      device: ./path/to/volumes_directory/database
      o: bind
  # The website volume, which contains all the website dynamic and static files
  website:
    driver: local
    driver_opts:
      type: none
      device: ./path/to/volumes_directory/website
      o: bind
~~~

##### The `networks` top-level element:
This element is used to define all the networks that our application's containers will use to communicate with each other. You can either define only the network name (and use the default configuration) or define all the configuration, such as which driver to use, driver options, whether it's an external or internal network, and more. For this project, you can declare only the network name, as the default configuration works correctly for it, but you can also explicitly declare the driver (`driver: bridge` in this case) if desired. By default, Docker Compose sets up a single network for the application, and each container joins it and is reachable by other containers. Also, if no custom networks are defined for an application, Docker Compose automatically creates a default network named after the project (e.g., `inception_default`).
~~~
# Example of network configuration in a Compose file

# Services: Database (mariadb), website (WordPress), web server (Nginx)
services:
  mariadb:
    container_name: mariadb
    build: requirements/mariadb
    volumes:
      [...]
    networks:
      - backend
  wordpress:
    container_name: website
    build: requirements/wordpress
    volumes:
      [...]
    # In this case, since WordPress needs the database information and receives requests from Nginx,
    # the WordPress container connects to both networks
    networks:
      - backend
      - frontend
    depends_on:
      - mariadb
  nginx:
    container_name: nginx
    build: requirements/nginx
    volumes:
      [...]
    networks:
      - frontend
    ports:
      - "443:443"
    depends_on:
      - wordpress

# The networks top-level element. The bridge driver is set by default, so you can omit that line
networks:
  # The backend (MariaDB - WordPress) network, used for database queries
  backend:
    driver: bridge
  # The frontend (WordPress - Nginx) network, used for web requests
  frontend:
    driver: bridge
~~~

##### The `secrets` top-level element
The `secrets` top-level element defines which secrets your application uses. You can specify the value of each secret either from a file on the host machine (e.g., `database_admin_password.txt`) or from a host environment variable.
~~~
# Example of secrets configuration in a Compose file

# Services: Database (mariadb), website (WordPress), web server (Nginx)
services:
  mariadb:
    container_name: mariadb
    build: requirements/mariadb
    volumes:
      [...]
    networks:
      [...]
    # Secrets needed by MariaDB
    secrets:
      - database_name
      - database_user_name
      - database_user_password
  wordpress:
    container_name: website
    build: requirements/wordpress
    volumes:
      [...]
    networks:
      [...]
    secrets:
      - database_name
      - database_user_name
      - database_user_password
      - website_admin_email
      - website_admin_password
      - website_admin_user
      - website_author_password
    depends_on:
      - mariadb
  nginx:
    container_name: nginx
    build: requirements/nginx
    volumes:
      [...]
    networks:
      - frontend
    ports:
      - "443:443"
    depends_on:
      - wordpress

# The secrets top-level element.
secrets:
  # The secret name becomes the filename inside the container under /run/secrets/
  # For example, to access the `database_name` secret inside the container, run:
  # `cat /run/secrets/database_name`
  database_name:
    file: ./secrets/database_name.txt
  database_user_name:
    file: ./secrets/database_user_name.txt
  database_user_password:
    file: ./secrets/database_user_password.txt
  website_admin_email:
    file: ./secrets/website_admin_email.txt
  website_admin_password:
    file: ./secrets/website_admin_password.txt
  website_admin_user:
    file: ./secrets/website_admin_user.txt
  website_author_password:
    file: ./secrets/website_author_password.txt
~~~

### 1.3 Inception's services
In this section, I will explain each service and program required for the Inception project, including what each service does, how it works, how they interact with each other, and other useful details.

#### 1.3.1 MariaDB 🦭🗂️:
MariaDB is a popular open-source database, created by the original developers of MySQL due to licensing and distribution concerns after MySQL was acquired by Oracle, to ensure MariaDB would remain open source. MariaDB was forked from MySQL, meaning it started as a clone of MySQL and then additional features and changes were added, with the goal of continuing MySQL's development as an open-source project.

It's a relational database, meaning its data is stored in tables with columns (e.g., a User table with ID, name, email and password columns), and those tables are related to each other with primary and foreign keys. A primary key is a table column (also known as a field) that identifies each row of a table, and must be unique. For example, in a User table, the ID column would be the primary key, as it identifies every user and is unique. A foreign key is a table field that links a table with another one, referring to the other table's primary key. Taking the last User table example, we could have an Account table with a field called `owner`, which is a foreign key that refers to the `ID` field in the `User` table, and links each account with one user.

MariaDB is also a SQL database, meaning it uses SQL (Structured Query Language) to manage the data inside a database. Each command you run with SQL, such as selecting, creating, modifying or deleting data is called a query. For example, an SQL query would be `SELECT ID, name FROM MyDatabase.User;`, where you are selecting (reading) the `ID` and `name` fields from the table `User` inside the database `MyDatabase`.

MariaDB is similar to Docker; it has a client-server architecture. The MariaDB server (`mariadbd`) is the daemon process that manages databases and handles client requests, while the client (`mariadb`) is a CLI program that gives the user an SQL shell (an SQL interpreter) to interact with the server via queries. The server can be on a different host machine than the client, meaning you can execute queries to a remote host. To install MariaDB using the terminal, run `apt install mariadb-server`. This will install both the server and the client, since the client is needed to interact with the server.

![MariaDB client-server architecture](https://github.com/user-attachments/assets/3dc5b5e5-9cee-46a6-804a-6e562d238856)

#### 1.3.2 PHP-FPM ⚙️📖:
To understand what PHP-FPM and CGIs are, we first need to understand how websites and web browsers work, and the difference between static and dynamic files.

Web browsers only interpret HTML, CSS and Javascript to load the websites, where HTML contains the structure of the web, CSS the decorations and styles, and Javascript the logic (content manipulation, interactivity, events handling, etc.). A website's type can be either static or dynamic, and it can change depending on the context it's considered.

On the client context (or web browser context, with the final HTML, CSS and Javascript files it interprets), a website is static if it's only composed of HTML and CSS files, and dynamic if it contains and uses Javascript to update content or interact with the backend via APIs. This is because Javascript provides dynamic functionalities, such as animations, event handling on buttons, etc., while HTML and CSS only provide the visual content without any logic underneath.

However, in the server context, these definitions change. On the one hand, a website is static when the requested files can be directly managed by the browser (HTML, CSS, Javascript, images...), always delivering the same content to all visitors (e.g., an `index.html`). On the other hand, a website is dynamic if some of the requested files need to be translated first so that the browser can interpret them, generating content on-the-fly (using server-side code or databases). For example, if the user requests the file `index.php`, with the following content:
~~~
// PLEASE NOTE THAT THIS IS AN EXAMPLE, THE CODE IS INCOMPLETE

// HTML body
<body>
    // Main title
    <h1>
        // Static message, always with the same content
        Welcome back
        // Dynamic content. It depends on the following logic:
        <?php
            // Import the website cookies and get the user role
            global $_COOKIE;
            $role = getUserRole($_COOKIE["user_name"]);

            // If the user is admin, print "admin!"; else, print "normal user!"
            if ($role == "admin")
                echo "admin!";
            else
                echo "normal user!";
        ?>
    </h1>
</body>
~~~
The application's backend should first interpret the PHP code to translate it to pure static HTML (as the browser can't interpret PHP), and then send it to the browser to load the new static page, providing personalized and interactive content (e.g., based on user data, like their role).

![Static vs dynamic websites](https://github.com/user-attachments/assets/10289d04-3f66-455d-a395-44b346ce10ee)

The programs that interpret dynamic files are called `CGI scripts`. `CGI` (Common Gateway Interface) is an old protocol that these scripts use to communicate with the web server and handle its requests. The `CGI scripts` are language-independent, meaning they can be written in any language, such as PHP, Python, C / C++ or even Bash.

When a web server receives a request for a dynamic file (e.g., `index.php`), it creates a child process that executes the `CGI script` (in this case, a `PHP-CGI` script), and passes the necessary environment variables to it, such as the user's cookies and session, the script filename (the requested file path), and more. Then, the `CGI script` sends its response back to the web server, and the web server back to the browser, which interprets the static content created by the script.

![Nginx and CGI workflow](https://github.com/user-attachments/assets/47026a13-8477-4d41-998d-270eb70c937c)

However, the usage of basic CGI scripts doesn't scale well, as creating new child processes every time you receive a dynamic file request is really resource-consuming, causing servers hosting high-traffic websites to break or to perform poorly. To avoid this issue, a new protocol called `FastCGI` was developed. This new protocol is based on the CGI protocol, but with a key difference: it allows implementations to have a pool of processes (called workers) that are created from the start and kept running persistently, reusing them multiple times for handling incoming requests. The management and behavior of the workers' pool depends on the program implementing it. In other words, a simple CGI script executes the dynamic file once per request to produce a response, and must be executed by the web server, while a `FastCGI` program is executed only once, independently from the web server, with a pool of persistent child processes that handle multiple requests.

`PHP-FPM` (PHP FastCGI Process Manager) is a highly-configurable program that implements the `FastCGI` protocol, and allows you to configure the pool's size, idle workers behavior, the maximum number of active child processes, and much more. When `PHP-FPM` receives a request from the web-server, it tries to send it to a worker in the pool. If all of them are busy, it creates a new temporary worker that will only handle the request (it may be reused or terminated, depending of the configuration) if there are fewer than `max_children` created (defined in the configuration file). If there are more than that, it waits until it can handle it (or timeout).

![Nginx and PHP-FPM workflow](https://github.com/user-attachments/assets/cd2e1d1f-4024-4a9d-a22f-1648a1063297)

#### 1.3.3 WordPress 📄📥:
WordPress is a CMS (Content Management System), a web application that simplifies content creation and management. It allows the user to create any type of dynamic website (though it was originally designed for blogs), offering features such as database integration (typically MySQL or MariaDB), admin panels, user role management, plugin support (third-party extensions that add functionality, such as e-commerce via the WooCommerce plugin), etc. Users can manage content, appearance, and settings through an admin dashboard. When a page is requested, WordPress queries the database to retrieve the corresponding content, which is then processed through the PHP scripts and templates, generating the final HTML.

Under the hood, WordPress is just a collection of PHP scripts that generate dynamic website pages based on a specific theme. This means that the content of the pages is dynamic, since it changes depending on multiple factors, such as the user role, the requested content, etc., but the appearance across all the pages will remain the same, regardless of the page content (e.g., a contact page and a blog page on the same website will share the same appearance). To achieve this, WordPress uses themes, a set of templates that define both the appearance and structure of website pages, using predefined HTML, CSS, and logic to render different types of content consistently. You can install any theme that suits your needs.

However, WordPress' PHP scripts alone are not sufficient, as the browser cannot interpret them directly. That's the reason why `FastCGI` programs and web servers are also needed; a `FastCGI` program (like PHP-FPM) to interpret and execute the scripts, and a web server (like Nginx) to forward browser requests to the `FastCGI` program.

![WordPress themes operations](https://github.com/user-attachments/assets/ec914255-a59e-4efc-9e85-5c27f911c430)

#### 1.3.4 Nginx and TLS ↪️🔐:
Nginx (pronounced `Engine X`) is an HTTP/HTTPS web server that is used for serving requested files of a website, though it can also be used as a reverse proxy or proxy server, load balancer, etc. When a user requests a file from the server (e.g., using `curl https://my.web.com/index.html` or a web browser like Mozilla), Nginx accepts the incoming connection, parses the request HTTP/HTTPS headers and body, and sends a response back with the appropriate HTTP status code. For example, if the requested file doesn't exist, Nginx would send a response with the status code `404` (Not Found).

By default, Nginx sends the existing files directly, without interpreting their content. This means that if a user requests a dynamic file (e.g., `index.php`), by default Nginx would return the raw file contents to the client, which is a significant security risk, as it would reveal the source code of the website. To avoid this, you can configure Nginx to forward these requests to a CGI/FastCGI script (e.g., PHP-FPM).

An `HTTP` (HyperText Transfer Protocol) communication mainly consists of two different parts: the headers and the body. The headers contain the request or response meta-data, such as the method (GET, POST, DELETE...), the content length and type, the user's cookies and session information, etc. The request's or response's body contains the data that the sender wants to send to the receiver. For example, when a user wants to log in on a website, the client would send a POST request with the login information in its body (e.g., the username and password), and would receive an according response from the server.

![HTTP request / response](https://github.com/user-attachments/assets/501dd411-8bac-4e55-8e34-82747cc094bc)

However, `HTTP` requests and responses are sent as plain text, so anybody that intercepts the packets (with a MITM attack) could read the data. This is where `HTTPS` (HyperText Transfer Protocol Secure) and `TLS` (Transport Layer Security) comes in handy. `HTTPS` has the same data format as `HTTP` (Headers and body), but it encrypts the data exchanged between the sender and the receiver, preventing unauthorized parties from reading or accessing its contents. To encrypt the data, it uses the `TLS` protocol, the successor to the `SSL` protocol (Secure Sockets Layer), which was deprecated in 2015 following version 3.0 due to several known vulnerabilities.

These protocols use asymmetric cryptography (a public/private key pair) to securely exchange session keys, which are then used for symmetric encryption and decryption of the data. When a client tries to connect to a server, the secure communication begins with a `TLS handshake` process, where the client and the server use their public/private key pair to agree on session keys, which they will use to encrypt and decrypt the data. The `TLS handshake` process depends on the `TLS` version; the `TLSv1.2` handshake takes more steps than `TLSv1.3`, and can be more insecure, since some insecure cipher suites (the encryption algorithms) are allowed, such as RSA-based key exchange. To use `HTTPS` and `TLS` encryption, your website must have a `TLS` certificate that verifies the server's identity and proves that it's truly who it says it is. These certificates are provided by security entities called Certificate Authorities (CA), such as DigiCert or Let's Encrypt. Browsers validate the certificate's authenticity by checking its trust chain up to a recognized Certificate Authority.

In summary, Nginx is primarily a web server designed to serve files in response to client requests. It uses `HTTP` and `HTTPS`, protocols that define the format of the data sent between a web server and a client. `HTTP` is insecure, as the information is sent as plain text, and `HTTPS` encrypts the data using the `TLS` protocol. To see more information about how `TLS` and the `TLS handshake` works, see [4. Sources](#4-Sources).

![HTTP vs HTTPS](https://github.com/user-attachments/assets/5d471043-d8d4-48fa-b201-4ca5f05515c0)

#### 1.3.5 Redis and Redis Object Cache ⚡📝:
Redis is an open-source database popular for its high read and write performance, since by default it stores the data in the RAM instead of the disk. This fact makes the data access much faster than a conventional database, with the downside that the data is volatile, as it's lost whenever the machine is shut down (although it can be configured to persist data). Redis is a non-relational and NoSQL database; the data is not stored as tables, but in key-value pairs, and it does not support SQL queries. It's mostly used in scenarios where speed is more important than data persistence, and for application cache (temporary data stored to improve loading times).

The pages of a website can be cached in different ways to speed up loading times. The simplest way to do it is caching static files, as its contents never change. Most browsers have a built-in caching system for them, improving speed after they are loaded the first time, but other web applications or web servers like WordPress or Nginx can manage static file caching as well. For example, web servers can cache the files requested, to avoid having to process them multiple times, as the content won't change. This allows the server to send future responses significantly faster.

Dynamic files cannot be cached the same way. Since their content is generated on-the-fly, any slight change would mean that the cached content is no longer useful. However, since building dynamic pages usually means to fetch data from a database, it's possible to cache the result of those queries. In dynamic page generation, the slowest step is usually retrieving data from the database, as it requires communicating with the server, sending a query, waiting for a response, and building the page with it. When caching the database query, the next pages that are built using the same data will only need to read the data and build the page, making the process much faster.

This is where Redis Object Cache can help us. Redis Object Cache is a WordPress plugin that replaces WordPress's default cache with a much faster and more powerful one using Redis. The default WordPress's cache is really limited, since the content of dynamic pages is constantly changing. This plugin uses Redis cache to save the results of database queries in memory, reusing it in future requests and speeding up page generation. A Redis service must be running in order to use Redis Object Cache, either on the same host machine or on a remote server.

![Redis Object Cache workflow](https://github.com/user-attachments/assets/7d0f71ae-e8fb-4e49-9987-61e9596d4cc6)

#### 1.3.6 FTP server 📨📬:
`FTP` (File Transfer Protocol) is an old communication protocol used to transfer and manage files between devices over a network. An `FTP server` is a service that allows users to access, upload, download and manage files using the `FTP` protocol. The user connects to the server using an `FTP client`, such as FileZilla or `ftp` command-line tool. Using a login and password, it can transfer files from one machine to another, or manage files on the remote server (e.g., create, rename, delete or move operations).

Unlike other protocols, `FTP` uses two different communication channels: the command channel and the data channel. The command channel is persistent, and is used to send the `FTP` command the user wants to execute on the server (e.g., `LIST` to list the working directory, `USER` and `PASS` to specify the user and the password, `RETR` and `STOR` to retrieve and store a file, etc.). The server sends a response based on the execution result, similar to `HTTP`; for example, `200 OK`, `230 Login successful`, `226 Transfer complete`, etc. The data channel is temporary, and is only used when the specified command requires to move data. For example, if a user sends the `STOR` command to upload a file to the remote server, a new data channel is created to transfer the file contents through it, and it is closed when the transfer is finished.

The client always establishes the command channel connection, normally on the server's port (SP) 21, but the establishment of the data channel depends on the mode: either the server connects to the client (active mode) or the client connects to the server (passive mode).
- **Active mode**: In this mode, the client creates the command channel, while the server creates the data channel. The client uses an ephemeral port (a temporary port, usually in the range of 49152 to 65535) on its side to initiate the command channel to the SP 21, and receives a connection from the server for the data channel in a different ephemeral port, which is established from the SP 20. Here are the simplified steps to transfer data in active mode:
  1. The client establishes the command channel connection.
  2. The server sends the response back on that channel (`220 Welcome to FTP`).
  3. The client authenticates itself with `USER` and `PASS` commands, and the server sends a response (e.g., `530 Login incorrect` if failed).
  4. When the client wants to transfer data, it sends a `PORT` command specifying its IP and an available port for the data channel (active mode).
  5. The server establishes the data channel connection to the specified client port.
  6. When established, every time the user sends a command through the command channel (e.g., `LIST`, `RETR` or `STOR`), the server receives or sends data on the data channel.
- **Passive mode**: In this mode, the client creates both the command and data channels. The client establishes (by default) the command channel to the SP 21, but for the data channel the server indicates a range of ports that the client can connect to. Here are the simplified steps to transfer data in passive mode:
  1. The client establishes the command channel connection.
  2. The server sends the response back on that channel (`220 Welcome to FTP`).
  3. The client authenticates itself with `USER` and `PASS` commands, and the server sends a response (e.g., `530 Login incorrect` if failed).
  4. The client requests passive mode with the `PASV` command.
  5. The server sends a response with `227 Entering Passive Mode` and specifies its IP and an available port the client can use to establish the data channel (passive mode).
  6. The client establishes the data channel to the specified port.
  7. When established, every time the user sends a command through the command channel (e.g., `LIST`, `RETR` or `STOR`), the server receives or sends data on the data channel.

For both modes, the client uses ephemeral ports to establish both the command and data channels connections. On passive mode, the server has a range of ports that can be used, and informs the client of one of them on every `PASV` response.

The active mode was the only mode used at the beginning. As systems evolved, some issues with this mode began to appear, such as problems with NAT (Network Address Translation) and firewalls (the server couldn't establish the data channel connection because the client had a firewall enabled). This is the reason why passive mode was created; the client creates both channels, and the server simply indicates which ports are available for data connections.

Other modern protocols, such as `HTTP` or `HTTPS`, only use one channel, combining commands and data in the same request/response, where headers define the operation and the body carries the data. In other words, the `HTTP` method and data are sent together over a single connection, with no separation between command and data channels, in a single request/response. This is one of the reasons why `FTP` has gradually fallen out of use.

`FTP` clients normally provide a more user-friendly interface to use compared to interacting directly with raw `FTP` commands (`LIST`, `RETR`, `STOR`, etc.). For example, FileZilla provides a GUI that is really easy to understand and use, and the `ftp` command-line tool interprets commands similar to those used in `bash`, and translates them into their corresponding `FTP` commands (e.g., executing `put file.txt` sends a `STOR` command to upload the file, and `ls` sends a `LIST` command).

![Active vs Passive mode](https://github.com/user-attachments/assets/fae4056a-57d0-43a7-935f-01961ee3f005)

#### 1.3.7 Adminer 👁️🗃️:
Adminer is a lightweight, full-featured database management tool implemented in a single PHP file. It provides various features such as connecting to databases, visualizing data, and managing database content. Under the hood, it's quite similar to WordPress, as it's also a PHP file that generates dynamic pages and provides a web-based interface to interact with a database. Since it's a single PHP file, it's lightweight and very fast. It's a good alternative to phpMyAdmin, which is heavier and requires installation. Adminer, on the other hand, only requires placing the file on the server.

However, since Adminer is a dynamic file, a CGI script or FastCGI program (e.g., `PHP-FPM`) is required to run it, and a web server like Nginx is needed to handle the PHP file request and forward it to the PHP backend.

Adminer supports the most popular relational database engines, such as MySQL, MariaDB, and PostgreSQL. Some relational databases, like Oracle, may also require specific configurations or plugins. Support for non-relational databases like MongoDB is also possible through plugins.

In the context of Docker-based projects, Adminer is used as a lightweight alternative to phpMyAdmin, and can be run as a standalone container, as it only requires a `PHP-FPM` process to interpret the file and a web server to serve it.

## 2. Walkthrough
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
https://stackoverflow.com/questions/47150829/what-is-the-difference-between-binding-mounts-and-volumes-while-handling-persist <br/>
https://docs.docker.com/engine/network/drivers/ <br/>
https://github.com/krallin/tini <br/>
https://docs.docker.com/compose/intro/compose-application-model/ <br/>
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
exec "$@"
~~~
2. Copying it to the /root folder and adding the exec args with CMD
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
CMD [ "mariadbd" ]
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
exec "$@"
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

exec "$@"
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

exec "$@"
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

exec "$@"
~~~
Also, wordpress must be installed in the root directory of nginx, so we set the workdir there: <br/>
https://serverfault.com/questions/718449/default-directory-for-nginx
~~~
[...]

WORKDIR /var/www/html

[...]

CMD [ "php-fpm7.4", "-F" ]
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
CMD [ "php-fpm7.4", "-F" ]
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
exec "$@"
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
CMD [ "php-fpm7.4", "-F" ]
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
exec "$@"
~~~
Then, in Dockerfile:
~~~
[...]

COPY --chmod=700 ./tools/create_tls_cert.sh /root/

[...]

ENTRYPOINT [ "/root/create_tls_cert.sh" ]
CMD [ "nginx", "-g", "daemon off;" ]
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
exec "$@"
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
exec "$@"
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
CMD [ "vsftpd", "/etc/vsftpd/ftp_inception.conf" ]
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
exec "$@"
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

Optionally, we can activate directory listing for /files/ routes, so we can see the files insiede more easily.
~~~
    [...]
 
    # Bonus: FTP server
    # Directive for exactly /files/ request
    location = /files/ {
        # Enable directory listing
        autoindex on;

        # Check if directory exists; if not, error 404 not found
        try_files $uri/ =404;
    }
}
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
exec "$@"
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
CMD [ "nginx", "-g", "daemon off;" ]
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
CMD [ "php-fpm7.4", "-F" ]
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
exec "$@"
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

    # Bonus: Adminer
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
exec "$@"
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
exec "$@"
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
exec "$@"
~~~


# TIPS
1. When debugging, remember to delete the physical volumes (/home/xxx/data), as the persisted data can show you fake results
even if you rebuild
2. Do not copy files to volumes in the Dockerfiles (image build time), specially if that volume is shared between containers.
You may end up erasing data when the volume is mounted on the containers
3. From time to time, build without cache (remove images and build, or build --no-cache). There can be some configurations that
show fake results between builds
