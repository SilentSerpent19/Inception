# Developer Documentation

## Setup from scratch
Prerequisites: Docker, Docker Compose, GNU Make, sudo, and a Linux host (VM).

1. **Configuration files**
   - `srcs/.env` — non-secret settings (domain, DB name, DB user, WP title, the
     two WordPress usernames and emails). The admin username must not contain
     admin/Admin/administrator/Administrator.
   - `srcs/requirements/nginx/conf/nginx.conf` — set `server_name` to your domain.
2. **Secrets** (`secrets/` folder, one value per file, **no trailing newline**)
   - `db_root_password.txt`, `db_password.txt`,
     `wp_admin_password.txt`, `wp_user_password.txt`
   - Mounted into the containers at `/run/secrets/<name>`.
3. **Host name resolution** — add `127.0.0.1 <yourlogin>.42.fr` to `/etc/hosts`.

## Build and launch
- `make` / `make up` — creates `~/data/{mariadb,wordpress}`, then runs
  `docker compose -f srcs/docker-compose.yml up -d --build`.
- The Makefile is the single entry point; it calls docker compose, which builds
  the three Dockerfiles and starts the containers on the `inception` network.

## Managing containers and volumes
- List: `docker ps -a`
- Logs: `docker logs <container>`
- Shell: `docker exec -it <container> bash` (or `sh`)
- Stop/remove: `make down`
- Remove volumes too: `make clean`
- Remove images and host data: `make fclean`

## Where data is stored and how it persists
Two named volumes are bind-configured to host directories:
- MariaDB data → `~/data/mariadb` (`/var/lib/mysql` in the container)
- WordPress files → `~/data/wordpress` (`/var/www/html` in the container)

Because the databases and site files live on these host directories, data
survives container restarts and rebuilds. The init scripts initialize only on the
first boot (they detect existing data and skip re-initialization), so restarting
does not wipe content. `make clean` / `make fclean` is what removes the data.
