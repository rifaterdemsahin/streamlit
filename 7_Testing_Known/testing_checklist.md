# 🧪 Testing Checklist — Validation Against OKRs

> Validates all objectives defined in [`1_Real_Unknown/real.md`](../1_Real_Unknown/real.md)

▶️ [Watch: How to Write Effective Test Plans](https://www.youtube.com/results?search_query=test+plan+checklist+software+testing)

---

## O1 — Background Resource Creation

| # | Key Result | Status | Notes |
|---|-----------|--------|-------|
| KR1.1 | `fly apps create` succeeds without portal intervention | ⬜ | |
| KR1.2 | Remote Docker build completes | ⬜ | |
| KR1.3 | App reachable within 5 min | ⬜ | |
| KR1.4 | `fly.toml` written correctly | ⬜ | |

## O2 — Background Resource Destruction

| # | Key Result | Status | Notes |
|---|-----------|--------|-------|
| KR2.1 | All VMs stopped and removed | ⬜ | |
| KR2.2 | All volumes deleted | ⬜ | |
| KR2.3 | TLS certificates revoked | ⬜ | |
| KR2.4 | Secrets purged | ⬜ | |
| KR2.5 | Typed confirmation prevents accident | ⬜ | |

## O3 — Cost Effectively Zero

| # | Key Result | Status | Notes |
|---|-----------|--------|-------|
| KR3.1 | `auto_stop_machines = true` | ⬜ | |
| KR3.2 | `min_machines_running = 0` | ⬜ | |
| KR3.3 | Cold-start < 5 s | ⬜ | |

## O4 — App Delivers Value

| # | Key Result | Status | Notes |
|---|-----------|--------|-------|
| KR4.1 | Sample data loads offline | ⬜ | |
| KR4.2 | Yahoo Finance works from Fly.io | ⬜ | |
| KR4.3 | Charts render without JS errors | ⬜ | |
| KR4.4 | CSV 10k rows < 3 s | ⬜ | |

## O5 — CI/CD

| # | Key Result | Status | Notes |
|---|-----------|--------|-------|
| KR5.1 | Actions triggers on push to main | ⬜ | |
| KR5.2 | Deploy completes < 5 min | ⬜ | |
| KR5.3 | Failures surface in Actions UI | ⬜ | |
| KR5.4 | Only `FLY_API_TOKEN` needed | ⬜ | |

## GitHub Pages

| Check | Status | Notes |
|-------|--------|-------|
| `https://rifaterdemsahin.github.io/streamlit/` live | ⬜ | |
| Navigation menu responsive | ⬜ | |
| Debug mode cookie toggle | ⬜ | |
| Markdown renderer accessible | ⬜ | |
| All 7 folders linked | ⬜ | |

---

*Validates: [1_Real_Unknown/real.md](../1_Real_Unknown/real.md)*
