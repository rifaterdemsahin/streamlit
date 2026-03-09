# 7️⃣ Testing Known — The "Proof"

> **Stage 7 of 7:** Validation that closes the loop.

This folder contains **validation results**, **testing checklists**, and **outcome confirmation** against the objectives defined in `1_Real_Unknown`.

---

## 📋 Contents

| File | Purpose |
|------|---------|
| `testing_checklist.md` | Master checklist validating all OKRs |

---

## 🧪 Purpose

This stage proves that what was _unknown_ in Stage 1 is now _known_:

1. **Validate each OKR** from `1_Real_Unknown/real.md`
2. **Document test results** with timestamps
3. **Confirm deployment** is live and functioning
4. **Sign off** the Definition of Done

---

## ✅ Master Testing Checklist

▶️ [Watch: Software Testing Best Practices](https://www.youtube.com/results?search_query=software+testing+best+practices)

### Infrastructure Tests
- [ ] `make create` completes in < 5 minutes
- [ ] App is reachable at `https://<app>.fly.dev`
- [ ] `make destroy` removes all resources
- [ ] CI pipeline auto-deploys on push to `main`

### Application Tests
- [ ] All four tabs render without errors
- [ ] Sample data loads without network access
- [ ] Yahoo Finance fetch returns data
- [ ] CSV upload processes correctly

### GitHub Pages Tests
- [ ] `https://rifaterdemsahin.github.io/streamlit/` is live
- [ ] Navigation menu works on mobile
- [ ] Debug mode toggles correctly
- [ ] Markdown renderer loads all `.md` files

---

*Part of the [Project Self-Learning System](../README.md) — Unknown → Proven*
