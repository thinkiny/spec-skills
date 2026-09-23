---
name: spec-reconcile
description: Reconcile one docs/spec domain after or during a Git merge, preserving reviewed content while repairing deterministic domain-document, root-catalog entry, link, and concurrent use-case sequence conflicts, then identify use cases that may be consolidated. Use when explicitly invoked with a domain.
user-invocable: true
argument-hint: "<domain>"
---

# Reconcile Domain Specifications

Reconcile one `docs/spec` domain after or during a Git merge. This workflow owns deterministic structural repair only. `/spec-domain` owns foundation conflicts, and `/spec-uc` owns interaction semantics and any proposed use-case consolidation.

## Input and Scope

The user supplies an existing domain slug or `docs/spec/<domain>` path. Resolve exactly one existing domain directory; do not create or infer a missing domain. If the input is absent or ambiguous, ask which existing domain to use before inspecting merge cohorts.

The selected domain scopes the workflow:

- Read and write its domain document, Entity Model, and every use case.
- Read the root catalog and update only the selected domain entry when required.
- Read all `docs/spec` references to selected-domain paths. Outside-domain files may change only to rewrite a confirmed selected-domain path; preserve all other content.
- Leave every other domain, non-spec conflict, application file, and test untouched. Report relevant outside-scope conflicts without resolving them.
- Treat an inseparable root-catalog conflict or cross-domain semantic decision as a blocker; never widen scope silently.

Use the host-provided **Other** response for free text; do not define a duplicate option. At an authorization gate, only selection of the named action authorizes it; otherwise treat entered text as feedback or an alternative proposal. Free text may add evidence but never resolves semantics in this coordinator.

- Treat the committed merge base, merge parents, index stages, working tree, and staged, unstaged, and untracked selected-domain work as inputs.
- Before any write, record every coordinator-owned path, its exact content or nonexistence, and its index-stage identity.
- Never run `git add`, `git commit`, `git merge --continue`, `git checkout`, `git restore`, or any command that alters the index or discards content.
- Never resolve semantics by choosing ours, theirs, the base, the newest file, or a majority. Offer **Resolve through `/spec-domain`**, **Resolve through `/spec-uc`**, or **Stop and leave the domain unchanged**, as applicable.
- Invoke another skill only through its named continuation action. Preserve the selected domain in every handoff and return.
- Apply a complete deterministic write set or restore every captured pre-image. Never report partial repair as success.

## Stage 1 — Detect Reconciliation Mode

Read repository instructions, then detect the mode for the selected domain.

### Active Merge

When Git exposes merge state such as `MERGE_HEAD`, read:

- `git status --short` and `git ls-files -u`;
- `HEAD`, `MERGE_HEAD`, and their merge base;
- base/ours/theirs index stages for selected-domain paths, the selected root-catalog entry, and references to selected-domain paths;
- current staged, unstaged, and untracked versions of those paths.

Do not assume the working tree is a safe merge result. Leave outside-scope conflicts untouched.

### Completed Merge

For an unambiguous two-parent merge, compare the result with both parents and their single merge base. Treat multiple merge bases, more than two parents, or an ambiguous recent merge as provenance blockers.

### Audit Only

Without an active or unambiguous recent merge, audit current selected-domain structure. Use history only where provenance is clear; do not invent a branch cohort or reorder accepted use cases because their numbers are not globally chronological.

Never substitute filesystem timestamps for missing Git provenance.

## Stage 2 — Inventory and Classify

Read the complete selected-domain specification set and inventory:

- its root-catalog entry, domain document, and Entity Model;
- every use-case path, sequence, title, status, and body;
- owning-requirement links and all `docs/spec` references to selected-domain paths;
- duplicate sequences, missing or stale links, conflict markers, and malformed canonical structure.

Classify every difference before writing.

### Deterministic Reconciliation

A change is mechanical only when one exact result preserves semantic text and status, including:

- additive or byte-identical selected-domain content;
- the selected root-catalog entry and canonical ordering that preserves unrelated entries;
- canonical domain-document, root-catalog-entry, and link formatting;
- links to files present in the final selected-domain set;
- concurrent use-case sequence allocation under Stage 3;
- references to a confirmed selected-domain path change; and
- malformed structure whose correction is uniquely derivable without semantic change.

Different same-path content, a likely duplicate actor goal, and any non-unique structural repair are semantic. Route foundation structure to `/spec-domain` and use-case structure to `/spec-uc`.

### Semantic Conflict

Stop dependent work and present exact evidence for:

- different domain definitions, boundaries, requirements, Entity Models, invariants, or terminology;
- different identity, title, status, goal, flow, outcome, or removal contract for one use case;
- a new use case that may duplicate an existing actor goal;
- a foundation change affecting multiple use cases;
- conflicting uncommitted work; or
- a conflict marker whose result is not mechanically derivable.

Foundation and multi-use-case invariant conflicts belong to `/spec-domain`. One interaction's identity, boundary, behavior, outcome, or status belongs to `/spec-uc`. Pass the selected domain, paths, base/ours/theirs/current evidence, and reconciliation reason to the chosen skill. On return to `/spec-reconcile <domain>`, rediscover the scoped state from scratch.

## Stage 3 — Reconcile Concurrent Use-Case Sequences

Sequences are local to the selected domain and stable for merge-base files. Never fill gaps or change a use case's slug, H1, body, or status while resequencing.

1. Keep every surviving merge-base use case at its sequence.
2. Identify every use case introduced on either parent after the merge base, including additions Git merged without a textual conflict.
3. Sort committed additions by their first introducing commit's committer timestamp (`%ct`), then source-relative path.
4. Append uncommitted additions by current numeric prefix, then relative path. Never use filesystem times.
5. Allocate the cohort from `max(sequence in the merge base) + 1`; treat an empty merge-base sequence set as zero, so its first allocated sequence is `001`.
6. Change only numeric prefixes and references to the old selected-domain paths.
7. Treat ambiguous provenance, multiple merge bases, unsupported multi-parent cohorts, duplicate identity, destination collisions, and inseparable uncommitted/branch changes as blockers.

The rule covers the complete selected-domain cohort, not only colliding numbers.

## Stage 4 — Review and Apply the Mechanical Set

Before writing, present:

```markdown
# Specification Reconciliation: [Domain]

## Mode and Provenance

## Deterministic Changes

## Semantic Conflicts and Decisions

## Preserved and Outside-Scope Work

## Affected Paths and Validation
```

Do not write while a selected-domain semantic conflict or required decision remains. On a named return continuation, rediscover the scoped state and never reuse an old sequence map or write set.

Apply changes only after **Apply complete deterministic set** is selected:

1. Re-read every target, relevant index stage, and working-tree path.
2. Verify that mode, inventory, membership, and classification still match the reviewed set.
3. Capture exact pre-images or nonexistence for every target.
4. Apply moves, content updates, and reference rewrites in one uninterrupted specification-only phase without staging.
5. Cross-validate the complete result.
6. If writing or validation fails, finish the exact set only when no new semantics are needed; otherwise restore and validate every pre-image. Report failed restoration as blocked and inconsistent.

If no deterministic change exists, proceed directly to validation without an apply gate.

## Stage 5 — Validate the Reconciled Domain

Before validation, derive the explicit coordinator-owned path set from the reviewed inventory: the selected domain paths, `docs/spec/catalog.md` only when its selected-domain entry changes, and each outside-domain file receiving a confirmed selected-domain reference rewrite. Use that same set for gating checks; never substitute all of `docs/spec`.

Confirm:

- no unintended conflict marker remains in coordinator-owned paths;
- the selected root entry, domain document, Entity Model, owning-requirement links, and all selected-domain references resolve;
- every `Use cases` field in the domain document is a nested one-link-per-bullet Markdown list;
- every normal use case has exactly one Goal, Actors, Preconditions, Trigger, Behavior Diagrams, Flow, and Postconditions section;
- Behavior Diagrams precedes `## Flow`;
- normal steps are ordered, and alternate and exception branches appear inline at their divergence points with an explicit Resume, Continuation, or Outcome;
- selected-domain sequences are unique, merge-base sequences and gaps are unchanged, and additions follow the Stage 3 order;
- every resequenced reference is updated while use-case title, body, status, and canonical structure are preserved;
- outside-domain content changed only for confirmed reference rewrites;
- no application code, tests, unrelated conflict, index state, or merge state changed;
- staged, unstaged, untracked, and combined coordinator-owned results pass whitespace, structure, and link checks; and
- run `git diff --check --cached --` and `git diff --check --` with the explicit coordinator-owned pathspecs appended, and directly inspect coordinator-owned untracked files for equivalent whitespace errors.

Check unrelated `docs/spec` changes separately when useful and report their failures as preserved outside-scope issues; they do not fail or roll back an otherwise valid selected-domain reconciliation.

Run Stage 6 only after every selected-domain conflict is resolved and the deterministic set is either unnecessary or applied and validated.

## Stage 6 — Review Use Cases for Consolidation

Read every selected-domain use case of every status from the final reconciled state. Compare:

- primary actor and actor-recognizable goal;
- trigger and meaningful success outcome;
- failure guarantees and unchanged-state behavior;
- owning requirements; and
- material overlap among normal flow steps and inline alternate or exception branches.

Propose consolidation only when a group appears to describe one externally meaningful goal whose expected variants or visible failures belong in one use case. Shared entities, terminology, requirements, implementation components, or adjacent workflow steps alone are insufficient. Independent triggers, goals, or outcomes must remain separate. Review an `Approved Removal` artifact for context but never include it in a candidate group.

Do not silently cap candidates. Present every candidate group:

| Candidate Paths and Statuses | Overlap Evidence | Proposed Surviving Goal and Path | Behavior to Preserve | Blockers or Decisions |
|---|---|---|---|---|
| [Paths and statuses] | [Actor, goal, trigger, outcome, and flow overlap] | [Proposal or decision needed] | [Unique behavior from every member] | [Status, boundary, or foundation concern] |

If none qualify, report that every use case was reviewed and no consolidation is proposed. This review never edits, deletes, renames, or changes status.

When candidates exist, call `AskUserQuestion` with **Review consolidation with `/spec-uc`** and **Finish reconciliation**. Only the named review action invokes `/spec-uc` with the selected domain, every candidate path, statuses, overlap evidence, preservation requirements, and blockers. `/spec-uc` must independently verify the proposal. If it returns a decision to keep a group separate, retain that resolution in the current workflow and do not re-propose the unchanged group; reassess it only after relevant content changes.

## Outcome

Report the selected domain, mode, changed paths, sequence map, resolved or remaining blockers, preserved outside-scope work, exact validation results, recovery, and consolidation candidates. Do not echo complete artifacts. Give mode-specific next steps: for **Active Merge**, tell the user to review and stage the repaired paths and continue the merge manually; for **Completed Merge**, tell the user to review and commit the reconciliation changes as appropriate; for **Audit Only**, tell the user to review and stage or commit ordinary repairs as appropriate. Never tell the user to continue a merge outside Active Merge mode.

For unresolved foundation conflicts, offer **Continue with `/spec-domain`** or **Stop reconciliation**. For interaction conflicts, offer **Continue with `/spec-uc`** or **Stop reconciliation**. For a ready mechanical set, offer **Apply complete deterministic set** or **Stop without applying**; free text revises the review. After validated reconciliation, use the Stage 6 consolidation handoff when applicable. Narrative text never authorizes writing or skill continuation.
