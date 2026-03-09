#!/usr/bin/env bash
# fly-setup.sh – interactive wizard that asks configuration questions,
# writes fly.toml, creates the Fly.io app, and optionally deploys it.
#
# Usage: bash scripts/fly-setup.sh   (called automatically by 'make create')

set -euo pipefail

# ── Colour/print helpers ──────────────────────────────────────────────────────
BOLD='\033[1m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

header() { printf "\n${BOLD}${CYAN}━━  %s  ━━${NC}\n\n" "$*"; }
ok()     { printf "${GREEN}✔${NC}  %s\n" "$*"; }
info()   { printf "${CYAN}ℹ${NC}  %s\n" "$*"; }
warn()   { printf "${YELLOW}!${NC}  %s\n" "$*"; }
die()    { printf "${RED}✗  ERROR: %s${NC}\n" "$*" >&2; exit 1; }

# ── Detect fly binary ─────────────────────────────────────────────────────────
FLY_CMD=""
command -v flyctl &>/dev/null && FLY_CMD=flyctl
command -v fly    &>/dev/null && [[ -z "$FLY_CMD" ]] && FLY_CMD=fly
[[ -z "$FLY_CMD" ]] && die "flyctl not found. Run 'make check-prereqs' first."

# ── Ensure authenticated ──────────────────────────────────────────────────────
if ! "${FLY_CMD}" auth whoami &>/dev/null; then
    header "Fly.io Login"
    info "You are not logged in. Starting login flow…"
    "${FLY_CMD}" auth login || die "Login failed. Re-run 'make create' after logging in."
fi

# ── Guard: warn if fly.toml already exists ────────────────────────────────────
if [[ -f fly.toml ]]; then
    warn "fly.toml already exists."
    read -rp "  Overwrite it with a new configuration? (y/N): " OVERWRITE
    [[ "${OVERWRITE,,}" != "y" ]] && { echo "Aborted — existing fly.toml kept."; exit 0; }
fi

header "🚀  Fly.io Streamlit Deployment Wizard"
info "Answer the questions below to configure your Fly.io environment."
info "Press Enter to accept the default shown in brackets."
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Q1 — App name
# ─────────────────────────────────────────────────────────────────────────────
while true; do
    read -rp "$(printf "${BOLD}[1/5] App name${NC} (globally unique, e.g. quant-app-yourname): ")" APP_NAME
    APP_NAME="${APP_NAME// /-}"   # replace spaces with hyphens
    APP_NAME="${APP_NAME,,}"      # lowercase
    [[ -n "$APP_NAME" ]] && break
    warn "App name cannot be empty."
done

# ─────────────────────────────────────────────────────────────────────────────
# Q2 — Organisation
# ─────────────────────────────────────────────────────────────────────────────
echo ""
info "Fetching your Fly.io organisations…"
ORGS=$("${FLY_CMD}" orgs list 2>/dev/null || echo "")
if [[ -n "$ORGS" ]]; then
    echo ""
    echo "$ORGS"
    echo ""
fi
read -rp "$(printf "${BOLD}[2/5] Organisation slug${NC} [personal]: ")" ORG
ORG="${ORG:-personal}"

# ─────────────────────────────────────────────────────────────────────────────
# Q3 — Region
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "  Common regions:"
echo "    ams  Amsterdam    cdg  Paris        fra  Frankfurt"
echo "    iad  Virginia*    lhr  London       nrt  Tokyo"
echo "    ord  Chicago      sea  Seattle      sin  Singapore"
echo "    syd  Sydney       yyz  Toronto      (* default)"
echo ""
read -rp "$(printf "${BOLD}[3/5] Primary region${NC} [iad]: ")" REGION
REGION="${REGION:-iad}"

# ─────────────────────────────────────────────────────────────────────────────
# Q4 — VM memory
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "  VM memory options:"
echo "    256   MB  – free-tier eligible, minimal"
echo "    512   MB  – recommended for Streamlit  (* default)"
echo "    1024  MB  – for heavier data processing"
echo ""
read -rp "$(printf "${BOLD}[4/5] VM memory in MB${NC} [512]: ")" MEMORY
MEMORY="${MEMORY:-512}"
# Validate
[[ "$MEMORY" =~ ^[0-9]+$ ]] || { warn "Memory must be a number. Using 512."; MEMORY=512; }

# ─────────────────────────────────────────────────────────────────────────────
# Q5 — Auto-stop idle machines
# ─────────────────────────────────────────────────────────────────────────────
echo ""
info "Auto-stop: Fly.io can automatically stop VMs when idle and restart them on"
info "           the next request. This saves cost but adds a ~2 s cold-start delay."
echo ""
read -rp "$(printf "${BOLD}[5/5] Auto-stop idle machines?${NC} [Y/n]: ")" AUTO_STOP_INPUT
AUTO_STOP="true"
[[ "${AUTO_STOP_INPUT,,}" == "n" || "${AUTO_STOP_INPUT,,}" == "no" ]] && AUTO_STOP="false"

# ── Summary ───────────────────────────────────────────────────────────────────
header "Configuration Summary"
printf "  %-22s ${BOLD}%s${NC}\n" "App name:"     "$APP_NAME"
printf "  %-22s %s\n"             "Organisation:" "$ORG"
printf "  %-22s %s\n"             "Region:"       "$REGION"
printf "  %-22s %s\n"             "VM memory:"    "${MEMORY} MB"
printf "  %-22s %s\n"             "Auto-stop:"    "$AUTO_STOP"
echo ""
read -rp "Proceed with this configuration? (Y/n): " CONFIRM
[[ "${CONFIRM,,}" == "n" || "${CONFIRM,,}" == "no" ]] && { echo "Aborted."; exit 0; }

# ── Write fly.toml ────────────────────────────────────────────────────────────
header "Writing fly.toml"

cat > fly.toml <<TOML
# fly.toml – generated by scripts/fly-setup.sh on $(date -u '+%Y-%m-%d %H:%M UTC')
# Edit manually or regenerate with: make create
# Reference: https://fly.io/docs/reference/configuration/

app            = "${APP_NAME}"
primary_region = "${REGION}"

[build]

[env]
  PORT = "8501"

[http_service]
  internal_port        = 8501
  force_https          = true
  auto_stop_machines   = ${AUTO_STOP}
  auto_start_machines  = true
  min_machines_running = 0
  processes            = ["app"]

  [[http_service.checks]]
    grace_period = "30s"
    interval     = "15s"
    method       = "GET"
    path         = "/_stcore/health"
    timeout      = "10s"

[[vm]]
  memory   = "${MEMORY}mb"
  cpu_kind = "shared"
  cpus     = 1
TOML

ok "fly.toml written."

# ── Create app on Fly.io ──────────────────────────────────────────────────────
header "Creating Fly.io App"

if "${FLY_CMD}" apps list 2>/dev/null | grep -qE "^${APP_NAME}[[:space:]]"; then
    warn "App '${APP_NAME}' already exists on your account — skipping creation."
else
    "${FLY_CMD}" apps create "${APP_NAME}" --org "${ORG}" \
        || die "Failed to create app '${APP_NAME}'. The name may already be taken by another user."
    ok "App '${APP_NAME}' created on Fly.io."
fi

# ── Optional deployment ───────────────────────────────────────────────────────
echo ""
read -rp "Deploy the app to Fly.io now? (Y/n): " DO_DEPLOY
if [[ "${DO_DEPLOY,,}" != "n" && "${DO_DEPLOY,,}" != "no" ]]; then
    header "Deploying"
    info "Building image remotely on Fly.io (no local Docker required)…"
    "${FLY_CMD}" deploy --remote-only
    echo ""
    ok "Deployment complete!"
    info "App URL : https://${APP_NAME}.fly.dev"
    info "Status  : make status"
    info "Logs    : make logs"
    info "Open    : make open"
else
    info "Deployment skipped. Run 'make deploy' whenever you are ready."
fi

echo ""
ok "Setup complete. Run 'make help' to see all available management commands."
