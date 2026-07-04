# @trace.uc_id: UC-LMS-001
# @trace.domain: lms
# @trace.status: approved
# @trace.version: 1.0

Feature: Teacher creates assignment
  As a teacher
  I want to create an assignment for a class
  So that students can receive and submit work on time

  # SC1 — Happy path
  Scenario: Teacher creates assignment with valid inputs
    Given teacher "T001" is authenticated and assigned to class "CLS-6A"
    When the teacher submits assignment title "Math Homework 1" with due date "2026-07-10"
    Then the system returns success and stores assignment for class "CLS-6A"

  # SC2 — Alternate path
  Scenario: Teacher saves assignment as draft
    Given teacher "T001" is authenticated and assigned to class "CLS-6A"
    When the teacher saves assignment "Math Homework 1" as draft without publishing
    Then the assignment status is "DRAFT" and students cannot view it

  # SC3 — Error case
  Scenario: Teacher uses due date in the past
    Given teacher "T001" is authenticated
    When the teacher submits assignment with due date "2026-06-01"
    Then the system rejects request with error code "INVALID_DUE_DATE"
