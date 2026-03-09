# 5️⃣ Symbols — The "Reality"

> **Stage 5 of 7:** The actual code that makes it real.

This folder contains the **core source code** and **implementation** for the project.

---

## 📋 Contents

| File | Purpose |
|------|---------|
| `app.py` | Main Streamlit application (UI, sidebar, tabs) |
| `utils.py` | Pure helper functions (returns, rolling avg, z-scores) |
| `requirements.txt` | Python runtime dependencies |
| `Dockerfile` | Multi-stage container build |
| `scripts/` | Operational shell scripts |

---

## 💻 Purpose

This folder contains the working implementation:

1. **Source code** — all Python application files
2. **Dependencies** — package requirements
3. **Container config** — Dockerfile for deployment
4. **Scripts** — automation for create/destroy lifecycle

---

## 🚀 Quick Start

```bash
pip install -r requirements.txt
streamlit run app.py
```

---

## ✅ Testing Checklist

▶️ [Watch: Streamlit Tutorial for Data Science](https://www.youtube.com/results?search_query=streamlit+tutorial+data+science)

- [ ] `app.py` runs without errors locally
- [ ] All four tabs (Data, Stats, Charts, Insights) render
- [ ] `utils.py` functions have unit test coverage
- [ ] Docker image builds successfully
- [ ] Scripts exit with 0 on happy path

---

*Part of the [Project Self-Learning System](../README.md) — Unknown → Proven*
