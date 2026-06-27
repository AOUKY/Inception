# Inception

> “One container is easy. A full infrastructure is where things get real.”

This project is my implementation of **Inception** at 42: building a small production-like web stack using Docker, with each service running in its own container.

---

## Why this project exists

The goal is simple (but not easy):  
learn how services work together in a real infrastructure environment instead of running everything in one place.

In this setup, I run:

- **NGINX** as the only public entrypoint (HTTPS only)
- **WordPress** with PHP-FPM
- **MariaDB** for persistent database storage

Everything is containerized, isolated, and connected through Docker networking.

---

## Architecture (42 requirements mindset)

- One container per service
- Custom Dockerfiles (no ready-made all-in-one images)
- Containers restart automatically on crash
- Persistent data using Docker volumes / bind mounts
- Secure communication entrypoint with TLS on port **443**
- Environment-based configuration through `.env`

---

## Project structure

```text
.
├── Makefile
├── secrets/
└── srcs/
    ├── .env                  # (you create this locally)
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/
        │   └── tools/
        └── wordpress/
            ├── Dockerfile
            └── tools/
```

---

## Services

### NGINX
- Terminates TLS (HTTPS)
- Exposes **443:443**
- Serves WordPress content through shared volume
- Depends on `wordpress`

### WordPress (PHP-FPM)
- Runs PHP-FPM (internal port 9000)
- Connects to MariaDB
- Shares files with NGINX

### MariaDB
- Stores all WordPress data
- Uses persistent volume (data survives container recreation)

---

## Prerequisites

Before launching, make sure you have:

- Docker installed
- Docker Compose plugin installed
- Linux user with write access to:

```bash
/home/$USER/data/mariadb
/home/$USER/data/wordpress
```

---

## Environment file

Create:

```bash
srcs/.env
```

Put your credentials and config values there (DB name/user/password, WP admin user/password/email, domain, etc.).

> Keep `.env` private and never push secrets.

---

## How to run

From the root of the repository:

```bash
make
```

That will run:

1. `make build`
2. `make up`

### Useful commands

```bash
make build    # build images
make up       # start services
make down     # stop services
make logs     # follow logs
make status   # list containers
make clean    # down -v (remove containers + volumes)
make fclean   # clean + remove custom images
make re       # full rebuild from scratch
```

---

## Persistence

This project stores data in:

- `/home/${USER}/data/mariadb`
- `/home/${USER}/data/wordpress`

So even if containers are deleted, your DB and WP files remain (unless you clean everything manually).

---

## What I learned (human part)

This project made me understand that DevOps is not “just Docker commands”.  
I had to think about:

- service dependencies and boot order
- volume ownership/permissions
- secure defaults (HTTPS only)
- environment configuration
- container lifecycle and reproducibility

It feels much closer to real-world backend infrastructure than a typical school exercise.

---

## Common issues

If something is not starting:

1. Check Docker daemon:
   ```bash
   docker info
   ```

2. Validate compose config:
   ```bash
   docker compose -f srcs/docker-compose.yml config
   ```

3. Verify `.env` exists and values are valid.

4. Check permissions on data folders.

---

## 42 evaluation quick-check (example)

- [x] Single Docker network for services
- [x] One container per service
- [x] Custom Dockerfiles
- [x] NGINX with TLS (port 443)
- [x] WordPress + PHP-FPM
- [x] MariaDB separate container
- [x] Persistent volumes
- [x] Restart policy enabled
- [x] `.env`-based configuration

---

## Final note

Inception is where I stopped seeing containers as “magic boxes” and started treating them as infrastructure components.

If you're also doing this project at 42: good luck, test everything twice, and trust your logs 👊
