#!/usr/bin/env bash
# check-prereqs.sh – verify that every tool needed to manage the Fly.io
# environment is present and that the user is authenticated.
#
# Exit codes:
#   0 – all prerequisites satisfied
#   1 – one or more prerequisites are missing
#
# Usage: bash scripts/check-prereqs.sh   (called automatically by the Makefile)

set -euo pipefail

# ── Colour helpers ────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

ok()   { printf "${GREEN}✔${NC}  %s\n" "$*"; }
fail() { printf "${RED}✗${NC}  %s\n" "$*"; }
warn() { printf "${YELLOW}!${NC}  %s\n" "$*"; }
info() { printf "${CYAN}ℹ${NC}  %s\n" "$*"; }

MISSING=0

printf "\n${BOLD}Checking prerequisites…${NC}\n\n"

# ── 1. flyctl ─────────────────────────────────────────────────────────────────
FLY_CMD=""
if   command -v flyctl &>/dev/null; then FLY_CMD=flyctl
elif command -v fly    &>/dev/null; then FLY_CMD=fly
fi

if [[ -z "$FLY_CMD" ]]; then
    fail "flyctl is not installed."
    echo "     Install on macOS/Linux:"
    echo "       curl -L https://fly.io/install.sh | sh"
    echo "     Install via Homebrew:"
    echo "       brew install flyctl"
    echo "     Or download from: https://fly.io/docs/hands-on/install-flyctl/"
    MISSING=1
else
    FLY_VER=$("${FLY_CMD}" version 2>/dev/null | head -1 || echo "version unknown")
    ok "flyctl is installed  (${FLY_VER})"

    # ── 2. Fly.io authentication ──────────────────────────────────────────────
    if ! "${FLY_CMD}" auth whoami &>/dev/null; then
        warn "Not logged in to Fly.io."
        echo "     Log in with:  flyctl auth login"
        MISSING=1
    else
        FLY_USER=$("${FLY_CMD}" auth whoami 2>/dev/null || echo "unknown")
        ok "Authenticated with Fly.io as ${FLY_USER}"
    fi
fi

# ── 3. Docker ─────────────────────────────────────────────────────────────────
if command -v docker &>/dev/null; then
    DOCKER_VER=$(docker version --format '{{.Client.Version}}' 2>/dev/null || echo "version unknown")
    ok "Docker is installed  (${DOCKER_VER})"

    if ! docker info &>/dev/null 2>&1; then
        warn "Docker daemon is not running."
        warn "  'fly deploy --remote-only' (used by 'make deploy') builds in the"
        warn "  Fly.io cloud, so a local daemon is NOT required for deployment."
        warn "  Start Docker Desktop if you want to build images locally."
    fi
else
    warn "Docker CLI is not installed."
    info "  'make deploy' uses 'fly deploy --remote-only' and builds in the cloud,"
    info "  so Docker is not strictly required for deployment."
    info "  Install Docker: https://docs.docker.com/get-docker/"
fi

# ── Result ────────────────────────────────────────────────────────────────────
echo ""
if [[ "$MISSING" -ne 0 ]]; then
    printf "${RED}${BOLD}Some required tools are missing. Please install them and try again.${NC}\n\n"
    exit 1
fi

printf "${GREEN}${BOLD}All prerequisites satisfied.${NC}\n\n"
