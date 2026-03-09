# GitHub Copilot Instructions — Streamlit Quantitative Analysis PoC

This file provides context so GitHub Copilot (and other AI pair-programming
tools) can give accurate, on-point suggestions for this repository.

---

## 📂 Project Structure — Self-Learning System

This repository follows the **7-Stage Self-Learning System** framework: _Unknown → Proven_

| Folder | Stage | Purpose |
|--------|-------|---------|
| `1_Real_Unknown/` | **The "Why"** | Problem definitions, OKRs, core questions |
| `2_Environment/` | **The "Context"** | Roadmaps, constraints, setup guides |
| `3_Simulation/` | **The "Vision"** | UI mockups, image carousel, flow diagrams |
| `4_Formula/` | **The "Recipe"** | Step-by-step guides, architecture, research |
| `5_Symbols/` | **The "Reality"** | Core source code and implementation |
| `6_Semblance/` | **The "Scars"** | Error logs, workarounds, lessons learned |
| `7_Testing_Known/` | **The "Proof"** | Validation against OKRs, testing checklists |

### Root Files
- `index.html` — GitHub Pages entry point with navigation
- `markdown_renderer.html` — renders any `.md` file in the browser
- `aigent.md` — AI agent persona instructions
- `robots.txt`, `sitemap.xml` — SEO configuration
- `.env` — environment variable template

### Navigation
- **Debug Menu** (cookie-gated): links to all 7 stages via `markdown_renderer.html`
- **Content Menu**: links to project pages not related to framework navigation

---

## Project overview

This is a **proof-of-concept (PoC)** Streamlit application for quantitative
financial analysis.  It is deployed on [Fly.io](https://fly.io) and the
infrastructure lifecycle (create → deploy → destroy) is managed through a
Makefile + shell scripts so that cloud resources can be spun up and torn down
on demand.

| Layer | Technology |
|-------|-----------|
| Web framework | [Streamlit](https://streamlit.io) ≥ 1.32 |
| Data processing | pandas, NumPy |
| Visualisation | Plotly |
| Market data | yfinance |
| Container | Docker (multi-stage, non-root) |
| Cloud host | Fly.io (Machines API, auto-stop enabled) |
| CI/CD | GitHub Actions → `flyctl deploy --remote-only` |

---

## Objectives and Key Results (OKRs)

### Objective 1 — Demonstrate a production-grade Streamlit deployment on Fly.io

| # | Key Result | Target |
|---|-----------|--------|
| KR1.1 | App starts successfully after `make create` and is reachable at `https://<app>.fly.dev` | 100 % success on first run |
| KR1.2 | Docker image builds without errors in CI | Zero build failures in `main` branch |
| KR1.3 | Health-check endpoint (`/_stcore/health`) returns 200 within 30 s of cold-start | ≥ 99 % of checks pass |
| KR1.4 | Auto-stop/auto-start cycle completes in < 5 s | p95 cold-start latency |

### Objective 2 — Provide a clean, repeatable create-and-destroy workflow

| # | Key Result | Target |
|---|-----------|--------|
| KR2.1 | `make create` completes end-to-end (prompts → `fly.toml` → app created → deployed) | Zero unhandled errors |
| KR2.2 | `make destroy` removes all Fly.io resources (VMs, volumes, certs, secrets) | Confirmed via `fly apps list` |
| KR2.3 | Re-running `make create` after `make destroy` succeeds cleanly | 100 % idempotent |
| KR2.4 | Scripts complete in < 3 minutes on a standard internet connection | Measured wall-clock time |

### Objective 3 — Deliver useful quantitative analysis features

| # | Key Result | Target |
|---|-----------|--------|
| KR3.1 | Support three data sources: sample data, CSV upload, Yahoo Finance | All three work in the deployed app |
| KR3.2 | Four analysis views rendered without error: Data, Stats, Charts, Insights | Zero runtime exceptions per session |
| KR3.3 | Rolling average, z-scores, period returns, and correlation heatmap are all interactive | Verified manually in each PR |

### Objective 4 — Maintain developer experience and code quality

| # | Key Result | Target |
|---|-----------|--------|
| KR4.1 | `make check-prereqs` gives clear pass/fail for every dependency | Zero ambiguous outputs |
| KR4.2 | Copilot/AI suggestions stay consistent with project conventions | Measured by PR review feedback |
| KR4.3 | All new Python code passes `ruff` / `flake8` linting | Zero lint errors in CI |

---

## Key files and their purpose

```
app.py               – Main Streamlit application (UI, sidebar, tabs)
utils.py             – Pure helper functions (returns, rolling avg, z-scores)
requirements.txt     – Python runtime dependencies
Dockerfile           – Multi-stage container build (builder + slim runtime)
fly.toml             – Active Fly.io configuration (gitignored when customised)
fly.toml.example     – Reference / template Fly.io config
Makefile             – Developer commands (create / deploy / destroy / logs …)
scripts/
  check-prereqs.sh   – Validates flyctl, Docker, and Fly.io auth
  fly-setup.sh       – Interactive wizard: configure + create + deploy
  fly-destroy.sh     – Teardown with typed-name confirmation
.github/workflows/
  deploy.yml         – CI: push to main → flyctl deploy --remote-only
```

---

## Coding conventions

* Python 3.11+, type annotations on all public functions.
* Helper functions live in `utils.py`; UI logic stays in `app.py`.
* Shell scripts use `set -euo pipefail` and print colour-coded status lines.
* Fly.io `internal_port` must be **8501** (Streamlit default).
* Use `fly deploy --remote-only` — no local Docker daemon required.
* Never hard-code app names; read them from `fly.toml` at runtime.

---

## Common Copilot task prompts

* *"Add a new analysis tab to app.py"* → follow the existing `tab_*` pattern.
* *"Add a new utility function"* → add to `utils.py` with a Google-style docstring.
* *"Update the Fly.io config"* → edit `fly.toml.example` and `fly-setup.sh` together.
* *"Write a shell helper"* → match the `ok / info / warn / die` colour pattern.
