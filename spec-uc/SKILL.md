---
name: spec-uc
description: Create, revise, split, consolidate, rename, or review one observable system use-case goal inside an existing docs/spec domain. Use when invoked directly or continued after explicit user consent from another specification skill to specify behavior, consolidate overlapping use cases, resolve ambiguity, compare a reported bug with the specification, or prepare behavior for implementation.
user-invocable: true
argument-hint: "<domain> [request]"
---

# Specify Use Case

Create or revise one system use-case goal without changing application code or tests. One artifact normally describes the interaction; this skill may also consolidate multiple overlapping artifacts into one goal after semantic review. Foundation-led coordinated sets remain owned by `/spec-domain`.

## Input

The user supplies a domain and a free-form request; the request need not name a use case. Infer the target from the request, current context or open file, and repository evidence. If one target is clear, proceed; otherwise use `AskUserQuestion` to offer concrete use-case choices before discovery or writing. A consolidation request may resolve to multiple targets. If a specification cannot be found, try the current open file before asking for its path.

## User Decisions, Stage Gates, and Skill Continuation

Call `AskUserQuestion` whenever a user decision is needed before recording behavior as settled. Give only needed context and concrete mutually exclusive options; recommend one only when repository or specification evidence supports it. Do not ask the user to decide repository facts or leave actionable choices in a summary. **For every semantic change that needs a decision, call `AskUserQuestion` and wait for the answer before using Write/Edit on any specification file.** At final review, offer **Mark Approved** and **Keep Draft/Review**; free text revises the proposal.

Use the host-provided **Other** response for free text; do not define a duplicate option. At an authorization gate, only selection of the named action authorizes it; otherwise treat entered text as feedback or an alternative proposal.

An actionable stage gate is a point where the user must authorize a persisted state transition, choose whether work advances, or transfer control to another specification skill. Use `AskUserQuestion` at every actionable stage gate; narrative text alone never authorizes advancement. A semantic-answer question authorizes a corresponding persisted `Draft` or `Review` update only when the question explicitly says that selecting the answer will write that update. After an authorized working-artifact update or final approval, deterministic writing, validation, recovery, and status calculation continue without another prompt unless a new decision appears.

For a cross-skill handoff, ask whether to continue and name the target skill, artifact, reason, and recommended action. If the user selects the named continuation action, immediately invoke the target through the host's skill mechanism with the resolved path and intent. Never invoke another skill merely because it appears relevant. If invocation is unavailable or permission is denied, preserve the current state, report the limitation, and provide the exact manual command as a fallback. When returning to `/spec-reconcile <domain>`, invoke it with the resolved domain so reconciliation rediscovers that scoped state.

## Preconditions

Read:

1. `docs/spec/catalog.md` for product context and path conventions;
2. `docs/spec/<domain>/domain.md`;
3. `docs/spec/<domain>/entity-model.md`;
4. related use cases;
5. repository instructions and relevant code, tests, and documents as evidence.

For a new or reconstructed use case, trace the installed or public entry path through its primary decision logic: validation, authorization, state changes, external effects, retries, and visible failures. Distinguish observed implementation from intended behavior, and surface any mismatch for review. Translate confirmed behaviorally material logic into one integrated flow whose normal steps carry inline alternate and exception branches, followed by postconditions; do not persist function names, architecture, or private control flow.

If the domain document or Entity Model does not exist, stop without writing and use `AskUserQuestion` to offer direct continuation with `/spec-domain` for the resolved domain path.

Every use case must be linked under at least one existing owning requirement in the domain document. If no existing requirement owns the proposed goal, stop before writing and use `AskUserQuestion` to offer direct continuation with `/spec-domain`; do not create a requirement in this workflow.

When this skill is invoked to resolve a conflicting `Draft` or `Review` that blocked `/spec-domain`, read the blocker context and accepted foundation proposal from the current conversation. Change only the proposal through the ordinary workflow; do not review or apply accepted coordinated members here. After the blocker is resolved, use `AskUserQuestion` to offer direct continuation back to `/spec-domain`, which must rediscover the complete affected set before approval.

## Specification Authority

The presence of `docs/spec/catalog.md` means the project has adopted this workflow. Within `docs/spec/`:

- The root catalog, domain documents, and Entity Models are the reviewed foundation.
- `Approved` and `Implemented` use cases are accepted implementation contracts.
- `Draft` and `Review` use cases are authoritative records of proposals, but they are not implementation targets.
- Code and tests describe observed implementation. If they differ from an accepted specification, classify the difference as implementation drift; do not rewrite intended behavior to match accidental code.

If specification artifacts conflict, stop and identify the exact contradiction for human resolution. For a foundation, domain-boundary, requirement, Entity Model, cross-use-case invariant, shared-terminology, or multi-use-case conflict, use `AskUserQuestion` to offer direct continuation with `/spec-domain`. Resolve a conflict limited to this interaction's goal, boundary, flow, outcome, or status in the current workflow.

## Classify the Request

| Situation | Action |
|---|---|
| New observable goal | Offer **Save Draft** with the next sequence or **Stop without saving**, then follow Draft and Review Iteration. |
| Intended behavior changes to an `Approved` or `Implemented` use case | Capture the exact current accepted content and status; then offer **Save Review** or **Stop without saving**. |
| Existing persisted `Draft` or `Review` | Follow Draft and Review Iteration. |
| Wording changes without behavioral effect | Apply a focused editorial edit and preserve status. |
| Title or path rename without behavioral effect | Preserve sequence and status; move the file and update all `docs/spec` references as one complete write set. |
| A requested rename changes the actor goal, boundary, or behavior | Treat it as a semantic revision; move the working artifact only after the user selects the named rename action. |
| One file contains multiple independent goals | Prepare and gate one recoverable `Draft` or `Review` split set; retain the original sequence for the closest goal. |
| Multiple files may describe one actor goal | Re-read the complete candidate set and follow Consolidate Similar Use Cases; never treat another skill's proposal as proof. |
| Current use case already states the desired behavior | Treat the problem as implementation drift and use `AskUserQuestion` to offer direct continuation with `/spec-impl`. |
| New, unimplemented persisted `Draft` is no longer wanted | Use `AskUserQuestion` to offer **Delete Draft**; only that selection deletes its file and owning-requirement links while leaving the sequence gap. |
| Existing persisted `Review` is rejected or abandoned | Use `AskUserQuestion` to offer **Abandon Review**; only that selection restores the captured accepted baseline and its links. |
| `Approved` or `Implemented` behavior should be removed | Create or update a `Review` negative contract when an observable rejection or unavailable result remains; otherwise finalize an `Approved Removal` artifact after the required gates. |

When uncertain whether actors, permissions, preconditions, trigger, flow steps or branches, outcomes, rules, or scope change, treat the edit as semantic.

## Bound the Use Case

Use one externally meaningful goal of one primary actor as the boundary:

1. Identify the external primary actor and a goal that actor can recognize as valuable.
2. Start with the observable trigger and end with meaningful success and failure postconditions.
3. Keep alternate branches, retries, validation failures, permission failures, and other visible failures in the same use case when they serve that goal.
4. Do not split merely because behavior crosses endpoints, buttons, CRUD operations, screens, internal components, validations, or flow steps.
5. Split when a goal, trigger, or outcome is independently initiated, independently valuable, or independently reviewable and implementable.
6. When uncertain, ask whether the proposed fragment still delivers actor value when separated from the surrounding interaction.

| Boundary | Example |
|---|---|
| Too fine | Validate an address, click **Save**, or call the address endpoint. |
| Appropriate | A customer changes a shipping address, from submitting the replacement through confirmation or a visible failure with unchanged state. |
| Too broad | Manage an account by combining address changes, password changes, and account closure. |

Expected variants and visible failures belong as inline alternate or exception branches beneath the flow step where they diverge when they serve the same goal. Shared invariants belong in the Entity Model, and domain-wide obligations belong in domain requirements; neither is a reason to manufacture a cross-cutting use case.

## Draft and Review Iteration

Persist a new use case as `Draft` or an accepted-use-case revision as `Review` only after the applicable named save action. A semantic-answer question may replace that save gate only when it explicitly says which `Draft` or `Review` paths selecting the answer will write. Update working artifacts incrementally with confirmed behavior; write a resolved answer into its behavioral section, and keep only deferred or still-insufficient matters in `## Open Questions`. Resolve every open decision before offering approval.

Before overwriting an accepted artifact with `Review`, capture its exact current content and prior status. If the baseline is missing or ambiguous, keep the accepted file unchanged and discuss the proposal without persistence. Retain the captured baseline throughout the Review so abandonment can restore it exactly.

Use this concise summary at the start of a new working artifact, when scope changes, or when a material decision needs review:

```markdown
# Use Case Review: [Use Case]

## Classification and Boundary

## Proposed Behavioral Changes

- **Primary actor and goal:**
- **Preconditions and trigger:**
- **Success behavior and postconditions:**
- **Meaningful variants and visible failures:**

## Observed Current Logic

- **Public entry path, material decisions, validation, authorization, state changes, and external effects:**
- **Retries, visible failures, and differences from intended behavior:**

## Domain Impact

- **Owning domain requirement impact:** [Unchanged, or the exact `Capabilities`, `Guarantees`, or `Constraints` delta required by this use-case change and why.]
- **Entity Model impact:** [Unchanged, or the exact external concept, relationship, diagram, concept, property, invariant, or Shared Value Type delta required and why.]

## Decisions Needed

## Contradictions and Assumptions

## Affected Specification Paths
```

For removal with no enduring interaction, summarize the interaction to remove, its required observable absence, and the final verification needed before its file can be deleted and every `docs/spec` reference can be removed or safely rewritten.

The summary exposes material choices without reproducing the artifact. Do not print the complete artifact as response content; write only confirmed behavior, and keep only unresolved matters in `## Open Questions`.

After re-reading targets, compare the proposed use-case behavior with every owning requirement's `Capabilities`, `Guarantees`, and `Constraints` in the domain document. Record whether each owning requirement remains accurate; if not, identify the exact requirement delta as part of Domain Impact. Also prepare the remaining semantic delta without writing it. Ask and wait on every required decision before using Write/Edit. Update a `Draft` or `Review` only after its named save action or an answer that explicitly disclosed the update. Never preserve `Implemented` after a semantic revision.

A use-case-owned domain requirement or Entity Model delta remains an unpersisted part of the proposal while any member is `Draft` or `Review`. Rediscover it before final approval and include it in the approved write set. If it changes domain scope, shared terminology, Entity Model structure, or multiple use cases, continue through `/spec-domain` instead.

When all decisions are resolved, remove `## Open Questions` and offer **Mark Approved** or **Keep Draft/Review**; free text revises the proposal. Only **Mark Approved** authorizes finalization. Re-read the complete write set first; if a new decision appears, return it to the working artifact. Finalize every split member as one unit, and create an `Approved Removal` artifact only through the same approval gate.

### Complete Write Sets and Recovery

Treat every semantic operation that changes multiple paths—including creation and owning-requirement linking, rename, split, consolidation, deletion, abandonment, final approval, and a directly owned foundation delta—as one complete write set. Before its first write, re-read all targets, verify the authorized baseline and membership, and capture each exact pre-image or nonexistence. Apply and cross-validate the whole set. If a write or validation fails, finish that exact set only when no new semantics are needed; otherwise restore every pre-image and validate restoration. Report failed restoration as blocked and inconsistent.

## Status Rules

- `Draft`: an editable persisted new use case under discussion. It may contain `## Open Questions` and cannot be implemented.
- `Review`: an editable persisted revision to accepted behavior under discussion. It may contain `## Open Questions` and cannot be implemented.
- `Approved`: a human explicitly finalized and accepted the complete behavior, or a durable removal decision. It contains no `## Open Questions` heading.
- `Implemented`: code conforms, behavior-derived tests exist, and required validation passed. Only `/spec-impl` establishes it.
- A split of new work keeps every member `Draft`. A split of accepted work keeps every member `Review` until one **Mark Approved** action finalizes all members as `Approved`; prior `Implemented` status is re-established only by `/spec-impl`.
- An all-`Draft` consolidation remains `Draft`. An accepted consolidation finalizes the survivor as `Approved`; `/spec-impl` must re-establish any prior `Implemented` conformance.
- An accepted removal with no enduring interaction remains at its existing path as an `Approved Removal` artifact until `/spec-impl` verifies removal.
- Editorial changes preserve status. Abandoning a `Review` or Review split restores its captured accepted baseline and links and removes paths introduced only by that Review. If exact recovery is unavailable, preserve the working set and stop for human resolution.

Status appears as one visible line below the H1 and nowhere else:

```markdown
**Status:** Draft
```

Do not add frontmatter, owner, reviewer, date, version, deployment, progress, or status history to use-case files or domain documents.

## Sequence and Path Rules

- Files are `docs/spec/<domain>/<three-digit-sequence>-<kebab-case-slug>.md`.
- Allocate `max(existing numeric prefix) + 1`; treat an empty existing sequence set as zero, so the first sequence is `001`.
- Never fill a gap, reuse a deleted sequence, or renumber files.
- Keep the existing path for a focused revision or title improvement unless the filename becomes materially misleading.
- A sequence is local reading order and a stable link, not a globally tracked identifier.
- When splitting, preserve the original sequence for the closest existing goal.
- When consolidating, preserve the selected survivor's sequence and never reuse an absorbed sequence.

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

## Flow

1. [Currently confirmed normal step.]
   - **Alternate — [Expected variation]**
     1. [Observable branch step.]
     2. **Resume:** [Continue at step N.]
   - **Exception — [Visible failure]**
     1. [Observable failure handling.]
     2. **Outcome:** [End state or recovery result.]

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
- Preconditions are true before step one; checks performed by the system belong in the flow.
- Top-level ordered items form the normal path and are active, atomic, and externally observable.
- Place each expected variation or visible failure directly beneath its divergence step as a nested bullet labeled `**Alternate — [Name]**` or `**Exception — [Name]**`. When the same branch can diverge at multiple steps, place it beneath the earliest applicable step and name the complete step set or range in its label rather than duplicating the branch.
- When a branch diverges at the Trigger and cannot meaningfully attach to step 1, place it before the first normal step with the label `**Alternate at Trigger — [Name]**` or `**Exception at Trigger — [Name]**`.
- Give each branch a nested ordered list and finish it with exactly one explicit `**Resume:**`, `**Continuation:**`, or `**Outcome:**` statement. A branch that resumes names the top-level flow step; a branch that continues alongside other items states that continuation; a terminal branch states its observable outcome.
- Preserve top-level numbering for the normal path; nested branch steps do not renumber it.
- Postconditions state guarantees, including unchanged or recovered failure state.
- Put an always-valid rule involving multiple properties, states, or connected concepts under the owning concept's `#### Invariants`; keep a one-property rule in that property's `Constraints` cell. Express interaction-specific behavior directly in flow steps, inline branches, and postconditions.
- Use concept, property, and Shared Value Type names exactly as defined in `entity-model.md`.
- Do not include architecture, function names, tables, framework mechanics, implementation tasks, test cases, or a separate acceptance-criteria section.

Behavior Diagrams:

- appear after Trigger and before `## Flow`;
- contain one `### Overview` subsection with exactly one fenced `mermaid` block;
- may contain up to three named process subsections, each with exactly one fenced `mermaid` block, only when they simplify a complex nested process;
- use `flowchart` for decision-heavy behavior, `sequenceDiagram` for participant exchanges and ordering, or `stateDiagram-v2` for lifecycle transitions;
- project the authoritative textual flow;
- keep the overview compact by summarizing the normal path and material decisions rather than duplicating every inline branch;
- introduce no behavior absent from the text;
- map every diagram branch to a normal flow step or an inline alternate or exception branch;
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
- **Final verification:** [Observable evidence required before deleting this file and removing or safely rewriting every `docs/spec` reference.]
```

This is the only exception to the normal required use-case structure. It contains exactly one H1, exactly one visible `**Status:** Approved` line, exactly one `## Approved Removal` section, exactly one of each displayed field, no other sections, and no `## Open Questions` heading. Preserve the existing title, path, sequence, owning-requirement links, and other references while removal is pending. Do not include implementation design or status history. `/spec-impl` deletes the artifact and removes or safely rewrites every `docs/spec` reference only after removing the behavior and behavior-derived tests, verifying the required absence, and then validating the final specification state.

## Consolidate Similar Use Cases

Use this path only when the user directly requests consolidation or selects a `/spec-reconcile <domain>` consolidation review. The reconciliation proposal is evidence, not authorization or proof.

1. Re-read every candidate, its owning requirements, the Entity Model, related use cases, and relevant current code. Compare primary actor, actor-recognizable goal, trigger, success outcome, failure guarantees, and material flow overlap.
2. Consolidate only when the candidates express one externally meaningful goal and each unique behavior fits as a normal step, inline alternate or exception branch, or postcondition. Shared terminology, entities, requirements, implementation components, or adjacent steps are insufficient. Never consolidate an `Approved Removal` artifact.
3. If goals, triggers, or outcomes remain independently valuable, keep the artifacts separate and report why. Route any required foundation or multi-use-case invariant decision to `/spec-domain`.
4. Except for an all-`Draft` candidate, resolve or abandon every open `Draft` or `Review` before consolidation. For all-`Draft` candidates, present the proposed survivor and sequence, combined confirmed behavior, unresolved questions, absorbed paths, link and reference changes, and every behavior to preserve. Offer **Consolidate Drafts** or **Keep Drafts Separate**; free text revises the proposal, and consolidation never promotes status.
5. On **Consolidate Drafts**, use the complete-write-set procedure to write the combined survivor as `Draft`, remove absorbed Draft paths, replace their owning-requirement links with survivor links wherever they materially implement the requirement, and update every other `docs/spec` reference. Preserve every confirmed behavior and unresolved question from the source Drafts.
6. For accepted candidates, capture an exact accepted baseline for every path. Present the proposed survivor and sequence, combined observable behavior, absorbed paths, link changes, source statuses, resulting `Approved` status, and every behavior that must be preserved.
7. Keep every accepted source unchanged during discussion. Offer **Save consolidation Review** or **Keep Sources Unchanged**; only the save action may replace the proposed survivor with a Review backed by its captured baseline. Absorbed accepted paths and links remain until final approval.
8. On **Mark Approved**, use the complete-write-set procedure to write the survivor as `Approved`, remove absorbed specification paths, replace their owning-requirement links with survivor links wherever they materially implement the requirement, and update every other `docs/spec` reference. If any source was `Implemented`, `/spec-impl` must re-establish conformance.
9. Absorbing a redundant specification path does not remove product behavior. Preserve every accepted flow and outcome in the survivor; if observable behavior must disappear, use the `Approved Removal` workflow instead.
10. On abandonment, restore the survivor's exact baseline and leave every other source and link unchanged.

## Rename a Use Case

For a behavior-neutral title or path rename:

1. Re-read the use case, its owning requirements, and all `docs/spec` references.
2. Preserve sequence and status.
3. Treat the move, H1 change, and reference rewrites as one complete write set; leave neither an unintended old-path copy nor stale reference.
4. Resolve every changed link and confirm the old path is no longer referenced.

For a semantic rename, prepare the destination as part of the recoverable `Draft` or `Review` set. Move it only after the user selects the named rename action, and finalize it separately through **Mark Approved**.

## Update or Finalize a Use Case

1. Re-read targets, owning requirements, sequence allocation, and any accepted baseline. Compare the proposed use-case behavior with each owning requirement's `Capabilities`, `Guarantees`, and `Constraints`; explicitly classify the requirement contract as unchanged or identify the exact required delta. Prepare the remaining semantic delta without editing. Put resolved answers in their behavioral sections; keep only deferred or insufficiently answered matters in `## Open Questions`.
2. Use the named save action or an explicitly disclosed semantic-answer write before updating a `Draft` or `Review`. Save a new `Draft` and its nested owning-requirement links as one complete write set. Save a `Review` only after capturing its exact current accepted baseline.
3. When no open decision remains, verify structure and diagram consistency, then offer **Mark Approved**. Only that selection writes `Approved`.
4. For a split, gate and persist all members and links together. Preserve the original sequence for the closest goal and allocate new sequences for the others. Apply the split status and abandonment rules above.
5. For consolidation, follow Consolidate Similar Use Cases; never delete an accepted source before the complete set receives **Mark Approved**.
6. For an approved removal with no enduring interaction, write the `Approved Removal` artifact and preserve every `docs/spec` reference to it for `/spec-impl`.
7. Apply renames and reference rewrites through the complete-write-set procedure.
8. Keep the smallest directly required domain requirement or Entity Model delta unpersisted until **Mark Approved**, then include it in the final complete write set. Route a domain-scope, shared-terminology, structural Entity Model, or multi-use-case change to `/spec-domain` without writing it here.
9. Keep each normative statement in one layer, preserve unrelated reviewed content, and change no application code or tests.
10. After finalizing accepted behavior or an `Approved Removal`, or after identifying implementation drift, use `AskUserQuestion` to offer direct continuation with `/spec-impl`; invoke it only through the named continuation action.

## Validation

- Every actionable transition or cross-skill continuation was authorized by selection of its named `AskUserQuestion` action; narrative or free text did not advance the workflow.
- A semantic answer wrote a `Draft` or `Review` only when its question explicitly disclosed the affected persisted update.
- Every `Review` has one exact captured accepted baseline; abandonment restores it and its links, including removal of Review-only split paths.
- Every use-case semantic change was checked against each owning requirement's `Capabilities`, `Guarantees`, and `Constraints` in the domain document; Domain Impact explicitly records either no requirement change or the exact required delta.
- A `Draft` or `Review` contains confirmed behavior, keeps only unresolved matters in `## Open Questions`, remains ineligible for implementation, and does not persist a domain requirement or Entity Model delta.
- Every multi-path semantic operation was applied and cross-validated as one complete write set or fully restored from captured pre-images.
- No semantic specification file was written before its required decision and named authorization.
- Promotion to `Approved` occurred only after every decision was resolved and **Mark Approved** was selected.
- Foundation-led coordinated accepted members were neither reviewed nor written here; `/spec-domain` owns their combined review and application.
- A normal `Approved` use-case artifact conforms to the Canonical Working Use-Case Structure, Writing Rules, and Behavior Diagrams rules.
- A `Draft` or `Review` contains all currently confirmed sections and does not fabricate unresolved behavior to satisfy the template.
- The file spans one complete externally meaningful primary-actor goal from observable trigger through meaningful success and failure postconditions.
- Expected variants, retries, validation failures, permission failures, and other visible failures remain inline branches when they serve the same goal; independently valuable goals, triggers, or outcomes are split.
- The boundary was not created merely from an endpoint, button, CRUD operation, screen, internal component, validation, or individual step.
- For a new or reconstructed use case, the current public execution path and behaviorally material decisions were inspected; confirmed observable logic appears in the applicable normal steps, inline branches, and postconditions without implementation detail.
- Success and failure guarantees are explicit.
- Terminology matches the Entity Model, and every referenced non-primitive type or concept is defined there.
- Use-case flow steps, inline branches, and postconditions do not duplicate Entity Model property constraints or concept-local invariants.
- Domain requirements are elaborated rather than copied.
- Mermaid syntax and text/diagram consistency were checked with an available renderer, or manual inspection and renderer unavailability are reported.
- An `Approved Removal` artifact contains exactly its canonical H1, Approved status, section, and three fields, preserves its existing path and every `docs/spec` reference while pending, and has no other section or `## Open Questions` heading.
- A rename preserves sequence and status, updates the H1, every owning-requirement link, and every affected `docs/spec` reference, leaves no unintended duplicate, and resolves every changed link.
- A consolidation proposal was independently verified as one actor goal; shared vocabulary or implementation alone did not justify it.
- Accepted consolidation sources remained unchanged until final approval; the survivor preserves every accepted behavior, absorbed sequences are not reused, and deletion removes redundant specification paths rather than product behavior.
- Every use-case file is linked under at least one existing requirement it materially implements; every `Use cases` field in the domain document is a nested Markdown list with one link per bullet; all specification links resolve and sequence rules hold.

## Handoff

Report only a concise outcome with classification, confirmed behavioral delta, changed paths, resulting status, unresolved decisions, and validation. Do not echo complete specification contents. At final review, offer **Mark Approved** or **Keep Draft/Review**; free text revises the proposal and never approves. When an actionable next stage exists, offer direct continuation with `/spec-domain` or `/spec-impl`. Invoke the target only through the named continuation action; provide an exact command only when invocation is unavailable or denied.

When `/spec-uc` is continued from `/spec-reconcile <domain>` for a conflict or consolidation proposal, preserve the supplied domain and base/ours/theirs/current-worktree evidence. For conflicts, change only the selected semantic issue; for consolidation, independently verify every candidate and follow Consolidate Similar Use Cases. Never stage or complete the Git merge. Return the consolidation decision and evidence, then offer a named continuation back to `/spec-reconcile <domain>`; if selected, invoke it with the original domain so it rediscovers the scoped set without re-proposing an unchanged rejected group.
