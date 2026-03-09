# Kilo Code AI Instructions — Streamlit Quantitative Analysis PoC

This file provides context so Kilo Code can give accurate, on-point suggestions for this repository.

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

## Project Overview

This is a **proof-of-concept (PoC)** Streamlit application for quantitative
financial analysis. Deployed on [Fly.io](https://fly.io) with a full
create/operate/destroy lifecycle managed via Makefile and shell scripts.

| Layer | Technology |
|-------|-----------|
| Web framework | [Streamlit](https://streamlit.io) ≥ 1.32 |
| Data processing | pandas, NumPy |
| Visualisation | Plotly |
| Market data | yfinance |
| Container | Docker (multi-stage, non-root) |
| Cloud host | Fly.io (Machines API, auto-stop enabled) |
| CI/CD | GitHub Actions → `flyctl deploy --remote-only` |
| Pages | GitHub Pages at `https://rifaterdemsahin.github.io/streamlit/` |

---

## Coding Conventions

* Python 3.11+, type annotations on all public functions.
* Helper functions live in `5_Symbols/utils.py`; UI logic stays in `5_Symbols/app.py`.
* Shell scripts use `set -euo pipefail` and print colour-coded status lines.
* Fly.io `internal_port` must be **8501** (Streamlit default).

---

## Kilo Code-Specific Guidance

* Follow the 7-stage framework when navigating the codebase.
* Place new source code in `5_Symbols/` and architecture docs in `4_Formula/`.
* Document errors and workarounds in `6_Semblance/`.
* Validate all changes against the OKRs in `1_Real_Unknown/real.md`.
* Every significant change should include a git commit and push.
