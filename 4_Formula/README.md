# 4️⃣ Formula — The "Recipe"

> **Stage 4 of 7:** The blueprint that guides the build.

This folder contains **step-by-step guides**, **research notes**, and the **logic behind the build**.

---

## 📋 Contents

| File | Purpose |
|------|---------|
| `formula_architecture.md` | System architecture — why every file exists and how they relate |

---

## 🔬 Purpose

This folder answers:

1. **How does the system work?** (architecture)
2. **Why were these decisions made?** (research notes)
3. **What are the step-by-step build instructions?**

---

## 🤖 AI Stack — Containerised Setup

```yaml
# Qdrant vector database
services:
  qdrant:
    image: qdrant/qdrant
    ports: ["6333:6333"]
    volumes: ["./qdrant_storage:/qdrant/storage"]

  ollama:
    image: ollama/ollama
    # Model: nomic-embed-text (4096 dimensions)
```

---

## ✅ Testing Checklist

▶️ [Watch: Software Architecture Fundamentals](https://www.youtube.com/results?search_query=software+architecture+fundamentals+tutorial)

- [ ] Architecture diagram is current
- [ ] Every component's purpose is documented
- [ ] Data flow diagrams are accurate
- [ ] Containerised AI stack setup is tested
- [ ] Step-by-step guide validated end-to-end

---

*Part of the [Project Self-Learning System](../README.md) — Unknown → Proven*
