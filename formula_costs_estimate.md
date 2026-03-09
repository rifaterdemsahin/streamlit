# Cost Estimate — Streamlit Quantitative Analysis PoC

Scenario: **10 page views via GitHub Pages**, each triggering a cold-start on Fly.io and a
Yahoo Finance data fetch.

---

## 1. GitHub Pages

| Item | Cost |
|------|------|
| Hosting static `index.html` | **$0.00** — GitHub Pages is free for public repos |
| Bandwidth for 10 page loads (~20 KB HTML/CSS per load) | **$0.00** — included in free tier |

**GitHub Pages subtotal: $0.00**

---

## 2. Fly.io — Compute (Fly Machine)

Config from `fly.toml`:
- VM size: 1 shared CPU, 512 MB RAM
- `auto_stop_machines = true`, `min_machines_running = 0` (scale-to-zero)

### Active compute time per visit

| Phase | Duration estimate |
|-------|-------------------|
| Cold-start (wake VM) | ~5 s |
| Page load + WebSocket handshake | ~5 s |
| Yahoo Finance fetch + chart render | ~5 s |
| User interaction / idle before auto-stop | ~60 s |
| **Total per visit** | **~75 s ≈ 0.021 hrs** |

### Fly.io shared-CPU pricing (as of 2026)

| Resource | Rate |
|----------|------|
| shared-cpu-1x, 512 MB RAM | ~$0.0000022 / s ($0.0000022 × 3600 = ~$0.0079 / hr) |

### Compute cost for 10 visits

```
10 visits × 75 s = 750 s active
750 s × $0.0000022/s = $0.00165
```

Fly.io free allowance: **160 GB-hrs RAM + 2,340 CPU-hrs / month** for free-tier orgs.
750 CPU-seconds = **0.21 CPU-hrs** — well within the free allowance.

**Fly.io compute subtotal: $0.00 (free tier covers it)**

---

## 3. Fly.io — Egress / Bandwidth

Each visit transfers approximately:

| Asset | Size |
|-------|------|
| Streamlit initial HTML + JS bundle | ~2 MB |
| WebSocket frames (UI updates) | ~50 KB |
| Plotly chart data (JSON) | ~100 KB |
| Yahoo Finance OHLCV data (3 tickers, 1 yr) | ~150 KB |
| **Per visit total** | **~2.3 MB** |

```
10 visits × 2.3 MB = 23 MB egress
```

Fly.io free egress allowance: **100 GB / month**.
23 MB is negligible — **$0.00**.

**Fly.io bandwidth subtotal: $0.00 (free tier covers it)**

---

## 4. Yahoo Finance API

`yfinance` uses Yahoo Finance's unofficial public API — no API key, no charge.

**Yahoo Finance subtotal: $0.00**

---

## 5. GitHub Actions (CI/CD)

Each push to `main` triggers `deploy.yml` (~3–5 min build).

| Plan | Free minutes / month |
|------|---------------------|
| GitHub Free (public repo) | **Unlimited** |

**GitHub Actions subtotal: $0.00**

---

## 6. Summary

| Component | 10-view cost | Notes |
|-----------|-------------|-------|
| GitHub Pages | $0.00 | Always free for public repos |
| Fly.io compute | $0.00 | 0.21 CPU-hrs vs 2,340 free |
| Fly.io egress | $0.00 | 23 MB vs 100 GB free |
| Yahoo Finance API | $0.00 | Unofficial public endpoint |
| GitHub Actions | $0.00 | Unlimited for public repos |
| **Total** | **$0.00** | |

---

## 7. Scaling — when does it start to cost money?

| Monthly active users | Estimated Fly.io bill |
|----------------------|-----------------------|
| 10 (this PoC) | $0.00 |
| 100 | $0.00 (still within free tier) |
| ~1,000 | ~$0.50–$1.00 |
| ~10,000 | ~$5–$10 |

The auto-stop/auto-start design (`min_machines_running = 0`) keeps costs near
zero at any low-traffic scale.  Costs only grow meaningfully if the VM stays
active continuously (i.e., sustained high traffic preventing auto-stop).

---

## 8. Key assumption

> If the Fly.io app is **destroyed** after the demo (`make destroy`), the
> monthly bill is exactly **$0.00** regardless of how many views occurred,
> because Fly.io only bills for resources that exist.
