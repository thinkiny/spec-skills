---
name: spec-impl
description: Plan, implement, test, and verify one approved system use case from docs/spec, then record implementation conformance. Use when explicitly invoked to implement approved behavior, synchronize code with a revised use case, repair implementation drift, or produce a plan-only implementation analysis.
disable-model-invocation: true
user-invocable: true
argument-hint: "<domain>/<use-case> [plan only]"
---

# Implement Use Case

Plan and execute the smallest code-and-test change that makes implementation conform to one reviewed use case. Specifications define observable behavior; repository rules and existing architecture define implementation.

## Input

The user supplies a use-case path or a domain plus use-case name. `plan only` stops after the approved planning stage without implementation edits.

## Preconditions

1. Read `docs/spec/catalog.md`, the domain `catalog.md`, `entity-model.md`, and selected use case.
2. Read repository instructions and inspect working-tree changes.
3. Require `Approved` for new or changed behavior.
4. Accept `Implemented` only for conformance checking, repair, or behavior-preserving work.
5. Reject `Draft` or `Review` and direct the user to `/spec-uc`.
6. Reject any `## Open Questions` heading, even when empty.
7. Never remove or answer Open Questions automatically; `/spec-uc` must resolve them and establish `Approved`.
8. For removal with no enduring interaction, require the explicitly accepted removal packet from `/spec-uc` in the current conversation and keep the existing `Approved` or `Implemented` file until code and tests are removed successfully.
9. Confirm one goal, observable flows, explicit outcomes, and terminology consistent with the domain and Entity Model.

If requested behavior is absent or implementation discovery exposes a missing product decision, stop and return to `/spec-uc`. Never modify a specification to rationalize accidental code behavior.

## Stage 1 — Inspect and Plan

1. Trace the installed or public execution path.
2. Locate existing responsibilities, domain types, validation, error boundaries, reusable utilities, and relevant tests.
3. Compare current observable behavior with the domain catalog, Entity Model, and every textual use-case section.
4. When a Behavior Diagram exists, verify it is syntactically valid when a renderer is available and is a faithful projection of the authoritative text. Return contradictions to `/spec-uc`.
5. Determine whether the implementation already conforms. If it does, plan only the necessary verification and status result; do not manufacture code changes.
6. Otherwise identify the smallest coherent behavioral delta while preserving unrelated architecture and user changes.
7. Map the contract to verification:

| Specification Source | Required Evidence |
|---|---|
| Actors | Authentication, authorization, and caller-context setup |
| Preconditions | Test fixture and initial state |
| Trigger | Public entry action that starts the behavior |
| Main Flow | Successful-path behavior test |
| Alternate Flow | Variation test when meaningful |
| Exception Flow | Defined error-path test |
| Postcondition | Observable result or final-state assertion |
| Entity Model policy or constraint | Applicable regression evidence |

Present:

```markdown
# [Use Case] Implementation Plan

## Behavioral Target

## Constraints

## Existing Execution Path

## Proposed Changes

### Phase 1 — [Coherent change]

**Validation gate:** [Focused evidence]

### Phase 2 — [Coherent change]

**Validation gate:** [Focused evidence]

## Behavior-to-Test Mapping

## Verification Commands

## Risks and Non-Goals
```

Use the host's native plan-and-approval mechanism when available. A host-required transient plan record is not a project specification. Do not edit code, tests, or status before approval. Stop here for `plan only`.

## Stage 2 — Establish the Baseline

After approval:

1. Re-read files that may have changed.
2. Run the smallest relevant existing checks and record pre-existing failures.
3. For bugs, regressions, correctness issues, or timing-sensitive behavior, first add or update a failing behavioral test.
4. Ensure the test would fail when the protected behavior is broken.
5. If an `Implemented` use case is confirmed not to match code, change it to `Approved` before repair. If repair becomes blocked, leave it `Approved` rather than claiming conformance.

## Stage 3 — Implement the Behavioral Delta

- Follow repository architecture, naming, error-handling, compatibility, and testing rules.
- Reuse the responsibility that already owns the behavior.
- Keep changes focused on the approved use case and applicable Entity Model policies and constraints.
- Preserve explicit failure behavior and unchanged-state guarantees.
- Do not implement behavior absent from the approved contract.
- Do not add numeric use-case references or metadata solely for traceability.
- Stop dependent work and return to `/spec-uc` when a missing product decision appears.

## Stage 4 — Derive and Run Tests

Use the smallest layer that proves the contract:

- pure rule: focused unit test;
- service, persistence, API, event, or job behavior: integration or public-entry-path test;
- UI behavior: component/integration test, with browser E2E only when browser behavior matters;
- dispatch, retry, callback, or routing behavior: installed/public dispatch-path test.

Tests assert observable behavior and postconditions rather than private structure. Run focused tests first, then the smallest relevant broader checks from the approved plan.

## Stage 5 — Verify Conformance

Review the final implementation against:

- domain scope and requirements;
- applicable Entity Model policies and constraints;
- actors and their access context;
- every precondition and the trigger;
- every main-flow step;
- meaningful alternate and exception flows;
- success and failure postconditions;
- Behavior Diagram consistency when present.

Report exact command results and distinguish pre-existing, introduced, skipped, and unavailable checks. Compilation or inspection alone does not establish conformance when behavior-derived tests are required.

## Stage 6 — Update Status

Promote `Approved` to `Implemented` only when:

- production code conforms;
- behavior-derived tests protect applicable flows, policies, and outcomes;
- required focused validation passes.

If evidence is incomplete, leave `Approved`. A behavior-preserving refactor may retain `Implemented` after tests pass. `Implemented` does not mean deployed, enabled in production, operationally healthy, or free from every defect.

For an explicitly approved removal with no enduring interaction, delete the use-case file and its domain-catalog row only after code and behavior-derived tests are removed or updated and all required validation passes. Until then, keep the original file and status. Report the final result as `Removed`; no status file remains.

## Completion Report

```markdown
# Outcome

[Completed, partially completed, blocked, or already conforming.]

## Specification Conformance

| Contract | Implementation and Test Evidence |
|---|---|
| Actors | [Evidence] |
| Preconditions and Trigger | [Evidence] |
| Main Flow | [Evidence] |
| Alternate or Exception Flow | [Evidence] |
| Postconditions | [Evidence] |
| Entity Model policy or constraint | [Evidence] |

## Changed Files

## Validation Results

## Remaining Issues

## Final Status

[Approved, Implemented, or Removed, with reason.]
```

Do not create a separate implementation-status file, dashboard entry, requirement map, persistent project plan, or duplicate status in a catalog.
