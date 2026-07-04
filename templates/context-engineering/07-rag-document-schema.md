# RAG Document Schema

<!--
Template cho chunking và metadata khi build knowledge base cho agent.

Tại sao cần schema chuẩn:
- Chunk không có metadata → retrieval trả về text mồ côi, agent không biết context
- Chunk quá lớn → dilute relevance score
- Chunk quá nhỏ → mất context liên câu
- Schema chuẩn → retrieval pipeline có thể filter, rank, cite đúng nguồn

Áp dụng khi: build vector store từ docs nội bộ (spec, wiki, runbook, codebase).
Không áp dụng cho: real-time tool call, web search.
-->

---

## Document Metadata Schema

```yaml
# Metadata gắn vào mỗi document trước khi chunk
document_id: "<type>/<domain>/<slug>"   # ví dụ: spec/lms/UC-LMS-001
title: "<tiêu đề đầy đủ>"
doc_type: spec | bdd | tech-design | runbook | adr | api-contract | wiki
domain: lms | club | teacher | products | global
stack: spring | laravel | golang | nodejs | all
audience: dev | tester | techlead | all
version: "1.0"
last_updated: "YYYY-MM-DD"
status: draft | approved | deprecated
tags:
  - <tag-1>
  - <tag-2>
source_path: "docs/specs/bdd/UC-LMS-001.feature"
```

---

## Chunking Strategy theo doc_type

| doc_type | Chunk by | Overlap | Max tokens/chunk |
|----------|---------|---------|-----------------|
| bdd | 1 Scenario = 1 chunk | 0 | 300 |
| spec | 1 Section (##) = 1 chunk | 50 token | 500 |
| tech-design | 1 Component/Layer = 1 chunk | 50 token | 600 |
| api-contract | 1 Endpoint = 1 chunk | 0 | 400 |
| runbook | 1 Step group = 1 chunk | 100 token | 400 |
| adr | Toàn bộ = 1 chunk | - | 800 |
| wiki | 1 Sub-section = 1 chunk | 50 token | 500 |

---

## Chunk Metadata Schema

```yaml
# Metadata gắn vào từng chunk (inherit từ document + chunk-specific)
chunk_id: "<document_id>#<section-slug>"
document_id: "<document_id>"    # reference về document gốc
section_title: "<tiêu đề section>"
chunk_index: 0                  # thứ tự trong document
chunk_type: scenario | section | endpoint | step | full
# Inherit từ document:
doc_type: ~
domain: ~
stack: ~
audience: ~
status: ~
tags: ~
```

---

## Template: BDD Scenario Chunk

```markdown
<!-- chunk_id: spec/lms/UC-LMS-001#SC1 -->
<!-- doc_type: bdd | domain: lms | status: approved -->

**Use Case:** UC-LMS-001 — Học sinh xem điểm
**Scenario:** SC1 — Happy path: điểm hiển thị đúng

Given học sinh đã đăng nhập
When học sinh mở trang điểm của môn Toán
Then hiển thị điểm số và nhận xét của giáo viên
And điểm được ghi audit log với timestamp
```

---

## Template: Tech Design Component Chunk

```markdown
<!-- chunk_id: spec/lms/UC-LMS-001-tech-design#grade-service -->
<!-- doc_type: tech-design | domain: lms | stack: spring | status: approved -->

**Component:** GradeService
**Layer:** Application / Use Case
**Responsibility:** Fetch và format điểm học sinh, enforce FERPA access check

**Input:** studentId (UUID), subjectId (UUID), requesterId (UUID)
**Output:** GradeDTO { score, comment, gradedAt, auditLogId }
**Throws:** AccessDeniedException nếu requester không có quyền xem điểm student này

**Dependencies:**
- GradeRepository (Infrastructure)
- AuditLogService (Infrastructure)
- PermissionGateway (Port)
```

---

## Retrieval Prompt Pattern

```
Dùng khi query knowledge base, đặt trước user query:

"Tìm tài liệu liên quan đến [query].
Filter: domain=[domain], doc_type=[type], status=approved.
Trả về chunk_id, section_title, và đoạn văn liên quan nhất.
Nếu có nhiều version — ưu tiên version mới nhất."
```

---

## Ingestion Checklist

Trước khi index document vào vector store:

- [ ] Metadata đầy đủ (document_id, doc_type, domain, status)
- [ ] Status = `approved` (không index `draft`)
- [ ] Chunk size trong giới hạn theo doc_type
- [ ] Chunk có đủ context độc lập (không cần đọc chunk trước mới hiểu)
- [ ] Tags phản ánh đúng nội dung (dùng cho pre-filter)
- [ ] Deprecated docs đã được xóa hoặc mark `status: deprecated`
