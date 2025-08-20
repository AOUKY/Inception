NAME := inception
COMPOSE := docker compose -f srcs/docker-compose.yml
DATA_DIR = /home/$(USER)/data

all: build up

build:
	mkdir -p $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	$(COMPOSE) build 

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

logs:
	$(COMPOSE) logs -f

status:
	$(COMPOSE) ps

clean:
	$(COMPOSE) down -v

fclean: clean
	-docker image rm -f nginx:custom wordpress:custom mariadb:custom || true
	-docker image prune -f


re: fclean all
