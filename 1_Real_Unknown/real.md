# Real-World OKRs — Streamlit PoC on Fly.io

This document captures the concrete, measurable objectives and key results that
define success for this proof-of-concept.  It focuses on the **Fly.io
resource lifecycle** (create in the background, operate, destroy in the
background) and on the value the app delivers to end-users.

---

## Context

The project proves that a data-science web application can be:

1. **Built** from source code in a single `make create` command.
2. **Deployed** to a global cloud (Fly.io) with zero local Docker requirement.
3. **Operated** with auto-stop / auto-start to eliminate idle costs.
4. **Destroyed** completely — every resource — with a single `make destroy` command.

The background create/destroy approach means engineers and analysts can spin up
a fresh environment for a demo, then tear it down afterwards with no leftover
cloud costs.

---

## Objectives and Key Results

### O1 — Background resource creation works reliably

> Engineers can run `make create`, answer five questions, and walk away while
> Fly.io provisions and deploys the app remotely.

| # | Key Result | Measure of Success |
|---|-----------|-------------------|
| KR1.1 | `fly apps create` succeeds without manual portal intervention | Zero portal visits required |
| KR1.2 | Remote Docker build on Fly.io completes without local daemon | `fly deploy --remote-only` exits 0 |
| KR1.3 | App is reachable at `https://<name>.fly.dev` within 5 min of `make create` | p95 provisioning time < 5 min |
| KR1.4 | `fly.toml` is written correctly (port 8501, health-check path, memory) | Validated by `make check-prereqs` |

---

### O2 — Background resource destruction is complete and safe

> Running `make destroy` removes **all** Fly.io resources with no orphans and no
> accidental deletions.

| # | Key Result | Measure of Success |
|---|-----------|-------------------|
| KR2.1 | All VMs are stopped and removed | `fly machines list` returns empty |
| KR2.2 | All volumes are deleted | `fly volumes list` returns empty |
| KR2.3 | All TLS certificates are revoked | `fly certs list` returns empty |
| KR2.4 | All secrets are purged | `fly secrets list` returns empty |
| KR2.5 | Typed-name confirmation prevents accidental deletion | Wrong input = clean abort, no API calls |
| KR2.6 | Local `fly.toml` is optionally removed | User prompted; default = remove |

---

### O3 — Cost is effectively zero when idle

> The auto-stop / auto-start feature ensures VMs stop when no requests are
> received, so the PoC incurs near-zero cost outside of active demos.

| # | Key Result | Measure of Success |
|---|-----------|-------------------|
| KR3.1 | `auto_stop_machines = true` in `fly.toml` | Confirmed in generated config |
| KR3.2 | `min_machines_running = 0` | Fly.io scales to zero when idle |
| KR3.3 | VM wakes and serves first request within 5 s of cold-start | Measured via browser DevTools |
| KR3.4 | Monthly Fly.io bill < $1 for a PoC with ≤ 100 daily active users | Estimated from Fly.io pricing |

---

### O4 — App delivers real analytical value during the demo

> While the infrastructure story is the focus of this PoC, the Streamlit app
> must work correctly and demonstrate useful quant-finance capabilities.

| # | Key Result | Measure of Success |
|---|-----------|-------------------|
| KR4.1 | Sample data loads without network access | Works on first open, no API key needed |
| KR4.2 | Yahoo Finance fetch returns data for AAPL, MSFT, GOOGL | Succeeds from Fly.io region |
| KR4.3 | Correlation heatmap, returns chart, z-score chart render without errors | Zero JS console errors |
| KR4.4 | CSV upload processes a 10k-row file in < 3 s | Measured in-browser |

---

### O5 — CI/CD pipeline keeps the deployed app up to date

> Every push to `main` automatically re-deploys the app on Fly.io with no
> manual steps.

| # | Key Result | Measure of Success |
|---|-----------|-------------------|
| KR5.1 | GitHub Actions workflow runs on every push to `main` | `deploy.yml` triggers confirmed |
| KR5.2 | Deployment completes within 5 minutes | GitHub Actions job duration |
| KR5.3 | Failed deployments surface in GitHub Actions UI | Red check in PR / commit status |
| KR5.4 | `FLY_API_TOKEN` secret is the only credential needed | Zero hardcoded tokens in the repo |

---

## Definition of Done

This PoC is considered **complete** when:

- [ ] `make create` → app live on Fly.io in < 5 minutes.
- [ ] App serves all four tabs (Data, Stats, Charts, Insights) without errors.
- [ ] `make destroy` → zero resources visible in `fly apps list`.
- [ ] CI pipeline automatically re-deploys on push to `main`.
- [ ] Documentation (README, copilot.md, real.md, formula_architecture.md) is up to date.
