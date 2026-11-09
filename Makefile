# Makefile for dotfiles installation on macOS
# Uses Homebrew for package management and mise for development tool versions

# =============================================================================
# Make Configuration
# =============================================================================
# GNU Make 3.81 does not support .ONESHELL or .SHELLFLAGS.
SHELL := /bin/zsh -eu -o pipefail
.NOTPARALLEL:
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# =============================================================================
# Phony Targets
# =============================================================================
.PHONY: help all verify check-xcode brew mise kitty clean
.PHONY: profile zsh neovim tmux git install-tpm install-zinit zsh-plugins
.PHONY: tools brew-tools nodejs golang ruby terraform
.PHONY: kubernetes kubectl helm kind kubectx
.PHONY: docker aws gcloud azure
.PHONY: list update nodejs-update validate test benchmark

# =============================================================================
# Default Target
# =============================================================================
.DEFAULT_GOAL := help

# =============================================================================
# Variables
# =============================================================================
BOLD   := $(shell tput bold)
RED    := $(shell tput setaf 1)
GREEN  := $(shell tput setaf 2)
YELLOW := $(shell tput setaf 3)
RESET  := $(shell tput sgr0)

DOTFILES   := $(CURDIR)
CONFIG_DIR := $(HOME)/.config
KITTY_CONFIG := $(CONFIG_DIR)/kitty
XDG_DATA_HOME ?= $(HOME)/.local/share
ZINIT_HOME ?= $(XDG_DATA_HOME)/zinit/zinit.git
LINK_CONFIG := /bin/zsh "$(DOTFILES)/scripts/link-config.zsh"

# =============================================================================
# Helper Functions
# =============================================================================
# Install a tool via mise (latest version, set as global)
define install_mise_tool
	@echo "$(YELLOW)Installing $(1)...$(RESET)"
	@mise use --global $(1)@latest 2>&1 \
		&& echo "$(GREEN)✓ $(1) installed$(RESET)" \
		|| { echo "$(RED)✗ Failed to install $(1)$(RESET)"; exit 1; }
endef

# =============================================================================
# Help Target
# =============================================================================
help: ## Show this help message
	@echo ""
	@echo "$(BOLD)Dotfiles Makefile - macOS$(RESET)"
	@echo ""
	@echo "$(BOLD)Main Targets:$(RESET)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E '^(all|verify|brew|mise|kitty|profile|tools|clean):' | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)  %-28s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(BOLD)Profile Targets:$(RESET)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E '^(zsh|neovim|tmux|git):' | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)  %-28s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(BOLD)Tool Targets:$(RESET)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E '^(brew-tools|nodejs|golang|terraform|kubernetes|list|update):' | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)  %-28s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(BOLD)Checks and Shell Maintenance:$(RESET)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -E '^(validate|test|benchmark|zsh-plugins):' | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)  %-28s$(RESET) %s\n", $$1, $$2}'
	@echo ""

# =============================================================================
# Verification Targets
# =============================================================================
check-xcode: ## Verify Xcode Command Line Tools are installed
	@echo "$(BOLD)Checking Xcode Command Line Tools...$(RESET)"
	@if ! xcode-select -p &>/dev/null; then \
		echo "$(RED)✗ Xcode Command Line Tools not found$(RESET)"; \
		echo ""; \
		echo "$(YELLOW)Run xcode-select --install, complete the installation, then retry.$(RESET)"; \
		exit 1; \
	else \
		echo "$(GREEN)✓ Xcode Command Line Tools installed at $$(xcode-select -p)$(RESET)"; \
	fi

verify: check-xcode ## Verify all system dependencies
	@echo ""
	@echo "$(BOLD)System Verification$(RESET)"
	@echo "$(BOLD)==================$(RESET)"
	@echo ""
	@echo "$(BOLD)macOS Version:$(RESET) $$(sw_vers -productVersion)"
	@echo "$(BOLD)Architecture:$(RESET) $$(uname -m)"
	@echo ""
	@if command -v brew &>/dev/null; then \
		echo "$(GREEN)✓$(RESET) Homebrew: $$(brew --version | head -1)"; \
	else \
		echo "$(YELLOW)✗$(RESET) Homebrew: Not installed (run: make brew)"; \
	fi
	@if command -v git &>/dev/null; then \
		echo "$(GREEN)✓$(RESET) Git: $$(git --version)"; \
	else \
		echo "$(YELLOW)✗$(RESET) Git: Not installed (install Xcode tools)"; \
	fi
	@if command -v zsh &>/dev/null; then \
		echo "$(GREEN)✓$(RESET) ZSH: $$(zsh --version)"; \
	else \
		echo "$(YELLOW)✗$(RESET) ZSH: Not installed (should be default on macOS)"; \
	fi
	@if command -v tmux &>/dev/null; then \
		echo "$(GREEN)✓$(RESET) Tmux: $$(tmux -V)"; \
	else \
		echo "$(YELLOW)✗$(RESET) Tmux: Not installed (run: make brew-tools)"; \
	fi
	@if command -v nvim &>/dev/null; then \
		echo "$(GREEN)✓$(RESET) Neovim: $$(nvim --version | head -1)"; \
	else \
		echo "$(YELLOW)✗$(RESET) Neovim: Not installed (run: make brew-tools)"; \
	fi
	@if command -v mise &>/dev/null; then \
		echo "$(GREEN)✓$(RESET) mise: $$(mise --version)"; \
	else \
		echo "$(YELLOW)✗$(RESET) mise: Not installed (run: make mise)"; \
	fi
	@echo ""

# =============================================================================
# Main Installation Targets
# =============================================================================
all: check-xcode brew mise profile tools kitty ## Install all components (full setup)
	@echo ""
	@echo "$(GREEN)$(BOLD)✓ Full installation complete!$(RESET)"
	@echo ""
	@echo "$(YELLOW)Next steps:$(RESET)"
	@echo "  1. Restart your terminal or run: exec zsh"
	@echo "  2. Open Kitty terminal for the full experience"
	@echo "  3. Run 'nvim' to complete plugin installation"
	@echo ""

# The upstream Homebrew installer requires bash; it is the only bash use here
brew: check-xcode ## Install Homebrew package manager
	@echo "$(BOLD)Checking Homebrew installation...$(RESET)"
	@if ! command -v brew >/dev/null 2>&1; then \
		echo "$(YELLOW)Homebrew not found. Installing...$(RESET)"; \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
		echo ""; \
		echo "$(BOLD)Configuring Homebrew in PATH...$(RESET)"; \
		if [ "$$(uname -m)" = "arm64" ]; then \
			echo 'eval "$$(/opt/homebrew/bin/brew shellenv)"' >> $(HOME)/.zprofile; \
			eval "$$(/opt/homebrew/bin/brew shellenv)"; \
		else \
			echo 'eval "$$(/usr/local/bin/brew shellenv)"' >> $(HOME)/.zprofile; \
			eval "$$(/usr/local/bin/brew shellenv)"; \
		fi; \
		echo "$(GREEN)✓ Homebrew installed successfully!$(RESET)"; \
	else \
		echo "$(GREEN)✓ Homebrew already installed at $$(command -v brew)$(RESET)"; \
		echo "Version: $$(brew --version | head -n 1)"; \
	fi

mise: brew ## Install mise version manager
	@echo "$(BOLD)Installing mise...$(RESET)"
	@if ! brew list mise >/dev/null 2>&1; then \
		echo "$(YELLOW)Installing mise via Homebrew...$(RESET)"; \
		brew install mise; \
		echo "$(GREEN)✓ mise installed$(RESET)"; \
	else \
		echo "$(GREEN)✓ mise already installed: $$(mise --version)$(RESET)"; \
	fi
	@echo ""
	@echo "$(BOLD)Activating mise...$(RESET)"
	@if command -v mise &>/dev/null; then \
		echo "$(GREEN)✓ mise active: $$(mise --version)$(RESET)"; \
	else \
		echo "$(YELLOW)mise installed but not yet in PATH. Run: exec zsh$(RESET)"; \
	fi

kitty: brew ## Install Kitty terminal emulator and configuration
	@echo "$(BOLD)Installing Kitty terminal emulator...$(RESET)"
	@if ! command -v kitty >/dev/null 2>&1; then \
		echo "$(YELLOW)Installing Kitty terminal...$(RESET)"; \
		brew install --cask kitty; \
	else \
		echo "$(GREEN)✓ Kitty already installed$(RESET)"; \
	fi
	@echo ""
	@echo "$(BOLD)Installing JetBrains Mono font...$(RESET)"
	@if ! brew list --cask font-jetbrains-mono >/dev/null 2>&1; then \
		echo "$(YELLOW)Installing font...$(RESET)"; \
		brew install --cask font-jetbrains-mono; \
	else \
		echo "$(GREEN)✓ JetBrains Mono font already installed$(RESET)"; \
	fi
	@echo ""
	@echo "$(BOLD)Linking Kitty configuration...$(RESET)"
	@if [ ! -f "$(DOTFILES)/kitty.conf" ]; then \
		echo "$(RED)✗ kitty.conf not found at $(DOTFILES)/kitty.conf$(RESET)"; \
		exit 1; \
	fi
	@$(LINK_CONFIG) "$(DOTFILES)/kitty.conf" "$(KITTY_CONFIG)/kitty.conf"
	@echo "$(GREEN)✓ Kitty configuration linked$(RESET)"
	@echo "  ~/.config/kitty/kitty.conf -> $(DOTFILES)/kitty.conf"
	@echo ""
	@echo "$(GREEN)$(BOLD)✓ Kitty setup complete!$(RESET)"

clean: ## Unlink this repository's configs; preserve files and unrelated links
	@echo "$(BOLD)Cleaning up...$(RESET)"
	@echo "$(YELLOW)This will remove symlinked configurations$(RESET)"
	@$(LINK_CONFIG) --unlink "$(DOTFILES)/kitty.conf" "$(KITTY_CONFIG)/kitty.conf"
	@$(LINK_CONFIG) --unlink "$(DOTFILES)/zshrc" "$(HOME)/.zshrc"
	@$(LINK_CONFIG) --unlink "$(DOTFILES)/zsh.d" "$(HOME)/.zsh.d"
	@$(LINK_CONFIG) --unlink "$(DOTFILES)/nvim" "$(CONFIG_DIR)/nvim"
	@$(LINK_CONFIG) --unlink "$(DOTFILES)/tmux.conf" "$(HOME)/.tmux.conf"
	@$(LINK_CONFIG) --unlink "$(DOTFILES)/gitignore_global" "$(HOME)/.gitignore_global"
	@echo "$(GREEN)✓ Cleanup complete$(RESET)"

# =============================================================================
# Profile Configuration Targets
# =============================================================================
profile: zsh neovim tmux git ## Install all profile configurations (ZSH, Neovim, Tmux, Git)
	@echo ""
	@echo "$(GREEN)$(BOLD)✓ Profile configuration complete!$(RESET)"
	@echo ""
	@echo "$(YELLOW)Next steps:$(RESET)"
	@echo "  1. Restart your terminal or run: exec zsh"
	@echo "  2. Run 'nvim' to install plugins automatically"
	@echo ""

install-zinit: ## Install Zinit if missing; do not update existing installations
	@if [[ ! -r "$(ZINIT_HOME)/zinit.zsh" ]]; then \
		if [[ -e "$(ZINIT_HOME)" || -L "$(ZINIT_HOME)" ]]; then \
			print -ru2 -- "Incomplete Zinit installation: $(ZINIT_HOME)"; \
			exit 1; \
		fi; \
		ZINIT_DIR="$(ZINIT_HOME)"; mkdir -p "$${ZINIT_DIR:h}"; \
		git clone --depth=1 https://github.com/zdharma-continuum/zinit.git "$(ZINIT_HOME)"; \
	fi

zsh-plugins: install-zinit ## Install missing ZSH plugins without updating existing ones
	@ZINIT_HOME="$(ZINIT_HOME)" DOTFILES="$(DOTFILES)" DOTFILES_INSTALL_PLUGINS=1 \
		/bin/zsh -df -e -c 'source "$$ZINIT_HOME/zinit.zsh"; source "$$DOTFILES/zsh.d/plugins.zsh"; \
		/bin/zsh "$${ZINIT[PLUGINS_DIR]}/romkatv---gitstatus/install"'

zsh: zsh-plugins ## Install ZSH configuration (Zinit + modules)
	@echo "$(BOLD)Installing ZSH configuration...$(RESET)"
	@if [ ! -f "$(DOTFILES)/zshrc" ]; then \
		echo "$(RED)✗ zshrc not found at $(DOTFILES)/zshrc$(RESET)"; \
		exit 1; \
	fi
	@if [ ! -d "$(DOTFILES)/zsh.d" ]; then \
		echo "$(RED)✗ zsh.d directory not found at $(DOTFILES)/zsh.d$(RESET)"; \
		exit 1; \
	fi
	@$(LINK_CONFIG) "$(DOTFILES)/zshrc" "$(HOME)/.zshrc"
	@$(LINK_CONFIG) "$(DOTFILES)/zsh.d" "$(HOME)/.zsh.d"
	@echo "$(GREEN)✓ ZSH configuration installed$(RESET)"
	@echo "  ~/.zshrc  -> $(DOTFILES)/zshrc"
	@echo "  ~/.zsh.d  -> $(DOTFILES)/zsh.d"

neovim: ## Install Neovim configuration (lazy.nvim + LSP)
	@echo "$(BOLD)Installing Neovim configuration...$(RESET)"
	@if ! command -v nvim &>/dev/null; then \
		echo "$(YELLOW)Neovim not found. Installing via Homebrew...$(RESET)"; \
		brew install neovim; \
	fi
	@if [ ! -d "$(DOTFILES)/nvim" ]; then \
		echo "$(RED)✗ nvim directory not found at $(DOTFILES)/nvim$(RESET)"; \
		exit 1; \
	fi
	@$(LINK_CONFIG) "$(DOTFILES)/nvim" "$(CONFIG_DIR)/nvim"
	@echo "$(GREEN)✓ Neovim configuration installed$(RESET)"
	@echo "  ~/.config/nvim -> $(DOTFILES)/nvim"
	@echo "$(YELLOW)  Run 'nvim' to install plugins automatically$(RESET)"

install-tpm: ## Install Tmux Plugin Manager (TPM)
	@echo "$(BOLD)Installing TPM (Tmux Plugin Manager)...$(RESET)"
	@if [ ! -d "$(HOME)/.tmux/plugins/tpm" ]; then \
		echo "$(YELLOW)Cloning TPM repository...$(RESET)"; \
		git clone https://github.com/tmux-plugins/tpm $(HOME)/.tmux/plugins/tpm; \
		echo "$(GREEN)✓ TPM installed at ~/.tmux/plugins/tpm$(RESET)"; \
		echo "$(YELLOW)  Open tmux and press prefix + I to install plugins$(RESET)"; \
	else \
		echo "$(GREEN)✓ TPM already installed$(RESET)"; \
	fi

tmux: install-tpm ## Install Tmux configuration
	@echo "$(BOLD)Installing Tmux configuration...$(RESET)"
	@if ! command -v tmux &>/dev/null; then \
		echo "$(YELLOW)Tmux not found. Installing via Homebrew...$(RESET)"; \
		brew install tmux; \
	fi
	@if [ ! -f "$(DOTFILES)/tmux.conf" ]; then \
		echo "$(RED)✗ tmux.conf not found at $(DOTFILES)/tmux.conf$(RESET)"; \
		exit 1; \
	fi
	@$(LINK_CONFIG) "$(DOTFILES)/tmux.conf" "$(HOME)/.tmux.conf"
	@echo "$(GREEN)✓ Tmux configuration installed$(RESET)"
	@echo "  ~/.tmux.conf -> $(DOTFILES)/tmux.conf"
	@echo "$(YELLOW)  To install plugins: open tmux and press Ctrl+A then I$(RESET)"

git: ## Install Git configuration (gitignore_global)
	@echo "$(BOLD)Installing Git configuration...$(RESET)"
	@if [ ! -f "$(DOTFILES)/gitignore_global" ]; then \
		echo "$(RED)✗ gitignore_global not found at $(DOTFILES)/gitignore_global$(RESET)"; \
		exit 1; \
	fi
	@$(LINK_CONFIG) "$(DOTFILES)/gitignore_global" "$(HOME)/.gitignore_global"
	@git config --global core.excludesfile $(HOME)/.gitignore_global 2>/dev/null || true
	@echo "$(GREEN)✓ Git configuration installed$(RESET)"
	@echo "  ~/.gitignore_global -> $(DOTFILES)/gitignore_global"

# =============================================================================
# Development Tools Targets (mise + Homebrew)
# =============================================================================
tools: brew-tools nodejs golang terraform kubernetes ## Install essential development tools
	@echo ""
	@echo "$(GREEN)$(BOLD)✓ Essential development tools installed!$(RESET)"
	@echo ""
	@echo "$(YELLOW)Installed tools:$(RESET)"
	@mise ls 2>/dev/null | awk '{printf "  %-16s %s\n", $$1, $$2}' || echo "  No mise tools installed yet"
	@echo ""

brew-tools: ## Install essential CLI tools via Homebrew
	@echo "$(BOLD)Installing essential tools via Homebrew...$(RESET)"
	@echo ""
	@echo "$(BOLD)Core Tools:$(RESET)"
	@for tool in git tmux neovim; do \
		if brew list $$tool &>/dev/null; then \
			echo "$(GREEN)✓$(RESET) $$tool"; \
		else \
			echo "$(YELLOW)Installing $$tool...$(RESET)"; \
			brew install --quiet $$tool || brew install $$tool; \
		fi; \
	done
	@echo ""
	@echo "$(BOLD)CLI Utilities:$(RESET)"
	@for tool in wget curl jq yq gh git-lfs bat lsd fd ripgrep fzf htop tree tldr zoxide direnv; do \
		if brew list $$tool &>/dev/null; then \
			echo "$(GREEN)✓$(RESET) $$tool"; \
		else \
			echo "$(YELLOW)Installing $$tool...$(RESET)"; \
			brew install --quiet $$tool || brew install $$tool; \
		fi; \
	done
	@echo ""
	@echo "$(GREEN)✓ All essential tools installed$(RESET)"

nodejs: ## Install Node.js LTS (latest even-numbered version)
	@echo "$(YELLOW)Installing Node.js LTS...$(RESET)"
	@mise use --global node@lts 2>&1 \
		&& echo "$(GREEN)✓ Node.js $$(node --version 2>/dev/null || mise exec node -- node --version) installed$(RESET)" \
		|| { echo "$(RED)✗ Failed to install Node.js$(RESET)"; exit 1; }

nodejs-update: ## Update Node.js to latest LTS
	@echo "$(YELLOW)Updating Node.js to latest LTS...$(RESET)"
	@CURRENT=$$(mise current node 2>/dev/null || echo "none"); \
	mise upgrade node 2>&1; \
	NEW=$$(mise current node 2>/dev/null || echo "unknown"); \
	if [ "$$CURRENT" = "$$NEW" ]; then \
		echo "$(GREEN)✓ Node.js $$NEW is already the latest$(RESET)"; \
	else \
		echo "$(GREEN)✓ Updated Node.js: $$CURRENT -> $$NEW$(RESET)"; \
	fi

golang: ## Install Go (latest stable)
	$(call install_mise_tool,go)

ruby: ## Install Ruby (latest stable)
	$(call install_mise_tool,ruby)

terraform: ## Install Terraform (latest stable)
	$(call install_mise_tool,terraform)

kubectl: ## Install kubectl (latest stable)
	$(call install_mise_tool,kubectl)

helm: ## Install Helm (latest stable)
	$(call install_mise_tool,helm)

kind: ## Install kind - Kubernetes in Docker
	$(call install_mise_tool,kind)

kubectx: ## Install kubectx/kubens via Homebrew
	@echo "$(YELLOW)Installing kubectx...$(RESET)"
	@if brew list kubectx &>/dev/null; then \
		echo "$(GREEN)✓ kubectx already installed$(RESET)"; \
	else \
		brew install kubectx; \
		echo "$(GREEN)✓ kubectx installed$(RESET)"; \
	fi

kubernetes: kubectl helm kind kubectx ## Install all Kubernetes tools

docker: ## Install Docker Desktop via Homebrew
	@echo "$(BOLD)Installing Docker Desktop...$(RESET)"
	@if brew list --cask docker &>/dev/null; then \
		echo "$(GREEN)✓ Docker Desktop already installed$(RESET)"; \
	else \
		brew install --cask docker; \
		echo "$(GREEN)✓ Docker Desktop installed$(RESET)"; \
	fi

aws: ## Install AWS CLI
	$(call install_mise_tool,awscli)

gcloud: ## Install Google Cloud SDK via Homebrew
	@echo "$(BOLD)Installing Google Cloud SDK...$(RESET)"
	@if brew list --cask google-cloud-sdk &>/dev/null; then \
		echo "$(GREEN)✓ Google Cloud SDK already installed$(RESET)"; \
	else \
		brew install --cask google-cloud-sdk; \
		echo "$(GREEN)✓ Google Cloud SDK installed$(RESET)"; \
	fi

azure: ## Install Azure CLI via Homebrew
	@echo "$(BOLD)Installing Azure CLI...$(RESET)"
	@if brew list azure-cli &>/dev/null; then \
		echo "$(GREEN)✓ Azure CLI already installed$(RESET)"; \
	else \
		brew install azure-cli; \
		echo "$(GREEN)✓ Azure CLI installed$(RESET)"; \
	fi

list: ## List all installed mise tools and versions
	@echo "$(BOLD)mise version:$(RESET) $$(mise --version)"
	@echo ""
	@echo "$(BOLD)Installed Tools:$(RESET)"
	@mise ls 2>/dev/null || echo "  No tools installed"

update: ## Update mise and all managed tools
	@echo "$(BOLD)Updating mise...$(RESET)"
	@brew upgrade mise 2>/dev/null || echo "$(GREEN)✓ mise up to date$(RESET)"
	@echo ""
	@echo "$(BOLD)Upgrading all tools...$(RESET)"
	@mise upgrade 2>&1 || true
	@echo "$(GREEN)✓ Update complete$(RESET)"

validate: ## Check configuration syntax without touching live sessions or clipboard
	@/bin/zsh "$(DOTFILES)/scripts/validate-configs.zsh"

test: validate ## Run shell and installer regression tests in temporary directories
	@/bin/zsh "$(DOTFILES)/scripts/test-shell.zsh"

benchmark: ## Measure warm startup-and-exit, with and without a PTY (macOS)
	@/bin/zsh "$(DOTFILES)/scripts/benchmark-shell.zsh"
