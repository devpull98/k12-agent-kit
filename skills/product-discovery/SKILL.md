---
name: product-discovery
description: Tìm hiểu và phân tích codebase/product mới trước khi bắt tay vào work. Use when onboarding vào project mới, cần hiểu 1 module cụ thể, hoặc trước khi viết spec/design.
keywords: [product discovery, codebase, explore, tìm hiểu, onboarding, module, architecture, how does it work]
not_for: [debug lỗi cụ thể, viết code, review PR]
---

# Skill: Product Discovery / Codebase Exploration

**Trigger:** User wants to understand a new product, feature area, or module before starting work.

**Duration:** 15 min (quick scan) to 2 hours (deep dive)

**Roles:** All (Tech Lead, Dev, Tester, DevOps)

---

## When to Use

- ✅ Starting on a new project / unfamiliar codebase
- ✅ Before writing spec (need to understand current state)
- ✅ Before design (need architectural context)
- ✅ Onboarding new team member
- ✅ Learning how a feature works (trophy, ranking, payment, etc.)
- ❌ NOT for code review (use /code-review)
- ❌ NOT for debugging (use /debugging)

---

## Quick Scan (15 min)

**Goal:** 30,000-foot overview. What is this product?

**Steps:**

1. **Name & Purpose** — Read README / main docs
   - What does this product do?
   - Who uses it? (teachers, students, admins?)
   - Key metrics? (>30k CCU, real-time, batch processing?)

2. **Tech Stack** — Check pom.xml / package.json / Dockerfile
   - Language, framework, databases
   - Third-party services (Kafka, Redis, MongoDB?)
   - External integrations?

3. **Module Map** — Scan src/ directory structure
   - How many modules? (monolith vs microservices)
   - Entry points? (Controller, API, CLI)
   - Dependencies? (which module depends on which)

4. **Data Flow** — Trace one request end-to-end
   - API endpoint → Service → Repository → Database
   - Any async flows? (Kafka, jobs, webhooks)

5. **Deployment** — How does it run?
   - Docker/K8s? Standalone?
   - Config files? (application.yml, env vars)
   - CI/CD? (GitHub Actions, Jenkins)

**Output:** 1-page summary (text or diagram)

---

## Deep Dive (1-2 hours)

**Goal:** Detailed architecture. Ready to implement features.

**Steps:**

1. **Architecture** — Create system diagram
   - Layers (Controller → Service → Repository)
   - External systems (APIs, queues, caches)
   - Data stores (SQL, NoSQL, Redis)

2. **Feature Map** — List all features + ownership
   - Which module owns what?
   - Dependencies between features?
   - High-risk areas (performance, concurrency)?

3. **Key Patterns** — Identify recurring designs
   - How is pagination handled? (Pageable vs Slice)
   - Error handling? (exceptions, logs, monitoring)
   - Testing strategy? (unit, integration, e2e)
   - Caching? (Redis, Aerospike, where?)

4. **Data Models** — Understand entities
   - Core entities (User, Session, Profile, etc.)
   - Relationships (1:1, 1:N, M:N)
   - Schema evolution (migrations, backward compat)

5. **Performance Baseline** — Check constraints
   - Concurrency target (30k CCU?)
   - Latency SLAs? (<100ms, <1s, <10s?)
   - Throughput needs? (tps, msgs/sec)
   - Bottlenecks? (known issues, monitoring)

6. **Testing & QC** — Understand test strategy
   - Unit test patterns
   - Mock scope (never mock internal services)
   - Test data setup (fixtures, factories)

7. **Monitoring & Logs** — What to watch
   - Key metrics (latency, error rate, throughput)
   - Log aggregation (ELK, CloudWatch)
   - Alerting rules

**Output:** Architecture doc + tech design template (ready for spec)

---

## Role-Specific Focus

### Tech Lead / Product Owner
- **Prioritize:** Business features, user flows, priorities
- **Document:** Feature list, roadmap, risks
- **Check:** Architecture decisions, trade-offs, constraints
- **Ask:** Why does this design exist? Is it still valid?

### Developer
- **Prioritize:** Code structure, patterns, testing
- **Document:** Module map, API contracts, data models
- **Check:** Where do I hook in? What's the pattern for X?
- **Ask:** Where are the N+1 queries? Batch vs streaming?

### Tester / QC
- **Prioritize:** User flows, acceptance criteria, edge cases
- **Document:** User journeys, happy path, error cases
- **Check:** Where are failures caught? How to reproduce bugs?
- **Ask:** What are the test scenarios? Who owns QA?

### DevOps / Infrastructure
- **Prioritize:** Deployment, config, monitoring, scaling
- **Document:** Deployment flow, config management, secrets
- **Check:** How does it scale? Resource limits? Auto-scaling?
- **Ask:** What's the SLA? What alerts should we set?

---

## Questions Checklist

### Architecture
- [ ] Monolith or microservices?
- [ ] What's the main request path?
- [ ] Where is data persisted? (SQL, NoSQL, cache)
- [ ] Are there async flows? (Kafka, queues, scheduled jobs)
- [ ] External dependencies? (3rd-party APIs, payments)

### Performance
- [ ] What's the concurrency target?
- [ ] Known bottlenecks?
- [ ] Caching strategy?
- [ ] Batch operations vs real-time?
- [ ] Monitoring tools? (metrics, logs, traces)

### Testing
- [ ] Test framework? (JUnit, Pytest, RSpec)
- [ ] Test data strategy?
- [ ] Mock scope? (never mock internal)
- [ ] Coverage baseline?

### Development
- [ ] Branch strategy? (master, develop, feature branches)
- [ ] Code review process?
- [ ] Deployment frequency? (hourly, daily, weekly)
- [ ] Rollback plan?

---

## Output Artifacts

**Quick Scan:**
```
# Product: <name>
- Purpose: <1 sentence>
- Users: <who>
- Tech: <stack>
- Modules: <count> (list top 5)
- Key Metrics: <CCU, latency, throughput>
```

**Deep Dive:**
```
docs/architecture/
├── system-overview.md           (layers, external systems)
├── feature-map.md               (features, ownership, dependencies)
├── data-models.md               (entities, relationships)
├── performance-baseline.md      (SLAs, bottlenecks, metrics)
└── <system>-architecture.md     (detailed design)
```

---

## Related Skills

- [spec-driven-development](../spec-driven-development/SKILL.md) — After discovery, write BDD spec
- [tech-docs](../tech-docs/SKILL.md) — After discovery, write detailed design
- [debugging](../debugging/SKILL.md) — When you find bugs during exploration
- [performance-optimization](../performance-optimization/SKILL.md) — When you spot perf risks

---

**Last Updated:** 2026-07-04 | **Used by:** All roles before starting feature work
