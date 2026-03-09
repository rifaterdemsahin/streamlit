# Streamlit — Quantitative Analysis PoC

🌐 **Live app (GitHub Pages):** <https://rifaterdemsahin.github.io/streamlit/>

A proof-of-concept Streamlit application using pandas, Plotly, and yfinance for
quantitative financial analysis. Deployable to [Fly.io](https://fly.io) with a
single interactive setup command.

---

## Running locally

```bash
pip install -r requirements.txt
streamlit run app.py
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

## Project structure

```
streamlit/
├── app.py                 Main Streamlit application
├── utils.py               Helper functions (returns, z-scores, rolling avg, …)
├── requirements.txt       Python dependencies
├── Dockerfile             Container image definition (used by Fly.io)
├── fly.toml.example       Reference Fly.io configuration (copy of what make create generates)
├── Makefile               Management commands
└── scripts/
    ├── check-prereqs.sh   Prerequisite checker (flyctl, Docker, auth)
    ├── fly-setup.sh       Interactive creation/deployment wizard
    └── fly-destroy.sh     Environment teardown with confirmation
```
