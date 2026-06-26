---
name: feature
---

# Flow
brainstorm → spec → plan → (tdd → log)×n task → review → ship

# Steps
| Step       | Skill     | On fail → |
|------------|-----------|-----------|
| brainstorm | brainstorming | - |
| spec       | spec-driven-development | brainstorm |
| plan       | writing-plans | spec |
| tdd        | tdd       | plan |
| log        | progress-logging | - (chạy ngay sau mỗi task tdd pass, không phải gate chặn) |
| review     | code-review | tdd |
| ship       | shipping  | review |

`log` không phải gate — nó chạy sau MỖI task trong plan pass verification, lặp lại cho tới khi hết task,
rồi mới sang `review`.
