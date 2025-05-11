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

SHARED_DIR = ../shared
SRCS = srcs/
REQS = $(SRCS)requirements/
MARIADB_DIR = $(REQS)mariadb/
YAML = ./srcs/docker-compose.yml
VOLUMES_PATH = ./data/
DATABASE_VOLUME = $(VOLUMES_PATH)database/

# ------------------ #

# --- # Rules # ---- #
all:
	@$(PRINT) "$(CYAN)Use $(YELLOW)'make up'$(CYAN) to build the application$(RESET)"

copy:
	@$(PRINT) "$(PINK)Copying files to $(WHITE_BOLD)VM$(PINK)...$(RESET)"
	@$(COPY) * $(SHARED_DIR)
	@$(PRINT) "$(GREEN)Files copied$(RESET)"

list:
	@$(PRINT) "$(CYAN)Printing all docker $(YELLOW)containers$(CYAN):$(RESET)"
	@$(DOCKER) ps -a
	@$(PRINT) "$(CYAN)Printing all docker $(YELLOW)images$(CYAN):$(RESET)"
	@$(DOCKER) images -a

up:
	@$(PRINT) "$(BLUE)Creating $(WHITE_BOLD)volumes$(BLUE) directories...$(RESET)"
	@$(MKDIR) $(VOLUMES_PATH) $(DATABASE_VOLUME)
	@$(PRINT) "$(BLUE)Deploying $(WHITE_BOLD)application$(BLUE)...$(RESET)"
	@$(DOCKER) compose -f $(YAML) up -d --build

down:
	@$(PRINT) "$(BLUE)Stopping and removing application $(WHITE_BOLD)containers$(BLUE)...$(RESET)"
	@$(DOCKER) compose -f $(YAML) down

fdown:
	@$(PRINT) "$(BLUE)Stopping and removing application $(WHITE_BOLD)containers$(BLUE) and $(WHITE_BOLD)volumes$(BLUE)...$(RESET)"
	@$(DOCKER) compose -f $(YAML) down -v

logmariadb:
	@$(PRINT) "$(PINK)Reading $(WHITE_BOLD)$(MARIADB)$(PINK) logs...$(RESET)"
	@$(DOCKER) logs $(MARIADB)

bldmariadb:
	@$(PRINT) "$(PINK)Building $(WHITE_BOLD)$(MARIADB)$(PINK) image...$(RESET)"
	@$(DOCKER) build -t $(MARIADB) $(MARIADB_DIR)

runmariadb:
	@$(PRINT) "$(PINK)Running $(WHITE_BOLD)$(MARIADB)$(PINK) container...$(RESET)"
	@$(DOCKER) run -d --name $(MARIADB) $(MARIADB)

dplmariadb: bldmariadb runmariadb
	@$(PRINT) "$(GREEN)The $(WHITE_BOLD)mariadb$(GREEN) container deployed successfully$(RESET)"

excmariadb:
	@$(PRINT) "$(PINK)Interacting with $(WHITE_BOLD)mariadb$(PINK) container with a $(WHITE_BOLD)bash$(PINK) shell...$(RESET)"
	@$(DOCKER) exec -it $$(docker ps -aq --filter="name=$(MARIADB)") bash

stpmariadb:
	@$(PRINT) "$(PINK)Stopping $(WHITE_BOLD)$(MARIADB)$(PINK) container...$(RESET)"
	@$(DOCKER) stop $$(docker ps -aq --filter="name=$(MARIADB)")

clnmariadb: stpmariadb
	@$(PRINT) "$(PINK)Removing $(WHITE_BOLD)$(MARIADB)$(PINK) container...$(RESET)"
	@$(DOCKER) rm $$(docker ps -aq --filter="name=$(MARIADB)")

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
		up \
		down \
		fdown \
		bldmariadb \
		runmariadb \
		dplmariadb \
		excmariadb \
		stpmariadb \
		clnmariadb \
		clean \
		fclean

.SILENT:
# ------------------ #
