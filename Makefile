# Makefile – Fly.io environment management for the Streamlit Quant Analysis app.
#
# Usage:
#   make              – show this help
#   make check-prereqs – verify required tools are installed
#   make create       – interactive wizard: configure + create + deploy
#   make deploy       – (re)deploy the current app
#   make destroy      – permanently delete the app and all resources
#   make status       – show running VMs and health
#   make logs         – stream live application logs
#   make open         – open the app in your default browser
#   make ssh          – SSH into a running VM
#   make secrets      – list secrets (values hidden)
#   make scale        – show current scale settings

.PHONY: help check-prereqs create deploy destroy status logs open ssh secrets scale

# ── Detect fly binary (flyctl preferred, fall back to fly) ────────────────────
FLY := $(shell command -v flyctl 2>/dev/null || command -v fly 2>/dev/null || echo flyctl)

.DEFAULT_GOAL := help

# ── Help ──────────────────────────────────────────────────────────────────────
help: ## Show all available commands
	@printf "\n\033[1mFly.io Streamlit App — Management Commands\033[0m\n\n"
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*?##/ \
	    { printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@printf "\n\033[90mGet started:\033[0m  make create\n\n"

# ── Prerequisites (auto-run before every Fly command) ─────────────────────────
check-prereqs: ## ① Verify flyctl and Docker are installed and you are logged in
	@bash scripts/check-prereqs.sh

# ── Environment lifecycle ─────────────────────────────────────────────────────
create: check-prereqs ## ② Interactively create a new Fly.io environment (asks questions)
	@bash scripts/fly-setup.sh

deploy: check-prereqs ## ③ Build and (re)deploy the app to Fly.io (requires fly.toml)
	@test -f fly.toml || { echo ""; echo "  \033[31m✗\033[0m  fly.toml not found. Run 'make create' first."; echo ""; exit 1; }
	@$(FLY) deploy --remote-only

destroy: check-prereqs ## ④ Permanently destroy the Fly.io app and all its resources
	@bash scripts/fly-destroy.sh

# ── Operations ────────────────────────────────────────────────────────────────
status: ## Show app status, VM info, and health checks
	@$(FLY) status

logs: ## Stream live application logs (Ctrl-C to stop)
	@$(FLY) logs

open: ## Open the deployed app in your default browser
	@$(FLY) open

ssh: ## Open an interactive SSH session on a running VM
	@$(FLY) ssh console

secrets: ## List app secrets (names only; values are never shown)
	@$(FLY) secrets list

scale: ## Show current VM count and size settings
	@$(FLY) scale show
