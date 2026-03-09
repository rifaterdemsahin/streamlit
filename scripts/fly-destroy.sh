#!/usr/bin/env bash
# fly-destroy.sh – permanently destroy the Fly.io app and all its resources.
#
# The user must type the app name to confirm — this prevents accidental deletion.
#
# Usage: bash scripts/fly-destroy.sh   (called automatically by 'make destroy')

set -euo pipefail

# ── Colour/print helpers ──────────────────────────────────────────────────────
BOLD='\033[1m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

die()  { printf "${RED}✗  ERROR: %s${NC}\n" "$*" >&2; exit 1; }
warn() { printf "${YELLOW}!${NC}  %s\n" "$*"; }
ok()   { printf "${GREEN}✔${NC}  %s\n" "$*"; }
info() { printf "${CYAN}ℹ${NC}  %s\n" "$*"; }

# ── Detect fly binary ─────────────────────────────────────────────────────────
FLY_CMD=""
command -v flyctl &>/dev/null && FLY_CMD=flyctl
command -v fly    &>/dev/null && [[ -z "$FLY_CMD" ]] && FLY_CMD=fly
[[ -z "$FLY_CMD" ]] && die "flyctl not found. Run 'make check-prereqs' first."

# ── Read app name from fly.toml ───────────────────────────────────────────────
if [[ ! -f fly.toml ]]; then
    die "fly.toml not found. Have you run 'make create' yet?"
fi

APP_NAME=$(awk -F'"' '/^app / {print $2}' fly.toml | tr -d '[:space:]')
[[ -z "$APP_NAME" ]] && die "Could not determine app name from fly.toml."

# ── Warning banner ────────────────────────────────────────────────────────────
printf "\n${BOLD}${RED}⚠  WARNING — Irreversible Action${NC}\n\n"
warn "You are about to permanently destroy the Fly.io app:"
printf "     ${BOLD}%s${NC}\n\n" "$APP_NAME"
warn "ALL of the following resources will be deleted:"
warn "  • All running machines / VMs"
warn "  • All persistent volumes (data)"
warn "  • All secrets and environment variables"
warn "  • All TLS certificates"
echo ""
warn "This action CANNOT be undone."
echo ""

# ── Confirmation ──────────────────────────────────────────────────────────────
read -rp "$(printf "Type ${BOLD}${APP_NAME}${NC} to confirm deletion (or anything else to abort): ")" CONFIRM_NAME

if [[ "$CONFIRM_NAME" != "$APP_NAME" ]]; then
    echo ""
    info "Name did not match — operation aborted. No changes were made."
    exit 0
fi

# ── Destroy ───────────────────────────────────────────────────────────────────
echo ""
printf "${RED}Destroying '${APP_NAME}'…${NC}\n"

"${FLY_CMD}" apps destroy "${APP_NAME}" --yes \
    || die "Destroy command failed. The app may not exist or you may lack permissions."

ok "App '${APP_NAME}' has been destroyed on Fly.io."

# ── Optionally remove local fly.toml ─────────────────────────────────────────
echo ""
read -rp "Remove the local fly.toml file as well? (Y/n): " RM_TOML
if [[ "${RM_TOML,,}" != "n" && "${RM_TOML,,}" != "no" ]]; then
    rm -f fly.toml
    ok "fly.toml removed."
fi

echo ""
info "Run 'make create' to set up a fresh environment."
