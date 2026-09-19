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

The user supplies a use-case path, a domain plus use-case name, or a behavior request from which both can be resolved.

## Preconditions

Read:

1. `docs/spec/catalog.md` for product context and path conventions;
2. `docs/spec/<domain>/catalog.md`;
3. `docs/spec/<domain>/entity-model.md`;
4. related use cases;
5. repository instructions and only relevant code, tests, and documents as evidence.

If the domain catalog or Entity Model does not exist, stop and direct the user to `/spec-domain`.

For a Coordinated Domain Change started by `/spec-domain`, also read the pending domain packet from the current conversation. Review affected use cases against that accepted proposal rather than only the stored foundation, and keep proposed use-case edits conversation-only until the coordinated set is accepted.

## Classify the Request

| Situation | Action |
|---|---|
| New observable goal | Propose a new use case with the next sequence and `Draft` status. |
| Intended behavior changes | Keep the accepted file unchanged while proposing the delta; save an unaccepted revision as `Review` only when explicitly requested. |
| Wording changes without behavioral effect | Apply a focused editorial edit and preserve status. |
| One file contains multiple independent goals | Propose a split; retain the original sequence for the closest goal and allocate new sequences for the others. |
| Current use case already states the desired behavior | Treat the problem as implementation drift and direct the user to `/spec-impl`. |
| New, unimplemented `Draft` is no longer wanted | Require confirmation, then remove its file and catalog row while leaving the sequence gap. |
| Saved `Review` is rejected or abandoned | Restore the recoverable accepted content and prior status; do not delete the use case. |
| `Approved` or `Implemented` behavior should be removed | If an observable rejection or unavailable result remains, revise and retain that negative contract. If no enduring interaction remains, prepare an explicit removal packet, keep the existing file until implementation succeeds, and hand the packet to `/spec-impl`. |

When uncertain whether actors, permissions, preconditions, trigger, flows, outcomes, rules, or scope change, treat the edit as semantic.

## Review Before Semantic Writes

For a new use case or semantic revision, present:

```markdown
# Use Case Review: [Use Case]

## Classification

## Current Behavior

## Proposed Behavior

## Affected Sections

## Domain Impact

- [Requirement or Entity Model concept/property/relationship/value type/policy/enumeration/constraint]

## Contradictions and Assumptions

## Decisions Needed

## Proposed Use Case

[Complete use case using `Draft` for new behavior or `Review` for a revision. For removal with no enduring interaction, replace this section with an explicit removal packet naming the file, catalog row, observable absence, code/tests to remove, and verification required.]
```

Stop after the packet. Do not write a semantic change or infer approval from silence.

A conversation-only proposal leaves an existing file and status unchanged. Save unresolved work only when the user explicitly requests it.

For removal with no enduring interaction, the explicitly accepted removal packet is the temporary contract for `/spec-impl` in the current session. Keep the existing `Approved` or `Implemented` use-case file and catalog row until implementation and verification succeed; `/spec-impl` removes them only as its final verified step.

Before overwriting accepted content with a saved `Review`, verify the previous file is recoverable from version control. Show the behavioral diff. If recovery is unavailable, keep the proposal in conversation instead of overwriting the accepted file.

After the user accepts complete behavior, re-read target files, remove the entire `## Open Questions` section, and write status `Approved`. Never preserve `Implemented` after an accepted semantic change; `/spec-impl` must verify code and tests.

## Status Rules

- `Draft`: a new use case is not yet accepted. It may contain `## Open Questions` and cannot be implemented.
- `Review`: a saved revision to previously accepted behavior is not yet accepted. It may contain `## Open Questions` and cannot be implemented.
- `Approved`: a human accepts the complete behavior and the file contains no `## Open Questions` heading.
- `Implemented`: code conforms, behavior-derived tests exist, and required validation passed. Only `/spec-impl` establishes it.
- Editorial changes preserve status.
- New behavior follows `Draft → Approved → Implemented`.
- Changed behavior follows `Implemented|Approved → Review → Approved → Implemented` when the proposal is saved before acceptance.
- If a revision is rejected, restore the recoverable accepted content and status.

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

## Canonical Use-Case Structure

````markdown
# [Use Case]

**Status:** Draft

## Goal

[One successful outcome from the primary actor's perspective.]

## Actors

- **Primary:** [Person, API client, scheduler, message producer, or external system]
- **Supporting:** [Other external participant, when relevant]

## Preconditions

- [State true before the interaction begins.]

## Trigger

[Observable event that starts the use case.]

## Behavior Diagram

```mermaid
[Optional sequenceDiagram, flowchart, or stateDiagram-v2 projection of the written behavior]
```

## Main Flow

1. [One observable actor action or system response.]
2. [Next atomic step.]
3. [Visible successful outcome.]

## Alternate Flows

### At Step [N] — [Expected Variation]

1. [Observable alternate behavior.]
2. [End the use case or resume at a named main-flow step.]

## Exception Flows

### At Step [N] — [Failure Condition]

1. [Observable failure handling.]
2. [What the actor receives or observes.]
3. [What state remains unchanged or is recovered.]

## Postconditions

### On Success

- [Guaranteed resulting state or observable result.]

### On Failure

- [Guaranteed unchanged or recovered state and error outcome.]

## Open Questions

- [Unresolved product decision.]
````

Always include Status, Goal, Actors, Preconditions, Trigger, Main Flow, and Postconditions. Include Behavior Diagram, Alternate Flows, Exception Flows, and Open Questions only when meaningful. Omit empty conditional sections.

## Writing Rules

- Keep one goal per file.
- Actors are external participants, not controllers, services, databases, internal workers, or UI components.
- Preconditions are true before step one; checks performed by the system belong in a flow.
- Main-flow steps are ordered, active, atomic, and externally observable.
- Alternate flows are expected variations; exception flows define meaningful visible failure behavior.
- Every alternate or exception names its main-flow divergence step and outcome.
- Postconditions state guarantees, including unchanged or recovered failure state.
- Put shared rules in Entity Model policies or constraints. Express interaction-specific behavior directly in flows and postconditions.
- Use concept and value-type names exactly as defined in `entity-model.md`.
- Do not include architecture, function names, tables, framework mechanics, implementation tasks, test cases, or a separate acceptance-criteria section.

A Behavior Diagram, when present:

- appears after Trigger and before Main Flow;
- uses `flowchart` for decision-heavy behavior, `sequenceDiagram` for participant exchanges and ordering, or `stateDiagram-v2` for lifecycle transitions;
- is limited to one diagram;
- is a projection of the authoritative textual flows;
- introduces no behavior absent from the text;
- maps every branch to a main, alternate, or exception flow;
- uses Entity Model terms and observable behavior;
- is checked with an available Mermaid renderer, or manually inspected with the missing renderer reported.

## Apply an Accepted Change

1. Re-read current files and recheck the next sequence.
2. For an ordinary create or revision, create or update only the selected use-case file. For an explicitly approved split, update the original file, create every approved split file with newly allocated append-only sequences, and update all corresponding catalog rows.
3. Add or update its domain-catalog row when the index or outcome changes.
4. Update a domain requirement only when the accepted behavior changes it.
5. Update the Entity Model only for the smallest concept, property, relationship, value type, policy, enumeration, or concept-constraint delta directly required by this accepted use case. If the change redefines domain scope, restructures the Entity Model, changes shared terminology, or affects multiple use cases, stop and return to `/spec-domain`.
6. Keep each normative statement in one layer: catalog requirement, Entity Model policy/constraint, or use-case flow/postcondition.
7. Preserve unrelated reviewed content.
8. Make no application-code or test changes.

## Validation

- Status is exactly `Draft`, `Review`, `Approved`, or `Implemented`.
- `Approved` and `Implemented` contain no `## Open Questions` heading.
- `Draft` is a new unaccepted use case; `Review` is an unaccepted revision.
- The file has one observable goal and every required section.
- Flow steps are observable and atomic.
- Every branch identifies its divergence and outcome.
- Success and failure guarantees are explicit.
- Terminology matches the Entity Model, and every referenced non-primitive type or concept is defined there.
- Use-case flows and postconditions do not duplicate Entity Model policies.
- Domain requirements are elaborated rather than copied.
- Mermaid syntax and text/diagram consistency are checked when a diagram exists.
- Catalog links resolve and sequence rules hold.

## Handoff

Report the classification, behavioral delta, files changed, resulting status, assumptions, unresolved questions, recoverability check for saved `Review`, and validation performed. Direct accepted behavior or implementation drift to `/spec-impl`.
