# Framework Kit — AI Agent Integration Guide

Bộ công cụ (Framework Kit) định hướng và kiểm soát chất lượng hoạt động của AI Agent (như Claude Code, Cursor, Windsurf) dựa trên triết lý **Spec-Driven Design (SDD)**, **Quality Gates**, và **Graph-based Orchestration**.

Framework tách biệt tri thức làm 3 trục độc lập để tối ưu hóa Context Budget và ngăn chặn AI ảo tưởng (hallucination):
*   **Rule (WHAT)** — Kiến thức tĩnh (Naming convention, Architecture, Coding style).
*   **Skill (HOW)** — Quy trình thực thi hành động (Checklist, các bước làm TDD, Debugging...).
*   **Workflow (WHEN/NEXT)** — Luồng điều phối các bước đi và xử lý lỗi.

---

## 1. Triết Lý Phân Chia Trách Nhiệm (Core & Extension)

Để đảm bảo bộ kit luôn tinh gọn (lean) và dễ mở rộng sang mọi techstack mà không bị phình to (bloated), framework hoạt động theo mô hình **Core Engine & Architecture Plugins**:

| Kit Cung Cấp (Bắt buộc / Sẵn có) | Dev / Team Tự Viết (Theo dự án & stack) |
| :--- | :--- |
| **Cơ chế Phân giải Động:**<br/>Cú pháp `{stack}` và tự động nạp rules qua `requires_rules` trong Skills. | **Cấu trúc Kiến trúc (`rules/{stack}/architecture.mdc`):**<br/>Quy định layers, DI, naming cụ thể của dự án (ví dụ: Controller $\rightarrow$ Service $\rightarrow$ Repo). |
| **Global Baselines (Chất lượng toàn cục):**<br/>Bảo mật (`security-baseline.mdc`), Traceability (`traceability.mdc`), và SDD Gate (`sdd-gate.mdc`). | **Quy chuẩn Kiểm thử (`rules/{stack}/test-patterns.mdc`):**<br/>Cách cấu hình test runner, mock data, annotations của ngôn ngữ đang dùng. |
| **Quy trình Hành động (Stack-agnostic Skills):**<br/>Quy trình chạy TDD, BDD, Code Review, Debugging,... | **Cấu hình Runtime (`project-context.yaml`):**<br/>Khai báo stack, QC engine, source directories, và file extensions của dự án. |
| **Templates & Format Rules:**<br/>Các file mẫu (`plan-template.md`, `principles-template.md`, `spec-template.md`...) và định dạng quy chuẩn MDC. | **Nguyên tắc Dự án (`docs/principles.md`):**<br/>Các quy định đặc thù (MUST/MUST NOT) riêng biệt của dự án hoặc của doanh nghiệp. |

---

## 2. Sơ Đồ Hoạt Động Tổng Thể (Workflows & Quality Gates)

Dưới đây là sơ đồ tổng thể mô tả cách thức vận hành và sự phối hợp giữa **Developer/Agent**, **Specs**, **Code/Test**, và các **Quality Gates** của framework:

```mermaid
graph TD
    Start(["1. Nhận Ticket / Request"]) --> Route{"2. Intent Router\nrouter.yaml"}

    Route -->|Match Keyword| LoadSkill["3. Nạp Skill tương ứng\nskills/*/SKILL.md"]
    Route -->|Không Match| Fallback["3. Fallback: Free Match\nYêu cầu giải trình lý do"] --> LoadSkill

    LoadSkill --> LoadRules["4. Resolve stack\nNạp Rules tĩnh tương ứng\nrules/_global/* + rules/stack/*"]

    LoadRules --> TrackSelect{"5. Chọn Track\nworkflows/canonical-flow.md"}

    %% Standard Track %%
    TrackSelect -->|Standard Track| Brief["6a. Product Brief\ndocs/specs/feature.md"]
    Brief --> BDD["6b. BDD Spec\ndocs/specs/bdd/UC.feature\nGiven-When-Then"]
    BDD --> TechDesign["6c. Technical Design\ntech-design/UC-tech.md\nAPI, DB, Concurrency"]
    TechDesign --> PlanBreakdown["7. Lập Kế Hoạch\nplan-template.md\nRisk, Concurrency, Tasks"]

    %% Fast Track %%
    TrackSelect -->|Fast Track\nMarker: fast-track| PlanFast["6. Lập Kế Hoạch rút gọn"]
    PlanFast --> TDDCycle

    %% Hotfix Track %%
    TrackSelect -->|Hotfix Track\nMarker: hotfix| BugFlow["6. Phân loại lỗi\nbug-flow"]
    BugFlow --> TDDCycle

    PlanBreakdown --> TDDCycle["8. Bắt đầu TDD"]

    subgraph TDDLoop ["Vòng lặp Code & Test"]
        TDDCycle --> Red["8.1 Viết Test Fail\nProve-It Pattern nếu fix bug"]
        Red --> Green["8.2 Viết code tối thiểu\nđể test Pass"]
        Green --> Refactor2["8.3 Tối ưu hóa code\nĐối chiếu Rules/Architecture"]
        Refactor2 --> Annotate["8.4 Gắn tag Traceability\n@trace.implements / @trace.verifies"]
        Annotate --> LogProgress["8.5 Ghi progress log\ndocs/logs/"]
    end

    LogProgress -->|Task tiếp theo| TDDCycle
    LogProgress -->|Tất cả tasks done| GovernanceChecks{"9. Run Governance checks\ngovernance-check.sh"}

    subgraph QualityGates ["Hệ thống Quality Gates"]
        GovernanceChecks --> GateStack["validate-stack.sh\nKiểm tra stack rules"]
        GovernanceChecks --> GateSDD["validate-sdd-gate.sh\nKiểm tra Spec/BDD khớp code"]
        GovernanceChecks --> GateTrace["validate-trace.sh\nKiểm tra @trace & TSV signals"]
    end

    GateStack -->|FAIL| FixGate["10. Quay lại step gần nhất\nsửa nguyên nhân gốc"]
    GateSDD -->|FAIL| FixGate
    GateTrace -->|FAIL| FixGate
    FixGate --> TDDCycle

    GateStack & GateSDD & GateTrace -->|ALL PASS| DevSelfPass["11. dev_selftest: pass"]
    DevSelfPass --> QCRun["12. QC Automation\nqc-automation"]
    QCRun -->|FAIL| BugFlow
    QCRun -->|PASS| QCStatusPass["13. qc_status: pass"]

    QCStatusPass --> Shipping["14. Deploy / Release\nshipping"]
    Shipping --> End(["15. Merge PR & Ship thành công"])

    classDef start_end fill:#e1f5fe,stroke:#01579b,stroke-width:2px;
    classDef decision fill:#fff9c4,stroke:#fbc02d,stroke-width:2px;
    classDef process fill:#e8f5e9,stroke:#2e7d32,stroke-width:1px;

    class Start,End start_end;
    class Route,TrackSelect,GovernanceChecks decision;
    class LoadSkill,LoadRules,Brief,BDD,TechDesign,PlanBreakdown,PlanFast,BugFlow,TDDCycle,Red,Green,Refactor2,Annotate,LogProgress,GateStack,GateSDD,GateTrace,DevSelfPass,QCRun,QCStatusPass,Shipping,FixGate process;
```

---

## 3. Các Tuyến Phát Triển (Delivery Tracks)

*Single source of truth: [workflows/canonical-flow.md](file:///E:/Educa/k12-agent-kit/workflows/canonical-flow.md)*

### A. Standard Track (Dành cho Feature lớn / Đổi logic)
*   **Quy trình bắt buộc:** `Product Brief` $\rightarrow$ `BDD Spec` $\rightarrow$ `Tech Design` $\rightarrow$ `Plan` $\rightarrow$ `TDD` $\rightarrow$ `Code Review` $\rightarrow$ `QC Automation` $\rightarrow$ `Trace Validation` $\rightarrow$ `Shipping`.
*   **Enforcement:** Mọi cổng Quality Gate đều được kích hoạt tự động.

### B. Fast Track (Task < 30 phút, rủi ro thấp)
*   **Quy trình rút gọn:** `Plan (rút gọn)` $\rightarrow$ `TDD` $\rightarrow$ `Code Review` $\rightarrow$ `Trace Validation (tối thiểu)` $\rightarrow$ `Shipping`.
*   **Escape Hatch:** Commit message hoặc PR Title chứa thẻ `[fast-track]` để bỏ qua cổng SDD gate.

### C. Hotfix Track (Sửa lỗi khẩn cấp trên Production)
*   **Quy trình khẩn cấp:** `Bug-flow (phân loại)` $\rightarrow$ `TDD (Viết test tái hiện trước)` $\rightarrow$ `Code Review` $\rightarrow$ `QC (chạy focused)` $\rightarrow$ `Shipping`.
*   **Escape Hatch:** Commit message hoặc PR Title chứa thẻ `[hotfix]`.

---

## 4. Các Vai Trò & Personas Của Agent (`agents/`)

Bộ kit thiết kế sẵn các Agent Persona chuyên biệt để phân rã và kiểm định chất lượng chéo (Cross-verification):

1.  **Developer (`developer.md`):** Hiện thực hóa feature từ spec — lập kế hoạch, parallel execution, TDD, gắn @trace tags, cập nhật `dev_selftest`.
2.  **Debugger (`debugger.md`):** Phân tích log, trace call stack qua nhiều layer, xác định root cause và sửa lỗi theo Prove-It Pattern.
3.  **Code Reviewer (`code-reviewer.md`):** Kiểm tra mã nguồn trên 5 trục chất lượng (Kiến trúc, Hiệu năng, Bảo mật, Khả năng test, và Naming). Đóng vai trò kiểm duyệt trước khi merge.
4.  **Tester (`tester.md`):** Đọc BDD spec, lên kịch bản test suite động, kiểm tra các trường hợp biên và Edge cases.
5.  **Test Engineer (`test-engineer.md`):** Chuyên thiết kế cấu trúc test suite tự động, phân tích khoảng trống độ phủ test (Coverage Gap Analysis).
6.  **Security Auditor (`security-auditor.md`):** Rà soát bảo mật tĩnh, Threat Modeling, quét OWASP Top 10 và các rò rỉ secret key.
7.  **Web Performance Auditor (`web-performance-auditor.md`):** Audit Core Web Vitals, đo lường độ trễ (latency), N+1 queries và tối ưu hóa tài nguyên.

---

## 5. Quy Trình Cài Đặt và Bắt Đầu (Onboarding Checklist)

Thực hiện đúng thứ tự các bước sau khi bắt đầu một dự án mới:

1.  **Cài đặt Bộ Kit vào dự án:**
    Sao chép thư mục `k12-agent-kit` vào thư mục gốc của dự án hoặc liên kết symlink qua cấu hình `.claude-plugin/plugin.json`.
2.  **Cấu hình dự án (`project-context.yaml`):**
    Sao chép `project-context.yaml` vào root của dự án thật và điền thông tin:
    *   Set `stack:` đúng ngôn ngữ (ví dụ: `spring` / `laravel` / `golang`).
    *   Khai báo `source_dirs` và `code_extensions` (nếu dự án có cấu trúc không chuẩn để scripts validate chạy động chính xác).
3.  **Kích hoạt Git Hooks kiểm soát commit:**
    Chạy lệnh để tự động cài đặt Git Hook chặn AI-spam và conventional commit:
    ```bash
    bash scripts/hooks/install-hooks.sh
    ```
4.  **Kiểm tra và chuẩn bị Rules Stack:**
    *   Đọc `rules/<stack>/architecture.mdc` và `test-patterns.mdc` đã có sẵn.
    *   Nếu stack chưa tồn tại, copy từ thư mục `rules/_template/` sang và điền các conventions cụ thể của team bạn.
    *   Chạy kiểm tra tính hợp lệ của rules:
        ```bash
        bash scripts/validate-stack.sh
        ```
5.  **Tích hợp `CLAUDE.md` vào Root:**
    Copy `templates/context-engineering/03-claude-md-template.md` ra thư mục gốc của dự án thật, đổi tên thành `CLAUDE.md`, điền các câu lệnh build/test/run cụ thể để Claude Code có thể đọc vị dự án ngay khi bắt đầu session.

---

## 6. Hệ Thống Kiểm Tra Tự Động (Quality Gates Scripts)

Chạy script kiểm duyệt trước khi merge Pull Request:
```bash
bash scripts/governance-check.sh
```
Lệnh này sẽ kích hoạt tuần tự:
*   `validate-stack.sh`: Đảm bảo toàn bộ quy tắc thiết kế stack đã được chuẩn bị đầy đủ.
*   `validate-sdd-gate.sh`: Đảm bảo mọi thay đổi code đều có tài liệu Spec/BDD đi kèm (chống trôi spec).
*   `validate-trace.sh`: Đảm bảo mọi kịch bản nghiệp vụ trong BDD đều đã được Code và Test bao phủ (đồng thời kiểm duyệt tự động các tín hiệu `dev_selftest` và `qc_status` trong file trace TSV).
