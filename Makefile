# --- # Colors # --- #
RESET = \033[0m
WHITE_BOLD = \033[1;39m
BLACK_BOLD = \033[1;30m
RED_BOLD = \033[1;31m
GREEN_BOLD = \033[1;32m
YELLOW_BOLD = \033[1;33m
BLUE_BOLD = \033[1;34m
PINK_BOLD = \033[1;35m
CYAN_BOLD = \033[1;36m

WHITE = \033[0;39m
BLACK = \033[0;30m
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[0;33m
BLUE = \033[0;34m
PINK = \033[0;35m
CYAN = \033[0;36m
# ------------------ #


# ---- # Vars # ---- #
COPY = cp -rf
RMV = rm -rf
MKDIR = mkdir -p
PRINT = echo
DOCKER = docker

MARIADB = mariadb
WORDPRESS = wordpress
NGINX = nginx

SHARED_DIR = ../shared
SRCS = srcs/
REQS = $(SRCS)requirements/
MARIADB_DIR = $(REQS)mariadb/
WORDPRESS_DIR = $(REQS)wordpress/
NGINX_DIR = $(REQS)nginx/
ENV_FILE = $(SRCS).env
YAML = $(SRCS)docker-compose.yml
DATABASE_VOLUME = $(VOLUMES_PATH)database/
WEBSITE_VOLUME = $(VOLUMES_PATH)website/

ifeq ("$(HOME)", "/home/cfidalgo")
	VOLUMES_PATH = /home/cfidalgo/data/
else ifeq ("$(HOME)", "/home/chris")
	VOLUMES_PATH = /home/chris/42bcn/Inception/data/
else
	VOLUMES_PATH = ./data/
endif
# ------------------ #


# --- # Rules # ---- #
all:
	@$(PRINT) "$(CYAN)Use $(YELLOW)'make up'$(CYAN) to build the application$(RESET)"

copy:
	@$(PRINT) "$(PINK)Copying files to $(WHITE_BOLD)VM$(PINK)...$(RESET)"
	@$(COPY) * $(ENV_FILE) $(SHARED_DIR)
	@$(PRINT) "$(GREEN)Files copied$(RESET)"

list:
	@$(PRINT) "$(CYAN)Printing all $(YELLOW)containers$(CYAN):$(RESET)"
	@$(DOCKER) ps -a
	@$(PRINT) "$(CYAN)Printing all $(YELLOW)images$(CYAN):$(RESET)"
	@$(DOCKER) images -a
	@$(PRINT) "$(CYAN)Printing all $(WHITE)volumes$(CYAN):$(RESET)"
	@$(DOCKER) volume ls
	@$(PRINT) "$(CYAN)Printing all $(WHITE)networks$(CYAN):$(RESET)"
	@$(DOCKER) network ls

up:
	@$(PRINT) "$(BLUE)Creating $(WHITE_BOLD)volumes$(BLUE) directories...$(RESET)"
	@$(MKDIR) $(DATABASE_VOLUME) $(WEBSITE_VOLUME)
	@$(PRINT) "$(BLUE)Deploying $(WHITE_BOLD)application$(BLUE)...$(RESET)"
	@$(DOCKER) compose -f $(YAML) up -d --build

down:
	@$(PRINT) "$(BLUE)Stopping and removing application $(WHITE_BOLD)containers$(BLUE)...$(RESET)"
	@$(DOCKER) compose -f $(YAML) down

fdown:
	@$(PRINT) "$(BLUE)Stopping and removing application $(WHITE_BOLD)containers$(BLUE) and $(WHITE_BOLD)volumes$(BLUE)...$(RESET)"
	@$(DOCKER) compose -f $(YAML) down -v
	@$(RMV) $(VOLUMES_PATH)

log:
	@$(PRINT) "$(PINK)Reading $(WHITE_BOLD)$(NGINX)$(PINK) logs...$(RESET)"
	@$(DOCKER) logs $(NGINX)

bld:
	@$(PRINT) "$(PINK)Building $(WHITE_BOLD)$(NGINX)$(PINK) image...$(RESET)"
	@$(DOCKER) build -t $(NGINX) $(NGINX_DIR)

run:
	@$(PRINT) "$(PINK)Running $(WHITE_BOLD)$(NGINX)$(PINK) container...$(RESET)"
	@$(DOCKER) run -d --name $(NGINX) $(NGINX)

dpl: bld run
	@$(PRINT) "$(GREEN)The $(WHITE_BOLD)$(NGINX)$(GREEN) container deployed successfully$(RESET)"

exc:
	@$(PRINT) "$(PINK)Interacting with $(WHITE_BOLD)$(NGINX)$(PINK) container with a $(WHITE_BOLD)bash$(PINK) shell...$(RESET)"
	@$(DOCKER) exec -it $$(docker ps -aq --filter="name=$(NGINX)") bash

stp:
	@$(PRINT) "$(PINK)Stopping $(WHITE_BOLD)$(NGINX)$(PINK) container...$(RESET)"
	@$(DOCKER) stop $$(docker ps -aq --filter="name=$(NGINX)")

cln: stp
	@$(PRINT) "$(PINK)Removing $(WHITE_BOLD)$(NGINX)$(PINK) container...$(RESET)"
	@$(DOCKER) rm $$(docker ps -aq --filter="name=$(NGINX)")

clean: down
	@$(PRINT) "$(PINK)Application $(GREEN)removed$(PINK).$(RESET)"

fclean: fdown
	@$(PRINT) "$(PINK)Removing $(WHITE_BOLD)cache$(PINK)...$(RESET)"
	@$(DOCKER) system prune -fa
	@$(RMV) $(VOLUMES_PATH)
	@$(PRINT) "$(GREEN)Cache removed successfully$(RESET)"

# ------------------ #


# --- # Extras # --- #
.PHONY: all \
		copy \
		list \
		up \
		down \
		fdown \
		bld \
		run \
		dpl \
		exc \
		stp \
		cln \
		clean \
		fclean

.SILENT:
# ------------------ #
