# Streamlit — Quantitative Analysis PoC

🌐 **Live app (GitHub Pages):** <https://rifaterdemsahin.github.io/streamlit/>

A proof-of-concept Streamlit application using pandas, Plotly, and yfinance for
quantitative financial analysis. Deployable to [Fly.io](https://fly.io) with a
single interactive setup command.

---

## Running locally

```bash
pip install -r 5_Symbols/requirements.txt
streamlit run 5_Symbols/app.py
```

---

## Deploying to Fly.io

### Prerequisites

| Tool | Install |
|------|---------|
| **flyctl** | `curl -L https://fly.io/install.sh \| sh` or `brew install flyctl` |
| **Docker** *(optional)* | <https://docs.docker.com/get-docker/> – only needed for local builds; remote builds work without it |

Verify your setup at any time:

```bash
make check-prereqs
```

### Create a new environment

The interactive wizard asks five questions (app name, organisation, region,
VM memory, auto-stop preference) and then creates the Fly.io app and
optionally deploys it for you:

```bash
make create
```

### Re-deploy after code changes

```bash
make deploy
```

### Destroy the environment

```bash
make destroy
```

You will be asked to type the app name as a confirmation before anything is
deleted. Optionally removes the local `fly.toml` afterwards.

---

## All management commands

```
make help           Show all available commands
make check-prereqs  ① Verify flyctl and Docker are installed and you are logged in
make create         ② Interactively create a new Fly.io environment (asks questions)
make deploy         ③ Build and (re)deploy the app to Fly.io
make destroy        ④ Permanently destroy the Fly.io app and all its resources
make status         Show app status, VM info, and health checks
make logs           Stream live application logs (Ctrl-C to stop)
make open           Open the deployed app in your default browser
make ssh            Open an interactive SSH session on a running VM
make secrets        List app secrets (names only; values are never shown)
make scale          Show current VM count and size settings
```

---

## Project structure — Self-Learning System (Unknown → Proven)

This repository follows a **7-stage learning framework**. Each folder represents one stage of the journey:

| Folder | Stage | Purpose |
|--------|-------|---------|
| [`1_Real_Unknown/`](1_Real_Unknown/README.md) | ❓ The "Why" | Problem definitions, OKRs, core questions |
| [`2_Environment/`](2_Environment/README.md) | 🌍 The "Context" | Roadmaps, constraints, setup guides |
| [`3_Simulation/`](3_Simulation/README.md) | 🎨 The "Vision" | UI mockups, image carousel, flow diagrams |
| [`4_Formula/`](4_Formula/README.md) | 🔬 The "Recipe" | Architecture, step-by-step guides, research |
| [`5_Symbols/`](5_Symbols/README.md) | 💻 The "Reality" | Core source code and implementation |
| [`6_Semblance/`](6_Semblance/README.md) | 🐛 The "Scars" | Error logs, workarounds, lessons learned |
| [`7_Testing_Known/`](7_Testing_Known/README.md) | 🧪 The "Proof" | Validation checklists, outcome confirmation |

### Root files

```
index.html               GitHub Pages entry point (nav, carousel, stage cards, live app iframe)
markdown_renderer.html   In-browser markdown reader (bi-directional linking for all .md files)
nav.json                 Shared navigation data (debug menu, content menu, social links)
aigent.md                Universal AI agent instructions
copilot.md               GitHub Copilot context
gemini.md                Google Gemini context
kilocode.md              Kilo Code context
claude.md                Anthropic Claude context
robots.txt               SEO — search engine crawl rules
sitemap.xml              SEO — page index for GitHub Pages
.env.example             Environment variable template (copy to .env)
Makefile                 Developer commands (create / deploy / destroy / …)
fly.toml.example         Reference Fly.io configuration
```

See [`4_Formula/formula_architecture.md`](4_Formula/formula_architecture.md) for detailed Mermaid
diagrams of the component relationships, request flow, and infrastructure lifecycle.
