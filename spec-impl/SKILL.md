---
name: spec-impl
description: Plan, implement, test, and verify one approved system use case from docs/spec, then record implementation conformance. Use when explicitly invoked to implement approved behavior, synchronize code with a revised use case, or repair implementation drift.
disable-model-invocation: true
user-invocable: true
argument-hint: "<domain>/<use-case>"
---

# Implement Use Case

Plan and execute the smallest code-and-test change that makes implementation conform to one reviewed use case. In an adopted workflow, accepted specifications define intended observable behavior; repository rules and existing architecture define how that behavior is implemented, and code and tests describe the observed implementation.

## Input

The user supplies a use-case path or a domain plus use-case name. If the specification cannot be found, try the current open file before asking for its path.

## User Decisions and Clarifications

Whenever this workflow needs a user choice or clarification to produce a complete implementation plan, call `AskUserQuestion`. Do not bury unresolved choices in narrative text, the plan, risks, or the completion report. Give only the context needed for the choice, offer concrete mutually exclusive options, and put the recommended option first with `(Recommended)` when appropriate. Do not ask the user to decide facts that the accepted specification or repository evidence already establishes.

Behavioral decisions belong in `/spec-uc`, and foundation decisions belong in `/spec-domain`; route them there rather than deciding them during implementation. Use the host's native plan-and-approval mechanism for approval of the completed implementation plan itself, without duplicating that approval through `AskUserQuestion`.

## Preconditions

1. Read `docs/spec/catalog.md`, the domain `catalog.md`, `entity-model.md`, and selected use case.
2. Read repository instructions and inspect working-tree changes.
3. Require `Approved` for new or changed behavior and for an `Approved Removal` artifact.
4. Accept `Implemented` only for conformance checking, repair, or behavior-preserving work.
5. Reject `Draft`, `Review`, or any `## Open Questions` heading. Never remove or answer Open Questions; `/spec-uc` must resolve them and establish `Approved`.
6. When the file contains `## Approved Removal`, require the durable removal fields defined by `/spec-uc`, plan against the required observable absence, and skip the normal use-case structure checks below.
7. For every normal use case, require exactly one Status line and exactly one Goal, Actors, Preconditions, Trigger, Behavior Diagrams, Main Flow, and Postconditions section. Require Behavior Diagrams between Trigger and Main Flow with an `### Overview` subsection containing exactly one fenced `mermaid` block and no more than three named process diagrams with one Mermaid block each. Return a structurally incomplete artifact to `/spec-uc` before planning.
8. Confirm a normal file covers one complete externally meaningful primary-actor goal. If it is only an endpoint, button, CRUD operation, validation, internal component, or flow-step fragment—or if it bundles independent goals, triggers, or outcomes—stop and return it to `/spec-uc`. Do not split, merge, or compensate for its boundary during implementation.

If requested behavior is absent or implementation discovery exposes a missing product decision, stop and return to `/spec-uc`. Never modify a specification to rationalize accidental code behavior.

## Specification Authority and Conflicts

Accepted specifications govern intended behavior. Repository rules and architecture govern implementation choices, and code and tests establish observed implementation; they do not override an accepted contract. Treat a mismatch as implementation drift.

If specification artifacts conflict, stop before planning or editing implementation and identify the exact contradiction for human resolution. Return product-definition, domain-boundary, requirement, Entity Model, shared-policy, or shared-terminology conflicts to `/spec-domain`. Return conflicts in one interaction's goal, boundary, flow, outcome, or status to `/spec-uc`.

## Stage 1 — Inspect and Plan

1. Trace the installed or public execution path.
2. Locate existing responsibilities, domain types, validation, error boundaries, reusable utilities, and relevant tests.
3. Compare current observable behavior with every relevant accepted specification: the root and domain catalogs, Entity Model, selected use case, and related accepted use cases whose contracts overlap.
4. For a normal use case, verify the required Behavior Diagrams overview is syntactically valid with an available renderer, or manually inspect it and report renderer unavailability. Verify any named process diagrams against the authoritative text and return contradictions to `/spec-uc`.
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

Use the host's native plan-and-approval mechanism when available. An implementation plan is a transient planning record, not a `docs/spec` artifact; do not store it under `docs/spec`. Do not edit code, tests, or status before approval.

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
- Required Behavior Diagrams overview, named process diagrams, Mermaid validity, and text consistency for a normal use case.

Report exact command results and distinguish pre-existing, introduced, skipped, and unavailable checks. Compilation or inspection alone does not establish conformance when behavior-derived tests are required.

## Stage 6 — Update Status

Promote `Approved` to `Implemented` only when:

- production code conforms;
- behavior-derived tests protect applicable flows, policies, and outcomes;
- required focused validation passes.

If evidence is incomplete, leave `Approved`. A behavior-preserving refactor may retain `Implemented` after tests pass. `Implemented` does not mean deployed, enabled in production, operationally healthy, or free from every defect.

For an `Approved Removal` artifact, delete the use-case file and its domain-catalog row only after the specified behavior and behavior-derived tests are removed or updated, the required observable absence is verified, and all required validation passes. Until then, preserve the artifact and catalog row so interrupted work remains recoverable. Report the final result as `Removed`; no status file remains.

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
