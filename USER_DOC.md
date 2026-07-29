# User Documentation

## What this stack provides
A WordPress website served over HTTPS, composed of three services:
- **NGINX** — the public web server (HTTPS, port 443); the only entry point.
- **WordPress + php-fpm** — runs the website and its PHP.
- **MariaDB** — stores the website's data.

## Starting and stopping
- Start: `make` (or `make up`)
- Stop: `make down`
- Stop and remove data volumes: `make clean`
- Full reset (containers, images, data): `make fclean`
- Rebuild from scratch: `make re`

## Accessing the website
Open `https://<yourlogin>.42.fr` in a browser. Because the certificate is
self-signed, the browser shows a security warning the first time — accept it to
continue.

## Accessing the admin panel
Go to `https://<yourlogin>.42.fr/wp-admin` and log in with the administrator
username and password (see Credentials).

## Credentials
Passwords live in the `secrets/` folder (one file per password); a summary is in
`secrets/credentials.txt`. The administrator and second-user names are set in
`srcs/.env`. Never share or commit these files.

## Checking the services are running
- `docker ps` — all three containers (nginx, wordpress, mariadb) should be "Up".
- `docker logs nginx` / `docker logs wordpress` / `docker logs mariadb` — view output.
- Website: `curl -kI https://<yourlogin>.42.fr` should return an HTTP status line.
- Database: `docker exec -it mariadb mariadb -u root -p` then `SHOW DATABASES;`.
