---
name: spec-uc
description: Create, revise, split, rename, or review one observable system use case inside an existing docs/spec domain. Use when explicitly invoked to specify new behavior, change intended behavior, resolve ambiguity, compare a reported bug with the specification, or prepare behavior for implementation.
disable-model-invocation: true
user-invocable: true
argument-hint: "<domain>/<use-case> [requested-change]"
---

# Specify Use Case

Create or revise one system use case without changing application code or tests. A use case describes one observable interaction and one meaningful outcome inside an existing domain.

## Input

The user supplies a use-case path, a domain plus use-case name, or a behavior request from which both can be resolved. If the specification cannot be found, try the current open file before asking for its path.

## User Decisions and Approval

Call `AskUserQuestion` whenever a user decision is needed before recording behavior as settled. Give only the needed context and concrete mutually exclusive options, with the recommended option first. Do not ask the user to decide repository facts or leave actionable choices only in a summary or handoff. **For every semantic change that needs a decision, call `AskUserQuestion` and wait for the answer before using Write/Edit on any specification file.** When discussion finishes, ask the user to **Mark Approved** or enter what to discuss next. A `Draft` or `Review` remains editable while discussion continues; follow Draft and Review Iteration for approval, removal, and deletion timing.

## Preconditions

Read:

1. `docs/spec/catalog.md` for product context and path conventions;
2. `docs/spec/<domain>/catalog.md`;
3. `docs/spec/<domain>/entity-model.md`;
4. related use cases;
5. repository instructions and only relevant code, tests, and documents as evidence.

If the domain catalog or Entity Model does not exist, stop and direct the user to `/spec-domain`.

For a Coordinated Domain Change started by `/spec-domain`, also read the concise pending-change summary from the current conversation. Review affected use cases against that accepted proposal rather than only the stored foundation. Preserve every specification file until the foundation and all affected use cases are explicitly approved.

## Specification Authority

The presence of `docs/spec/catalog.md` means the project has adopted this workflow. Within `docs/spec/`:

- Root and domain catalogs and Entity Models are the reviewed foundation.
- `Approved` and `Implemented` use cases are accepted implementation contracts.
- `Draft` and `Review` use cases are authoritative records of proposals, but they are not implementation targets.
- Code and tests describe observed implementation. If they differ from an accepted specification, classify the difference as implementation drift; do not rewrite intended behavior to match accidental code.

If specification artifacts conflict, stop and identify the exact contradiction for human resolution. Return foundation, domain-boundary, requirement, Entity Model, shared-policy, or shared-terminology conflicts to `/spec-domain`. Resolve one interaction's goal, boundary, flow, outcome, or status conflict through `/spec-uc`.

## Classify the Request

| Situation | Action |
|---|---|
| New observable goal | Start a persisted `Draft` with the next sequence and follow Draft and Review Iteration. |
| Intended behavior changes to an `Approved` or `Implemented` use case | Keep the accepted file unchanged; when the user asks to save the working revision, create recoverable `Review` and follow Draft and Review Iteration. |
| Existing persisted `Draft` or `Review` | Follow Draft and Review Iteration. |
| Wording changes without behavioral effect | Apply a focused editorial edit and preserve status. |
| Title or path rename without behavioral effect | Preserve sequence and status, move the file, update the domain-catalog row and every `docs/spec` reference, and validate all affected links. |
| A requested rename changes the actor goal, boundary, or behavior | Treat it as a semantic revision; update the working artifact and move it only after the user confirms the destination. |
| One file contains multiple independent goals | Use a complete `Draft` or `Review` split set; retain the original sequence for the closest goal and allocate new sequences for the others. |
| Current use case already states the desired behavior | Treat the problem as implementation drift and direct the user to `/spec-impl`. |
| New, unimplemented persisted `Draft` is no longer wanted | Require confirmation, then remove its file and catalog row while leaving the sequence gap. |
| Existing persisted `Review` is rejected or abandoned | Restore the recoverable accepted content and prior status; do not delete the use case. |
| `Approved` or `Implemented` behavior should be removed | Create or update a `Review` negative contract when an observable rejection or unavailable result remains; otherwise finalize an `Approved Removal` artifact. |

When uncertain whether actors, permissions, preconditions, trigger, flows, outcomes, rules, or scope change, treat the edit as semantic.

## Bound the Use Case

Use one externally meaningful goal of one primary actor as the boundary:

1. Identify the external primary actor and a goal that actor can recognize as valuable.
2. Start with the observable trigger and end with meaningful success and failure postconditions.
3. Keep alternate paths, retries, validation failures, permission failures, and other visible failures in the same use case when they serve that goal.
4. Do not split merely because behavior crosses endpoints, buttons, CRUD operations, screens, internal components, validations, or flow steps.
5. Split when a goal, trigger, or outcome is independently initiated, independently valuable, or independently reviewable and implementable.
6. When uncertain, ask whether the proposed fragment still delivers actor value when separated from the surrounding interaction.

| Boundary | Example |
|---|---|
| Too fine | Validate an address, click **Save**, or call the address endpoint. |
| Appropriate | A customer changes a shipping address, from submitting the replacement through confirmation or a visible failure with unchanged state. |
| Too broad | Manage an account by combining address changes, password changes, and account closure. |

Expected variants and visible failures belong in alternate or exception flows when they serve the same goal. Shared invariants belong in the Entity Model, and domain-wide obligations belong in catalog requirements; neither is a reason to manufacture a cross-cutting use case.

## Draft and Review Iteration

Persist a new use case as `Draft` and an accepted-use-case revision as recoverable `Review` when the user asks to save the working revision. Update either status incrementally as behavior is confirmed; retain unresolved matters in `## Open Questions`. Keep accepted files unchanged until a revision is explicitly saved. Resolve outstanding decisions before offering approval.

Use this concise summary at the start of a new working artifact, when scope changes, or when a material decision needs review:

```markdown
# Use Case Review: [Use Case]

## Classification and Boundary

## Proposed Behavioral Changes

- **Primary actor and goal:**
- **Preconditions and trigger:**
- **Success behavior and postconditions:**
- **Meaningful variants and visible failures:**

## Domain Impact

- [Requirement or Entity Model concept/property/relationship/value type/policy/enumeration/constraint]

## Decisions Needed

## Contradictions and Assumptions

## Affected Specification Paths
```

For removal with no enduring interaction, summarize the interaction to remove, its required observable absence, and the final verification needed before its file and catalog row can be deleted.

The summary exposes material choices without reproducing the artifact. Do not print the complete artifact as response content; write only confirmed behavior and retain unsettled matters in `## Open Questions`.

After re-reading targets and sequence allocation, prepare the proposed semantic delta without writing it. If the delta needs a user decision, call `AskUserQuestion` and wait for the answer before using Write/Edit. Only then update a `Draft` or `Review` with confirmed behavior. To save a revision of an `Approved` or `Implemented` use case, first verify recovery of the accepted version, then write the complete working revision as `Review`; never preserve `Implemented` after a semantic revision.

When all decisions are resolved, remove `## Open Questions` and use the approval prompt above. On **Mark Approved**, re-read before writing `Approved`; if a new decision emerges, return it to the working artifact instead. Persist and update every member of a split together. For a Coordinated Domain Change, write no finalized member and hand the approved set to `/spec-domain`. Persist an `Approved Removal` artifact only after the user selects **Mark Approved** for that removal.

## Status Rules

- `Draft`: an editable persisted new use case under discussion. It may contain `## Open Questions` and cannot be implemented.
- `Review`: an editable persisted revision to accepted behavior under discussion. It may contain `## Open Questions` and cannot be implemented.
- `Approved`: a human explicitly finalized and accepted the complete behavior, or a durable removal decision. It contains no `## Open Questions` heading.
- `Implemented`: code conforms, behavior-derived tests exist, and required validation passed. Only `/spec-impl` establishes it.
- An accepted removal with no enduring interaction remains at its existing path as an `Approved Removal` artifact until `/spec-impl` verifies removal.
- Editorial changes preserve status. If a persisted `Review` is rejected, restore the recoverable accepted version; when recovery is unavailable, preserve the file and stop for human resolution.

Status appears as one visible line below the H1 and nowhere else:

```markdown
**Status:** Draft
```

Do not add frontmatter, owner, reviewer, date, version, deployment, progress, or status history to use-case files or catalogs.

## Sequence and Path Rules

- Files are `docs/spec/<domain>/<three-digit-sequence>-<kebab-case-slug>.md`.
- Allocate `max(existing numeric prefix) + 1`.
- Never fill a gap, reuse a deleted sequence, or renumber files.
- Keep the existing path for a focused revision or title improvement unless the filename becomes materially misleading.
- A sequence is local reading order and a stable link, not a globally tracked identifier.
- When splitting, preserve the original sequence for the closest existing goal.

## Canonical Working Use-Case Structure

Use this structure when creating or incrementally updating a persisted `Draft` or `Review`, and when finalizing it as `Approved`. It is not a response template. Keep unresolved decisions in `## Open Questions` until final approval.

````markdown
# [Use Case]

**Status:** [Draft, Review, or Approved]

## Goal

[Current confirmed goal; mark unresolved scope in Open Questions rather than inventing it.]

## Actors

- **Primary:** [Person, API client, scheduler, message producer, or external system]
- **Supporting:** [Other external participant, when relevant]

## Preconditions

- [Currently confirmed state before the interaction begins.]

## Trigger

[Currently confirmed observable event that starts the use case.]

## Behavior Diagrams

### Overview

```mermaid
[Compact projection of the currently confirmed primary behavior]
```

### [Nested Process]

```mermaid
[Optional compact projection of a complex currently confirmed nested process]
```

## Main Flow

1. [Currently confirmed observable step.]

[Add `## Alternate Flows` and `## Exception Flows` only for currently confirmed variations or visible failures.]

## Postconditions

### On Success

- [Currently confirmed result.]

### On Failure

- [Currently confirmed unchanged or recovered state.]

## Open Questions

- [Unresolved product decision or behavior still under discussion.]
````

A working `Draft` or `Review` may leave conditional sections incomplete, but it must not invent unresolved behavior. An `Approved` artifact meets the complete-structure and diagram rules in Validation.

## Writing Rules

- Keep one complete externally meaningful primary-actor goal per file, from its observable trigger through meaningful postconditions.
- Actors are external participants, not controllers, services, databases, internal workers, or UI components.
- Preconditions are true before step one; checks performed by the system belong in a flow.
- Main-flow steps are ordered, active, atomic, and externally observable.
- Alternate flows are expected variations; exception flows define meaningful visible failure behavior.
- Every alternate or exception names its main-flow divergence step and outcome.
- Postconditions state guarantees, including unchanged or recovered failure state.
- Put shared rules in Entity Model policies or constraints. Express interaction-specific behavior directly in flows and postconditions.
- Use concept and value-type names exactly as defined in `entity-model.md`.
- Do not include architecture, function names, tables, framework mechanics, implementation tasks, test cases, or a separate acceptance-criteria section.

Behavior Diagrams:

- appear after Trigger and before Main Flow;
- contain one `### Overview` subsection with exactly one fenced `mermaid` block;
- may contain up to three named process subsections, each with exactly one fenced `mermaid` block, only when they simplify a complex nested process;
- use `flowchart` for decision-heavy behavior, `sequenceDiagram` for participant exchanges and ordering, or `stateDiagram-v2` for lifecycle transitions;
- project the authoritative textual flows;
- keep the overview compact by summarizing the primary path and material decisions rather than duplicating every alternate or exception flow;
- introduce no behavior absent from the text;
- map every diagram branch to a main, alternate, or exception flow;
- use Entity Model terms and observable behavior;
- are checked with an available Mermaid renderer, or manually inspected with the missing renderer reported.

## Approved Removal Artifact

When an accepted removal leaves no enduring interaction, replace the existing use case with this durable temporary contract after approval:

```markdown
# [Existing Use Case]

**Status:** Approved

## Approved Removal

- **Interaction to remove:** [Existing actor goal and trigger that must cease to exist.]
- **Required observable absence:** [Entry point, capability, or outcome that must no longer be available.]
- **Final verification:** [Observable evidence required before deleting this file and its catalog row.]
```

This is the only exception to the normal required use-case structure. Preserve the existing title, path, sequence, and domain-catalog row while removal is pending. Do not include implementation design, status history, or an `## Open Questions` heading. `/spec-impl` deletes the artifact and catalog row only after removing the behavior and behavior-derived tests and completing required validation.

## Rename a Use Case

For a behavior-neutral title or path rename:

1. Re-read the use case, domain-catalog row, and all references under `docs/spec`.
2. Preserve the numeric sequence and current status.
3. Move the file to the approved kebab-case path; do not copy it into a second sequence or leave the old path unless the repository already requires redirects for specification files.
4. Update the H1, domain-catalog row, and every affected `docs/spec` link or reference.
5. Resolve every changed link and confirm the old path is no longer referenced.

If the requested name changes the actor goal, boundary, or behavior, update the `Draft` or `Review` after the user confirms the destination. Finalize it separately only when the user explicitly asks.

## Update or Finalize a Use Case

1. Re-read targets and sequence allocation. Prepare any semantic delta without editing; record a new decision in `## Open Questions` only after the user answers the corresponding `AskUserQuestion`.
2. For a semantic update, call `AskUserQuestion` and wait before using Write/Edit. Then update a `Draft` or `Review` under `docs/spec` with confirmed behavior, preserving its status and unresolved questions. Keep an accepted file unchanged until its working revision is explicitly saved as `Review`.
3. When all decisions are resolved—or when the user separately requests finalization—verify the required structure and diagram consistency, resolve and remove `## Open Questions`, then use the approval prompt above. Write `Approved` only after **Mark Approved** is selected.
4. Persist and update every split member together; finalize it only after every member receives explicit final approval. After final approval of a Coordinated Domain Change, write no member and hand the set to `/spec-domain` for application.
5. For an approved removal with no enduring interaction, write the `Approved Removal` artifact and preserve its catalog row for `/spec-impl`.
6. Apply confirmed renames using the procedure above, and update the catalog row when the index or outcome changes.
7. Make only the smallest directly required domain requirement or Entity Model change. Return domain scope, shared terminology, Entity Model restructuring, or multi-use-case effects to `/spec-domain`.
8. Keep each normative statement in one layer, preserve unrelated reviewed content, and change no application code or tests.

## Validation

- A `Draft` or `Review` is updated only after the required `AskUserQuestion` answer, preserves unresolved matters in `## Open Questions`, remains ineligible for implementation, and does not replace an accepted file until explicitly saved as recoverable `Review`.
- No semantic specification file is written before its required user decision is asked and answered.
- Promotion to `Approved` occurs only after resolution of every decision and selection of **Mark Approved**.
- No finalized coordinated member was written by `/spec-uc`; the approved summary was handed to `/spec-domain` for coordinated application.
- A normal `Approved` use-case artifact contains exactly one Status line and exactly one Goal, Actors, Preconditions, Trigger, Behavior Diagrams, Main Flow, and Postconditions section.
- A `Draft` or `Review` contains all currently confirmed sections and does not fabricate unresolved behavior to satisfy a template.
- Behavior Diagrams appears between Trigger and Main Flow, contains an `### Overview` subsection with exactly one fenced `mermaid` block when primary behavior is confirmed, and contains no more than three named process diagrams with one Mermaid block each.
- The file spans one complete externally meaningful primary-actor goal from observable trigger through meaningful success and failure postconditions.
- Alternate, retry, validation, permission, and failure paths remain flows when they serve that goal; independently valuable goals, triggers, or outcomes are split.
- The boundary was not created merely from an endpoint, button, CRUD operation, screen, internal component, validation, or individual step.
- Flow steps are observable and atomic.
- Every branch identifies its divergence and outcome.
- Success and failure guarantees are explicit.
- Terminology matches the Entity Model, and every referenced non-primitive type or concept is defined there.
- Use-case flows and postconditions do not duplicate Entity Model policies.
- Domain requirements are elaborated rather than copied.
- Mermaid syntax and text/diagram consistency were checked with an available renderer, or manual inspection and renderer unavailability are reported.
- An `Approved Removal` artifact contains only the accepted durable removal contract, preserves its existing path and catalog row, and has no `## Open Questions` heading.
- A rename preserves sequence and status, updates the H1, catalog row, and every affected `docs/spec` reference, leaves no unintended duplicate, and resolves every changed link.
- Catalog links resolve and sequence rules hold.

## Handoff

Report only a concise handoff: classification, confirmed behavioral delta, changed paths, resulting status, unresolved decisions, and validation performed. Do not echo complete specification contents. Before ending a completed discussion, use the approval prompt above; entered text continues the discussion. For a Coordinated Domain Change after final approval, report the approval without writing files and give the exact `/spec-domain ... apply coordinated change` command. Direct only finalized accepted behavior, an `Approved Removal` artifact, or implementation drift to `/spec-impl`.
