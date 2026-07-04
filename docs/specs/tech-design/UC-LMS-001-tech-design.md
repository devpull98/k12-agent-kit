# Tech Design — UC-LMS-001: Teacher creates assignment

<!-- @trace.uc_id: UC-LMS-001 -->
<!-- @trace.bdd_version: 1.0 -->
<!-- @trace.status: approved -->

## 1. Summary
This design defines APIs and persistence for teacher assignment creation in LMS.
It implements behavior from `UC-LMS-001` with validation for due date and publish state.

**BDD Spec:** `docs/specs/bdd/UC-LMS-001.feature`  
**Scenarios in scope:** SC1, SC2, SC3

## 2. API Endpoint

### `POST /api/lms/assignments`
**Description:** Create assignment as published or draft  
**Auth required:** Role `TEACHER`

**Request Body**
```json
{
  "classId": "CLS-6A",
  "title": "Math Homework 1",
  "dueDate": "2026-07-10",
  "status": "PUBLISHED"
}
```

**Success Response — 201**
```json
{
  "code": 201,
  "message": "created",
  "data": {
    "assignmentId": "ASM-1001",
    "status": "PUBLISHED"
  }
}
```

**Error Responses**
- `400 INVALID_DUE_DATE`: due date is in the past
- `403 FORBIDDEN_CLASS_ACCESS`: teacher not assigned to class

## 3. Database Changes

### Table: `lms_assignments`
| Field | Type | Nullable | Index | Description |
|------|------|----------|-------|-------------|
| id | BIGINT PK | No | PK | Assignment id |
| class_id | VARCHAR(32) | No | IDX | Class identifier |
| teacher_id | VARCHAR(32) | No | IDX | Owner teacher |
| title | VARCHAR(255) | No | - | Assignment title |
| due_date | DATE | No | IDX | Deadline date |
| status | VARCHAR(16) | No | IDX | DRAFT or PUBLISHED |
| created_at | TIMESTAMP | No | - | Creation timestamp |

## 4. Layer Map
| Layer | Module/File | Responsibility |
|------|-------------|----------------|
| Controller | `lms-api/controller/AssignmentController` | Request validation and auth check |
| Service | `lms-core/service/AssignmentService` | Business rules and workflow |
| Repository | `lms-core/repository/AssignmentRepository` | Insert/query assignment records |

## 5. Trace Mapping
- `SC1` -> create published assignment -> `@trace.implements: UC-LMS-001-SC1`
- `SC2` -> create draft assignment -> `@trace.implements: UC-LMS-001-SC2`
- `SC3` -> reject past due date -> `@trace.implements: UC-LMS-001-SC3`
