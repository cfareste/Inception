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
PRINT = echo

SHARED_DIR = ../shared

# ------------------ #

# --- # Rules # ---- #
all:
	@$(PRINT) "$(CYAN)Use $(YELLOW)'make up'$(CYAN) to build the application$(RESET)"

copy:
	@$(PRINT) "$(PINK)Copying files to $(WHITE_BOLD)VM$(PINK)...$(RESET)"
	@$(COPY) * $(SHARED_DIR)
	@$(PRINT) "$(GREEN)Files copied$(RESET)"

# ------------------ #

# --- # Extras # --- #
-include $(DEPS)

.PHONY:

.SILENT:
# ------------------ #
