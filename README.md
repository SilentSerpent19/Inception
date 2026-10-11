# Inception

## Description
Inception is a system-administration project that builds a small, self-contained
web infrastructure entirely from custom Docker images. The stack runs three
services — NGINX (TLS termination), WordPress with php-fpm, and MariaDB — each in
its own container, wired together over a dedicated Docker network and backed by
two persistent volumes. The goal is to learn containerization, image building,
service isolation, secrets handling, and Docker Compose orchestration.

## Instructions
Prerequisites: a Linux host (typically a VM) with Docker and Docker Compose,
GNU Make, and sudo access.

1. Set your domain in `srcs/.env` (`DOMAIN_NAME=<yourlogin>.42.fr`) and update
   `server_name` in `srcs/requirements/nginx/conf/nginx.conf` to match.
2. Point the domain at localhost:
   `echo "127.0.0.1 <yourlogin>.42.fr" | sudo tee -a /etc/hosts`
3. Replace the placeholder passwords in `secrets/*.txt`.
4. Build and start: `make`
5. Visit `https://<yourlogin>.42.fr` (accept the self-signed certificate warning).

Useful targets: `make up`, `make down`, `make clean`, `make fclean`, `make re`.

## Resources
- Docker documentation — https://docs.docker.com
- Docker Compose file reference — https://docs.docker.com/compose/compose-file/
- NGINX + php-fpm (FastCGI) configuration
- MariaDB bootstrap & `mariadb-install-db`
- WP-CLI handbook — https://make.wordpress.org/cli/handbook/
- PID 1 / signal handling in containers ("the PID 1 zombie reaping problem")

### AI usage disclosure
I used AI during this project as a learning support tool to help me understand the main concepts behind Docker, MariaDB, and WordPress. It was mostly useful for getting a clearer idea of how containers work together, how services communicate in a Docker setup, and how to properly structure the project. I also used it to help me organize my approach and make sense of best practices while building the system. 

## Project description
### Use of Docker and sources
Each service has its own directory under `srcs/requirements/` containing a
Dockerfile, a `conf/` folder, and a `tools/` folder. Images are built from a
pinned Debian base (no `latest`, no pre-built service images). The Makefile drives
`docker compose` to build and run everything.

Main design choices: secrets are kept out of the images and the repository and
mounted at runtime under `/run/secrets`; non-secret configuration lives in `.env`;
MariaDB and WordPress initialize once (guarded by the presence of existing data)
so restarts preserve state; every container runs its real service as PID 1 via
`exec` (no `tail -f`, `sleep infinity`, or `while true`).

### Virtual Machines vs Docker
A VM virtualizes hardware and runs a full guest OS with its own kernel, giving
strong isolation at the cost of size and startup time. A container shares the host
kernel and isolates only the process/filesystem/network namespaces, making it far
lighter and faster to start, though less isolated than a VM.

### Secrets vs Environment Variables
Environment variables are convenient but visible in `docker inspect`, process
listings, and child processes, and they tend to leak into logs — acceptable for
non-sensitive config like a database name. Docker secrets are mounted as files
readable only inside the container (here under `/run/secrets`), are not baked into
the image, and stay out of version control — the right place for passwords.

### Docker Network vs Host Network
A user-defined bridge network isolates the containers, gives them a private
subnet, and provides DNS resolution by service name, so only the ports you publish
are reachable from outside. Host networking removes that isolation: the container
shares the host's network stack directly, which is faster but exposes everything
and breaks the single-entry-point requirement. This project uses a dedicated
bridge network and publishes only port 443 on NGINX.

### Docker Volumes vs Bind Mounts
A named volume is managed by Docker and is the portable default for persistent
data. A bind mount maps a specific host path into the container, giving direct
access to host files. This project uses named volumes configured with
`driver_opts` to bind them to `~/data`, combining a named-volume declaration with
a known host location (`/home/<login>/data`) as required by the subject.
# Inception
