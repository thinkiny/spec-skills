---
name: spec-impl
description: Capture existing code paths with or without a paired use case, implement approved behavior, verify conformance, and refresh or reshape implementation records without repeated repository-wide discovery.
user-invocable: true
argument-hint: "<domain> [sequence or capture request]"
---

# Implement Use Case

Implement one reviewed use case through cohesive, reviewable implementation batches. The matching implementation record is the durable code-path context: it records current entry points, symbol-level flows, locations, material state boundaries or constraints, and focused tests. A batch contains one or more vertical behavioral increments, each associating its production-and-test scope or existing conformance evidence with a discriminating proof, and is the largest set that can be safely approved and executed without another product decision or material replan. Accepted specifications define intended observable behavior; implementation records, code, and tests describe observed implementation.

## Input

The user supplies a domain and three-digit use-case sequence, for example `provider-admission 001`. Resolve that pair to exactly one `docs/spec/<domain>/<sequence>-<slug>.md` path; reject a missing or ambiguous sequence instead of guessing a slug. Its paired implementation-record path is `docs/spec/<domain>/implementation/<sequence>-<slug>.md`. Do not accept a use-case path, slash-form identifier, use-case name without a sequence, or current-open-file fallback. For unpaired Capture, accept only a domain plus an explicit implementation-capture request instead of a sequence.

For existing code with no use case, accept a domain plus an implementation-capture request. Resolve the domain foundation, inventory the requested public code path, and keep the proposed flow cards in conversation without writing an unpaired file. If `/spec-uc` originated the Capture, return the captured evidence to that existing workflow; otherwise offer direct continuation with `/spec-uc`. In either case pass the preserved workflow origin and a marker for the pending Capture. After `/spec-uc` creates and approves the use case and the user selects the named return, resume that pending Capture, resolve the final sequence and slug, revalidate the captured locations and tests, then save the paired implementation record and forward link together. Never allocate a use-case sequence or create a semantic use case in this workflow.

## Operating Modes

Select the first applicable mode below from repository state and the request. When another skill invokes `/spec-impl`, it supplies this mode as continuation intent; the command still resolves the use case by domain and sequence.

- **Removal:** the use case is an `Approved Removal` artifact. Remove the behavior and its proof, verify the required absence, then delete the paired specification and implementation records as one recoverable cleanup.
- **Reshape:** a resolved split or consolidation proposal over accepted use cases changes which paths will own existing implementation flows. Inventory the affected source records and current code, prepare the exact destination card set and links, write nothing, and return the prepared set to `/spec-uc` before final approval.
- **Execute:** accepted behavior is missing, incomplete, or drifting, including when code exists without an implementation record. Read and coverage-check the record when one exists; otherwise inventory the current flows as part of the approved code plan, create the paired record after the first verified implementation flow, then refresh the complete flow-card set. Execute takes precedence over Capture whenever behavior must change.
- **Capture:** existing code has no matching implementation record and no accepted-behavior drift is known. Inventory every current implementation flow, inspect each path once, verify available proofs, and create the matching record and use-case forward link without changing application behavior.
- **Refresh:** accepted behavior is not known to drift, but verified code changed and the existing record no longer navigates the current implementation accurately. Re-inventory the complete flow set, add or remove cards when entry or lifecycle paths changed, update affected cards, and verify available tests.
- **Verify:** code and its record appear complete and conforming. Confirm complete flow-card coverage first, then use the record's tests and focused locations for a verification-only batch.

Capture or Refresh may be part of an approved implementation batch, in which case that approval covers its record and forward-link changes. For standalone Capture or Refresh, present the exact card, forward-link, status, and validation changes. If the paired use case is `Implemented`, retain that status only after all Stage 6 conformance conditions pass; otherwise include a downgrade to `Approved` in the write set. Offer exactly one applicable save action plus **Stop without saving** through `AskUserQuestion`: use **Save implementation record** when status is unchanged, or **Save implementation record and mark Approved** when it is downgraded. Only the displayed save action authorizes writing.

Apply a standalone record, forward-link, and conditional status change as one recoverable complete write set: re-read both paired paths, capture their exact pre-images or nonexistence, apply the authorized set without interruption, and validate pairing, links, cards, status, and whitespace. If writing or validation fails, finish the exact set only when no new decision is needed; otherwise restore and validate every pre-image. Reshape is preparation only: it never writes code, use cases, or implementation records, and returns the exact prepared record set to its caller. A reconciliation-scoped Refresh may repair an observed-code record paired with a `Review`, but it changes only that record and its navigation link, never application code, semantic content, status, or conformance. When Capture begins before a use case exists, keep the inventory unpersisted until `/spec-uc` establishes the paired path, then revalidate it and use the same standalone save gate. When classification is uncertain or application behavior may change, use Execute and include the work in an implementation plan instead.

## User Decisions, Stage Gates, and Skill Continuation

Whenever this workflow needs a user choice or clarification for a complete current-batch plan, call `AskUserQuestion`. Give only needed context and concrete mutually exclusive options; recommend one only when repository or specification evidence supports it. For each independent implementation decision with two or more materially viable approaches, ask the user before completing the plan, put the evidence-backed recommendation first with `(Recommended)`, and wait for the answer. Ask up to three independent decisions together when the host supports it; otherwise ask them in sequence. These choices determine the plan but do not authorize implementation; plan approval does that. When a decision has only one materially viable approach, state why and proceed without inventing a choice. Do not bury choices in narrative, risks, or the completion report, or ask the user to decide established facts.

Use the host-provided **Other** response for free text; do not define a duplicate option. At an authorization gate, only selection of the named action authorizes it; otherwise treat entered text as feedback or an alternative proposal.

An actionable stage gate is a point where the user must authorize a persisted state transition, choose whether work advances, or transfer control to another specification skill. Use `AskUserQuestion` at every actionable stage gate except approval of a completed current-batch plan. Each batch uses the host's native plan-and-approval mechanism, or the defined fallback when it is unavailable, and must not receive duplicate approval. Narrative text alone never authorizes any other advancement. Approval authorizes every increment explicitly named in that batch plan, but no later batch. After approval, execute the batch's increments and their validation gates without another prompt unless a material replan or new decision is required. If accepted behavior remains afterward, prepare the next cohesive batch plan and obtain fresh plan approval before editing for that batch.

For a cross-skill handoff, ask whether to continue and name the target skill, artifact, reason, and recommended action. If the user selects the named continuation action, immediately invoke the target through the host's skill mechanism with the resolved path and intent. Never invoke another skill merely because it appears relevant. If invocation is unavailable or permission is denied, preserve the current state, report the limitation, and provide the exact manual command as a fallback. Preserve the workflow origin and intended return target separately from the immediate caller. An unpaired Capture that originates in `/spec-impl` remains an implementation-originated run while it visits `/spec-uc`; the return resumes that run and does not make `/spec-uc` its new return target. Preserve `/spec-uc`, `/spec-domain`, or `/spec-reconcile` as the return target only when that skill originated the workflow. When entered from `/spec-reconcile`, preserve its selected domain and base/ours/theirs/current evidence, never stage or continue the merge, and keep a reconciliation-scoped Refresh to the selected implementation record and navigation link.

Behavioral decisions belong in `/spec-uc`, and foundation decisions belong in `/spec-domain`. When either is required, use the consented cross-skill handoff instead of deciding it during implementation.

## Preconditions

1. Read `docs/spec/catalog.md`, `docs/spec/<domain>/domain.md`, `docs/spec/<domain>/entity-model.md`, the resolved selected use-case path or affected source and destination paths, and matching implementation records when present. Use the explicitly resolved `<domain>` and `<sequence>`; never resolve a domain document by basename alone. For unpaired Capture only, read the resolved domain foundation and defer use-case preconditions until `/spec-uc` returns an approved paired path. For Reshape, read every affected accepted baseline and source record plus the caller's resolved destination proposal, whether that proposal remains in conversation or is persisted as `Review`.
2. Read repository instructions and inspect working-tree changes.
3. Except for `Reshape` and a reconciliation-scoped Refresh of an existing record paired with `Review`, require `Approved` for new or changed behavior and for an `Approved Removal` artifact. Reshape may inspect accepted baselines and a resolved split or consolidation `Review` solely to determine destination ownership, but it must not edit or implement the proposal. Reconciliation-scoped Refresh treats the record only as observed-code evidence and does not implement the pending proposal.
4. Accept `Implemented` only for conformance checking, repair, or behavior-preserving work.
5. Except for `Reshape` and a reconciliation-scoped Refresh of an existing record paired with `Review`, reject `Draft`, `Review`, or any `## Open Questions` heading. Never remove or answer Open Questions; use `AskUserQuestion` to offer direct continuation with `/spec-uc` so it can resolve them and establish `Approved`. Reshape may read only the caller's resolved split or consolidation proposal and its captured accepted baselines; reject an unresolved proposal or any `## Open Questions`, and never write or implement the `Review` target. Reconciliation-scoped Refresh preserves the `Review` artifact and its open questions unchanged.
6. Classify a file as an `Approved Removal` artifact only when it contains exactly one H1, exactly one visible `**Status:** Approved` line, the canonical `Implementation` line exactly when a matching record exists, exactly one `## Approved Removal` section, exactly one `Interaction to remove`, `Required observable absence`, and `Final verification` field, no other sections, and no `## Open Questions` heading. If the heading or any removal field appears in a different shape, stop before planning and use `AskUserQuestion` to offer direct continuation with `/spec-uc`. For a valid artifact, plan against the required absence and skip the normal structure checks below.
7. For every normal use case, require:
   - exactly one Status line and one Goal, Actors, Preconditions, Trigger, Behavior Diagrams, Flow, and Postconditions section;
   - Behavior Diagrams between Trigger and `## Flow`, with one `### Overview` Mermaid block and no more than three named process diagrams; and
   - ordered normal steps with inline branches at their divergence points, each ending with a Resume, Continuation, or Outcome.
   For a structurally incomplete artifact, stop before planning and use `AskUserQuestion` to offer direct continuation with `/spec-uc`.
8. Confirm a normal file covers one complete externally meaningful primary-actor goal. If it is only an endpoint, button, CRUD operation, validation, internal component, or flow-step fragment—or if it bundles independent goals, triggers, or outcomes—stop before planning and use `AskUserQuestion` to offer direct continuation with `/spec-uc`. Do not split, merge, or compensate for its boundary during implementation.

Items 3–8 apply after a use case exists. Unpaired Capture may inspect and verify existing code, but it may not change application code, create an implementation-record file, claim conformance, or assign status before `/spec-uc` establishes the accepted contract.

After a paired use case exists, confirm it is linked under at least one existing requirement in the domain document. A missing or stale owning-requirement link is foundation drift; stop before planning and use `AskUserQuestion` to offer direct continuation with `/spec-domain`.

If requested behavior is absent or implementation discovery exposes a missing product decision, stop dependent work and use `AskUserQuestion` to offer direct continuation with `/spec-uc`. Never modify a specification to rationalize accidental code behavior.

## Specification Authority and Conflicts

Accepted specifications govern intended behavior. Repository rules and architecture govern implementation choices, and code and tests establish observed implementation; they do not override an accepted contract. Treat a mismatch as implementation drift.

If specification artifacts conflict, stop before planning or editing implementation and identify the exact contradiction. For a product-definition, domain-boundary, requirement, Entity Model, cross-use-case invariant, or shared-terminology conflict, use `AskUserQuestion` to offer direct continuation with `/spec-domain`. For a conflict in one interaction's goal, boundary, flow, outcome, or status, use `AskUserQuestion` to offer direct continuation with `/spec-uc`.

## Implementation Record

One optional record pairs with one use case by identical sequence and slug:

```text
001-example.md
implementation/001-example.md
```

The record describes current code, never planned future code. It contains one required backlink and a complete set of human-readable flow cards. An implementation flow is a distinct externally entered or independently resumed runtime path required to realize the use case, such as a UI action through its API and backend, a command, a job or callback, an asynchronous worker, or a polling/resume path. Keep alternate and failure branches inside the owning card; do not create separate cards for internal helpers, architecture layers, or every branch.

```markdown
# [Use Case]

**Use Case:** [Use Case title](../NNN-use-case.md)

## [Implementation Flow]

**Specification flow:** [Relevant use-case heading](../NNN-use-case.md#relevant-heading)

| Item | Details |
|---|---|
| Entry | [Public endpoint, job, callback, command, or UI action and handler symbol] |
| Flow | [Concise symbol-level path using arrows] |
| Locations | [repository-relative/path](relative-link-from-this-record) — key symbols; ... |
| State | [Optional material reads, writes, transaction, cache, or event boundary] |
| Constraints | [Optional authorization, feature gate, compatibility, concurrency, retry, redaction, or partial-failure rule] |
| Tests | [Exact focused commands or named tests; or `Missing —` the specific unprotected flow] |
```

The file-level `Use Case` backlink is required, uses the use-case H1 as its label, and must target the paired root-level use case. The paired use case must contain exactly one forward link immediately below `Status`:

```markdown
**Implementation:** [Implementation record](implementation/NNN-use-case.md)
```

Create, update, or remove that line atomically with its record through the standalone recovery procedure above or the enclosing approved complete write set. Omit it when no record exists. It is navigation metadata, not implementation detail or semantic authority. `Specification flow` is optional per card and appears only when a unique relevant use-case heading exists; it is navigation, not a semantic identifier. `Entry`, `Flow`, `Locations`, and `Tests` are required for each card. `State` and `Constraints` are omitted when they add no useful implementation information.

Every current implementation flow has exactly one card, and no card describes a removed flow. A card begins at the real outer entry and crosses UI, transport, service, persistence, or external-integration layers needed to reach its result; do not start at a convenient backend boundary when the implemented flow begins in a UI or another caller. `Locations` contains portable Markdown links to existing repository files. Each link resolves relative to the implementation record, displays the repository-relative path, and is followed by the key symbols in that file. Do not use an unlinked code span, directory, glob, invented path, or line number as a location. `Tests` names focused proof for the whole card. If no such proof exists, keep the card and write `Missing — [specific uncovered flow]`; missing proof blocks `Implemented` status but never justifies omitting the flow.

Do not add source revisions, freshness labels, change history, behavioral prose already owned by the use case, placeholders, exhaustive call graphs, or other implementation detail to the use-case file.

When a record exists, first compare its card set with a targeted inventory of the use-case-relevant UI actions, API or command entries, dispatch points, workers, callbacks, and polling or resume paths. Only after coverage matches may each card's linked locations and tests become the discovery boundary for that flow. Search outside them to find an omitted or stale flow, resolve a missing symbol or concrete inconsistency, or follow a required dependency, and record why discovery broadened. When no record exists but code does, Capture mode performs the smallest complete set of end-to-end path traces needed to populate every card. An implementation record never overrides an accepted specification.

## Reshape Accepted Records

When mode is `Reshape`, the caller supplies the primary domain and sequence plus every affected source and destination path in the continuation intent. Read the resolved destination proposal, including a persisted `Review`, only as the already-decided ownership boundary. Inventory each affected source record and its current code, determine which complete flow card belongs to each destination use case, preserve cards that remain unchanged, and identify links and records to create, rename, or remove. Return the exact prepared record set, forward links, backlinks, fragment links, and validation results to `/spec-uc`. Do not allocate sequences, decide use-case semantics, write any file, or claim `Implemented` conformance. After `/spec-uc` applies the approved semantic write set, it owns applying the unchanged prepared record set atomically. Do not continue into the ordinary implementation-batch stages for Reshape.

## Stage 1 — Inspect and Select the Current Batch

Inspect enough of the complete use case and implementation-flow inventory to choose a cohesive implementation batch:

1. Derive the implementation responsibilities from the complete use case, then inventory every current outer entry and independently resumed runtime path with targeted searches for UI callers, route or command registration, dispatch, workers, callbacks, and polling or resume logic. Group architecture layers and branches into their owning end-to-end flows.
2. Read the matching implementation record when one exists. Compare its cards with the inventory and identify every missing, stale, split, or accidentally combined flow before using it as navigation context. Validate the use-case forward link, record backlink, fragment links, every linked location and named symbol, and each focused test or explicit `Missing` proof gap. If the record is absent but code exists, include the complete new record and forward link in the plan or capture-only outcome. If `Execute` has no record and no code exists yet, treat that absence as expected and include record creation with the first verified flow in the approved plan. Do not route that case through `Capture`. If no record is expected for the current operation, reject a stale or duplicate `Implementation` line and remove it only as part of the approved or standalone-gated write set.
3. Locate existing responsibilities, domain types, validation, error boundaries, reusable utilities, and relevant tests within the verified linked locations for each covered flow. Broaden only for an omitted or stale flow, a concrete inconsistency, or a dependency needed by the selected batch.
4. Compare current observable behavior with every relevant accepted specification: the root catalog, domain document, Entity Model, selected use case, and related accepted use cases whose contracts overlap.
5. For a normal use case, verify the required Behavior Diagrams overview is syntactically valid with an available renderer, or manually inspect it and report renderer unavailability. Verify any named process diagrams against the authoritative text; when they contradict it, use `AskUserQuestion` to offer direct continuation with `/spec-uc` before planning implementation.
6. Identify the accepted contract areas that remain unimplemented or unverified. Keep that whole-contract assessment in working context and use it to avoid arbitrary batch boundaries; do not turn the plan into a behavior-to-test inventory.
7. Identify each exact baseline and proof check. Run a baseline during discovery when it is safe and non-mutating, and use the observed result in the plan. If a valid baseline cannot safely run before approval, mark that verification row `Baseline after approval`, state the expected distinguishing result, and require plan revision if the observed result differs.
8. Identify every implementation-record card that the batch will add, remove, or refresh. A card changes when its entry, flow, linked locations or symbols, material state boundary, constraints, focused proof, or specification-flow link changes, or when complete-flow inventory finds a missing or stale card.
9. If implementation already conforms, select one verification batch containing the focused and final evidence needed to establish conformance and capture or refresh the complete record when necessary; do not manufacture production-code changes.
10. Otherwise choose the current implementation batch under the rules below.

### Batch and Increment Granularity

A behavioral increment is a coherent vertical production-and-test change that makes one observable contract result demonstrably true through a focused command or exact tool-driven check. When code already conforms, an increment may instead be verification-only and contain no edit. A batch is one or more ordered increments covered by one plan and approval.

Choose the largest cohesive, reviewable batch that can be safely implemented and validated without another product decision or material replan. Prefer covering the complete remaining use case in one batch when its execution path, affected responsibilities, and validation are understood and bounded.

- **Group in one batch** increments that use the same public path, implementation responsibility, migration, fixture, or validation setup; represent normal, alternate, or exception branches of the same goal; or can be reviewed and validated together without an unsafe intermediate commitment. Independent provability alone is not a reason to require separate approval.
- **Split into a later batch** only when the later work depends on evidence from the current batch, needs an unresolved product or non-routine architectural decision, has a materially different blast radius or recovery boundary, requires an intermediate state to be reviewed, or would make the current plan too broad to review reliably.
- **Group within one increment** behavior that shares an atomic state transition or has no meaningful passing intermediate state.
- Never split by file, architecture layer, implementation step, normal-versus-error path, or “tests first, code later.” Every implementation increment contains its discriminating behavioral test and required production change; a verification-only increment contains its focused proof and no production edit.
- Use no file-count, line-count, step-count, or one-outcome-per-plan target. The boundaries are cohesive implementation and safe review, not minimum size.
- Prefer the user-reported regression or requested missing result first in execution order, while including related understood behavior in the same batch when the grouping rules support it.
- A verification-only batch is valid when code already conforms or only conformance evidence is missing.

Examples:

| Situation | Batch Boundary | Increment Structure |
|---|---|---|
| Success, validation failure, and permission denial share one service entry path | One batch unless a branch needs a separate decision or recovery boundary | Separate focused increments or tests may prove each branch under the same approval |
| Behavior requires an inseparable schema transition | Migration, compatible behavior, and end-to-end validation in one batch | Use one atomic increment when no valid intermediate state exists |
| A later external integration depends on results from a local state change | Split after the local batch because the next scope cannot yet be planned reliably | Prove the local behavior, then plan the integration from observed evidence |
| One visible regression sits in an otherwise understood use case | Include the regression first plus related bounded conformance work | The regression keeps its discriminating test and focused gate |

Before proposing the current-batch plan, state the implementation gap, its owning responsibility, and any blocker in one concise paragraph. If the code already conforms, state what evidence is missing. If the implementation path, required behavior, ownership, scope, or decision is ambiguous or vague, stop and use `AskUserQuestion` to resolve it before proposing the plan. Do not repeat the execution path, behavior contract, test inventory, or plan scope. If this exposes a missing behavioral decision, domain boundary, Entity Model rule, or shared invariant, stop and offer the appropriate `/spec-uc` or `/spec-domain` continuation before proposing a plan.

### Plan

After that paragraph, present only:

```markdown
# [Outcome]

## Decision

- **Constraints:** [Relevant specification, repository, compatibility, and validation constraints.]

## Approaches

### [Decision]

| Selection | Approach | Benefits | Costs / Risks | Reason |
|---|---|---|---|---|
| YES | [Chosen approach] | [...] | [...] | [Why the user chose it.] |
| NO | [Alternative] | [...] | [...] | [Why it was not chosen.] |

[Or: `None — existing architecture and repository rules determine the implementation; no user choice is required.`]

## Flow Changes

- **Before:** [Current code-level control or data path through the affected symbols.]
- **After:** [Proposed code-level path and the precise changed handoffs, branches, or state transitions.]
- **Unchanged:** [Important adjacent responsibility or boundary that remains untouched.]

## File Changes

| Kind | File | Planned Change |
|---|---|---|
| [New / Modify / Rename / Delete] | `[path]` | `I1 — [Observable result]:` [Exact symbols, logic, tests, configuration, migration, or references affected.] |

## Verification

| Check | Expected |
|---|---|
| `I1 baseline — [command or tool-driven check]` | [Observed distinguishing result, or `Baseline after approval` and the expected current result.] |
| `I1 proof — [command or tool-driven check]` | [Expected passing result that proves the increment.] |
| `Final — [broader coexistence or public-path check]` | [Concrete completion result, or omit when increment proofs are sufficient.] |

## Next

- **After approval:** [Implementation and proof order.]
- **Later work:** [Accepted work excluded from this batch, or none.]
```

List file changes in execution order and give every affected path its own row, including the implementation-record path and the selected use-case path when its status may change. Use `New`, `Modify`, `Rename`, or `Delete` for `Kind`; for a rename, show `[old path]` → `[new path]` in `File`. Start every `Planned Change` with a stable increment label and its observable result, and reuse that label across all production, test, migration, configuration, implementation-record, and specification rows belonging to the increment. Identify exact existing symbols, tests, or responsibilities when known, and never invent line numbers. Describe the crucial logic, data, interface, configuration, migration, test, flow-card, and reference changes precisely enough for the complete plan to be reviewed before editing. If an affected path or symbol is still unknown, continue inspection before submitting the plan.

Keep `Flow Changes` at the code level. Show how control or data moves through named symbols and where the implementation changes; when there is no material flow change, state `None` and name the localized responsibility instead. Do not include `Context` or `Contract Slice`, and do not restate accepted behavior except for one concise rationale when needed to understand an implementation choice. For a verification-only batch, state `None` for the flow and file changes and identify the existing checks being run.

For every increment, include one baseline row and one executable focused-proof or exact tool-driven behavioral-check row in `Verification`, using the same stable label as `File Changes`. Record the observed discovery result in the baseline row; when it cannot safely run before approval, write `Baseline after approval` and state the expected current result. Compilation or inspection alone is insufficient when behavior can be exercised. Include a `Final` row only when a broader check is needed to prove the increments coexist. Do not include an exhaustive execution-path narrative, full behavior-to-test matrix, or speculative risks and non-goals. In `Approaches`, use one named subsection per independent decision. Complete each subsection only after `AskUserQuestion` resolves it: put `YES` on its chosen approach and `NO` on each unchosen alternative. Each decision group has one `YES`; multiple independent groups may therefore contain multiple `YES` rows overall. If the user proposes a new approach, revise that decision group and ask again. `YES` records the user's approach choice, not implementation authorization. For a decision with only one materially viable approach, replace its table with one sentence naming it and why no meaningful alternative exists. When no implementation decision exists, write `None — existing architecture and repository rules determine the implementation; no user choice is required.` Plan approval remains required before implementation.

Use the host's native plan-and-approval mechanism when available. This is the sole actionable gate that does not use `AskUserQuestion`; do not duplicate current-batch approval through `AskUserQuestion`. If native plan approval is unavailable, stop before editing and use one `AskUserQuestion` with the named actions **Approve implementation plan** and **Stop without implementing**; only the approval action authorizes editing. A batch plan is a transient planning record, not a `docs/spec` artifact; do not store it under `docs/spec`. Do not edit code, tests, or status before approval. If baseline discovery requires a material scope change or decision, resolve it through `AskUserQuestion` when it is genuinely the user's choice, then refresh approval for the revised batch before resuming dependent work.

## Stage 2 — Establish the Current-Batch Baseline

After approval:

1. Re-read only files that can affect the approved batch and confirm its increments, file set, and boundary are unchanged.
2. For each increment in execution order, run its exact baseline check before the corresponding production change and record pre-existing failures separately.
3. When unmet behavior can be protected before the production change, add or update its behavioral test first, run it, and confirm it fails for the expected behavioral reason. This test work is part of the approved vertical increment, not a separate increment or approval cycle.
4. When a durable automated test cannot precede the production change, exercise the installed or public path with the approved exact check and record the distinguishing current result.
5. If an `Implemented` use case is confirmed not to match code or lacks required behavior-derived protection, change it to `Approved` before repair. If repair becomes blocked, leave it `Approved` rather than claiming conformance.

If a baseline does not distinguish its target result, stop dependent editing. Substitute an equivalent check without new approval only when the observable result, responsibility, planned files, and validation layer remain unchanged; report the substitution. Otherwise revise the current-batch plan and obtain fresh plan approval. Do not turn the other approved increments into separate plans merely because one baseline needs correction.

## Stage 3 — Implement the Current Batch

- Follow repository architecture, naming, error-handling, compatibility, and testing rules.
- Execute the approved increments in their planned dependency order, proceeding between them without another approval gate.
- Reuse the responsibility that already owns each behavior.
- Change only what the approved batch and its focused proofs require.
- Keep each behavioral test and its production change in the same increment.
- Preserve explicit failure behavior, unchanged-state guarantees, unrelated architecture, and user changes.
- Do not implement work assigned to a later batch merely because nearby files are open.
- Do not add behavior absent from the approved contract or numeric use-case metadata solely for traceability.
- If a missing product decision appears, stop dependent work and use `AskUserQuestion` to offer direct continuation with `/spec-uc`. Complete only other approved increments that are genuinely independent of that decision. Resume dependent work only after the specification is accepted and the affected batch plan receives fresh plan approval as needed.
- Do not write planned future paths into the implementation record. Refresh an affected card only after its production path and focused proof establish the current implementation.

## Stage 4 — Prove the Current Batch

Use the smallest layer that proves each approved increment:

- pure rule: focused unit test;
- service, persistence, API, event, or job behavior: integration or public-entry-path test;
- UI behavior: component/integration test, with browser E2E only when browser behavior matters;
- dispatch, retry, callback, or routing behavior: installed/public dispatch-path test.

Run an increment's focused proof as soon as its production-and-test change is complete. When it passes, continue directly to the next approved increment. After all increment gates pass, run the planned coexistence check. Tests assert observable behavior and postconditions rather than private structure. Confirm each protected test would fail if its implemented behavior were removed or broken. Report exact results and distinguish pre-existing, introduced, skipped, and unavailable checks.

After a card's current production path is confirmed, create or refresh it with the verified `Entry`, `Flow`, linked `Locations` and symbols, optional `State`, optional `Constraints`, and `Tests`. When focused proof is missing, record the exact `Missing` gap and keep the use case `Approved`; do not omit the card. Create or repair the use-case forward link in the same write set. Re-read every linked file and symbol and every command recorded in the card. Remove obsolete locations, tests, and cards; do not keep planned or historical alternatives.

A failure may be repaired within the approved batch when the planned observable result, owning responsibility, file set, and validation boundary remain unchanged. An unplanned observable result, additional responsibility, materially different proof layer, expanded recovery boundary, or other change that invalidates batch review requires a revised current-batch plan and fresh plan approval. Independent focused proofs inside the approved scope do not.

## Stage 5 — Close the Batch and Select What Remains

After all approved increment gates pass:

1. Compare each resulting observable behavior with its planned result and done condition.
2. Run the batch coexistence check when one was planned.
3. Recompute conformance against the complete accepted use case, owning requirements, applicable Entity Model rules, overlapping accepted contracts, and the refreshed complete implementation-flow inventory.
4. Report the completed work compactly:

```markdown
# Outcome

## Result

[Completed, partially completed, blocked, verification-only, or already conforming.]

## Verification

- **Focused proofs:** [Ordered commands or checks and results.]
- **Final validation:** `[Command or check]` — [Result, or not needed.]
- **Conformance:** [Complete, remaining contract, or blocked evidence.]

## File Changes

[Paths, or none.]

## Next

- **Remaining work:** [None or explicitly deferred work.]
- **Current status:** [Approved, Implemented, or Removed, with reason.]
```

5. For new, changed, or repaired behavior, keep the use case `Approved` while any accepted contract area remains unimplemented or unverified. An existing `Implemented` use case may retain that status during a verification-only batch only until drift or missing required evidence is found; then change it to `Approved`. Passing one batch never newly establishes `Implemented` without complete conformance verification.
6. If accepted work remains outside the approved batch, select the next cohesive batch under Stage 1, present its plan, and obtain fresh plan approval. Do not duplicate that approval, and do not create one plan per outcome when the remaining work can be safely reviewed together.
7. If no work remains, proceed to final conformance verification and status calculation.

## Stage 6 — Verify Complete Conformance and Update Status

Only after no contract area remains, review the final implementation against:

- domain scope and owning requirement capabilities, guarantees, and constraints;
- applicable Entity Model property constraints and concept invariants;
- actors and their access context;
- every precondition and the trigger;
- every normal flow step and meaningful inline alternate or exception branch;
- success and failure postconditions; and
- Required Behavior Diagrams overview, named process diagrams, Mermaid validity, and text consistency for a normal use case.

Compilation or inspection alone does not establish conformance when behavior-derived tests are required. Run the smallest final broader validation needed to show the increments coexist and the public execution path remains valid.

Promote `Approved` to `Implemented` only when:

- production code conforms to the complete accepted contract;
- behavior-derived tests protect applicable flow steps and branches, property constraints, concept invariants, and outcomes; and
- the paired implementation record contains exactly one card for every current implementation flow and no stale card; every card starts at its real outer entry, every `Locations` link resolves to an existing repository file and names existing symbols, and no `Tests` field reports `Missing`;
- the use case has exactly one resolving `Implementation` link immediately below `Status`, the record has exactly one resolving `Use Case` backlink, and every optional fragment link resolves; and
- every required focused and final validation passes.

If evidence is incomplete, leave `Approved`. A behavior-preserving refactor may retain `Implemented` after tests pass. `Implemented` does not mean deployed, enabled in production, operationally healthy, or free from every defect.

For an `Approved Removal` artifact, behavior and test removal may span multiple approved batches, but preserve the artifact, matching implementation record, forward link, and other references until the required observable absence is verified. Make final specification cleanup its own approved batch because it has a distinct recovery boundary. Treat that cleanup as one recoverable complete write set: inventory every `docs/spec` reference to the artifact and record, re-read every target, and capture exact pre-images or nonexistence before the first specification write. Delete the artifact and matching record together, remove its owning-requirement links, and remove or safely rewrite every other reference without changing unrelated semantics. Then run the batch's planned behavioral checks plus specification structure, pairing, forward-link, backlink, fragment-link, and whitespace validation against the final state. If any cleanup or post-cleanup validation fails, finish the exact set only when no new decision is needed; otherwise restore and validate every pre-image. Until the complete set passes, preserve or restore the artifact, record, forward link, and other references so interrupted work remains recoverable. Report the final result as `Removed`; no status or implementation-record file remains.

## Final Completion Report

Use this report only after complete conformance verification, completed removal, or a blocker that requires whole-contract accounting. Do not repeat it after each successful batch.

```markdown
# Outcome

[Completed, partially completed, blocked, or already conforming.]

## Specification Conformance

| Contract | Implementation and Test Evidence |
|---|---|
| Owning requirement contract | [Evidence] |
| Actors | [Evidence] |
| Preconditions and Trigger | [Evidence] |
| Normal flow steps and inline branches | [Evidence] |
| Postconditions | [Evidence] |
| Entity Model property constraint or concept invariant | [Evidence] |

## Changed Files

## Validation Results

## Remaining Issues

## Final Status

[Approved, Implemented, or Removed, with reason.]
```

Do not create a separate implementation-status file, dashboard entry, persistent project plan, duplicate catalog status, or requirement map. The paired implementation record is code navigation and proof context, not a status dashboard or semantic contract. When completion or a blocker creates an actionable specification next step, offer a named continuation with `/spec-uc`, `/spec-domain`, or `/spec-reconcile` through `AskUserQuestion`. Invoke the selected skill with the artifact and reason only through that named action; provide an exact command only when invocation is unavailable or denied.

Route completion by the preserved workflow origin, not by the skill that immediately invoked the current run. When `/spec-uc` originated a paired or unpaired Capture or a Reshape, offer **Return to `/spec-uc`** with the resolved evidence, saved record, or prepared record set. When `/spec-domain` originated the selected member, offer **Return to `/spec-domain`** with its domain, sequence, resulting status, changed paths, and validation. When `/spec-reconcile` originated the issue, offer **Return to `/spec-reconcile <domain>`** with the domain, sequence, changed paths, and validation. A direct unpaired Capture that temporarily continued through `/spec-uc` finishes in its resumed `/spec-impl` run and does not return to `/spec-uc` again. The return target rediscovers its remaining scope before selecting another operation; a directly invoked workflow has no return action.
