---
name: spec-reconcile
description: Reconcile the complete docs/spec set after or during a Git merge without arguments, preserving reviewed content while repairing deterministic domains, catalogs, links, and concurrent use-case sequence conflicts. Use when explicitly invoked to reconcile merged specification artifacts.
user-invocable: true
---

# Reconcile Specifications

Reconcile the complete `docs/spec/` tree after or during a Git merge. This is a repository-wide mechanical reconciliation workflow, not a fourth semantic authoring workflow. It preserves the existing specification authority split: `/spec-domain` owns foundation conflicts, `/spec-uc` owns one interaction's behavior, and this skill owns only deterministic structural reconciliation.

This skill takes no arguments. Invoke it as `/spec-reconcile` from the repository root.

## Scope, Safety, and User Decisions

- Work only on specification artifacts under `docs/spec/` and their internal links. Never change application code or tests.
- Treat the committed merge base, both merge parents, the Git index stages, the working tree, and staged, unstaged, and untracked `docs/spec` work as inputs. Current staged, unstaged, and untracked work is a fourth input, not disposable noise.
- Preserve unrelated working-tree changes. Before any write, record the current paths, exact target contents or nonexistence, and index-stage identities for every coordinator-owned target.
- Never run `git add`, `git commit`, `git merge --continue`, `git checkout`, `git restore`, or any command that alters the Git index or discards user content. Leave staging and merge completion to the user.
- Never resolve a semantic conflict by choosing ours, theirs, the merge base, the newest file, or an apparent majority. On every conflict or newly required decision, stop dependent reconciliation and call `AskUserQuestion` with the exact evidence and concrete choices. Offer **Resolve through `/spec-domain`**, **Resolve through `/spec-uc`**, or **Stop and leave the set unchanged**, as applicable.
- Do not invoke another skill merely because it is relevant. Invoke it only after the user selects that continuation. If invocation is unavailable or denied, preserve state and provide the exact manual command.
- A completed deterministic reconciliation must either apply its complete approved write set or restore every captured pre-image and report the failure. Never report a partial repair as success.

## Stage 1 — Detect the Reconciliation Mode

Read repository instructions before inspecting artifacts. Then identify the mode without requiring user arguments.

### Active Merge

An active merge is present when Git exposes merge state such as `MERGE_HEAD`. Read:

- `git status --short` and `git ls-files -u`;
- the current `HEAD`, `MERGE_HEAD`, and merge base;
- Git's ours/theirs index stages (and the merge-base stage when available) for relevant `docs/spec` paths;
- the current working-tree version, including conflict markers and untracked files.

Do not assume the working tree is the result of a safe merge. A textual conflict may be mechanical, semantic, or both. Leave non-spec conflicts untouched.

### Completed Merge

When the merge has completed, inspect the merge commit's parents and their merge base when the current `HEAD` is a merge commit or the recent merge is unambiguous. Compare the merged result with both parent lines to identify artifacts introduced by the merge. Do not infer a merge cohort from unrelated old history.

### Audit Only

If no active or unambiguous recent merge exists, audit the current `docs/spec/` tree and use Git history only where provenance is clear. Repair only deterministic structural inconsistencies. Do not invent a branch cohort or reorder existing accepted use cases merely because their numbers are not globally chronological.

If required Git provenance is unavailable, ask the user what to do; do not use filesystem timestamps as a substitute.

## Stage 2 — Inventory and Classify

Read the complete specification tree before proposing changes. Inventory:

- the root catalog and every linked domain;
- each domain catalog and Entity Model;
- every use-case path, numeric prefix, title, status, and body;
- every owning-requirement link and every other `docs/spec` reference;
- duplicate paths, duplicate numeric prefixes, missing links, nonexistent links, conflict markers, and malformed canonical structure.

Classify each difference before writing.

### Deterministic Reconciliation

The following are mechanical only when the source content is additive or identical and no semantic choice is required:

- union of independent new domains and their root-catalog entries;
- alphabetical root-domain entries and canonical catalog/link ordering;
- nested Markdown `Use cases` lists with one link per bullet;
- byte-identical same-path additions;
- links to files that exist after reconciliation;
- concurrent use-case sequence allocation under the rules below;
- replacement of old internal references after a confirmed path change.

A same-path addition with different content is not deterministic. A likely duplicate actor goal is not deterministic even when filenames differ.

### Semantic Conflict

Stop and present the evidence when any choice could alter intended behavior, including:

- different domain definitions, boundaries, requirements, Entity Models, invariants, or terminology;
- different content, status, title, actor goal, flow, outcome, or removal contract for the same use case;
- a new use case that appears to duplicate an existing actor goal;
- a changed foundation that affects multiple existing use cases;
- a current uncommitted edit that conflicts with either committed branch version;
- an unresolved conflict marker whose correct content is not mechanically derivable.

Foundation, scope, requirement, Entity Model, cross-use-case invariant, or shared-terminology conflicts belong to `/spec-domain`. One interaction's identity, goal, boundary, flow, outcome, or status conflict belongs to `/spec-uc`.

## Stage 3 — Reconcile Concurrent Use-Case Sequences

Use-case sequences are local to a domain and stable for the merge base. Do not renumber merge-base files, fill deleted gaps, or change a use case's title, body, status, or slug while resequencing.

For each domain:

1. Keep every surviving merge-base use case at its existing numeric sequence.
2. Identify every use case introduced on either parent after the merge base, including additions that Git merged without a textual conflict.
3. Resolve the first introducing commit for each committed addition on its source lineage. Sort committed additions by that commit's timestamp, then by relative path for equal timestamps.
4. Append uncommitted additions after committed additions. Sort uncommitted additions by their current numeric prefix, then by relative path for equal prefixes. Never use filesystem birth or modification times.
5. Allocate the combined cohort consecutively from `max(sequence in the merge base) + 1`.
6. Keep each artifact's slug, H1, body, and status unchanged. Change only its numeric prefix and every internal `docs/spec` reference that points to the old path.
7. Treat missing provenance, duplicate artifact identity, destination collisions, and an uncommitted edit that cannot be separated from a branch change as blockers. Ask the user; do not guess.

Example:

```text
Merge base: 001, 002
Branch A:   003-A created 09:00, 004-C created 11:00
Branch B:   003-B created 10:00

Result:     003-A, 004-B, 005-C
```

The rule applies to all concurrently added files, not only directly colliding prefixes. It never changes the existing merge-base sequence.

## Stage 4 — Prepare and Apply the Mechanical Set

Before writing, present a concise reconciliation summary:

```markdown
# Specification Reconciliation

## Mode

[Active merge, completed merge, or audit only; include merge base and parents when available.]

## Deterministic Changes

- [New domains and catalog entries]
- [Sequence mappings and reference rewrites]
- [Other mechanical link or ordering repairs]

## Semantic Conflicts and Decisions

- [Exact path and contradiction, or None]

## Preserved Work and Non-Spec Conflicts

- [Current staged/unstaged/untracked work and untouched conflicts]

## Affected Paths and Validation

- [Complete write set and checks]
```

Do not write while a semantic conflict or required decision remains unresolved. Use `AskUserQuestion` for the user's choice. If the user selects an owning skill, immediately invoke it with the artifact, exact contradiction, source evidence, and reconciliation reason. The owning skill must not stage or complete the merge. When it offers continuation back to this skill and the user selects it, rediscover the complete set from scratch; never reuse an old sequence map or write set.

When the set is deterministic and the user has selected approval to apply it:

1. Re-read every target, current index stage, and working-tree path.
2. Confirm the reviewed inventory, merge state, membership, and semantic classification are unchanged. Any semantic drift invalidates approval and requires a new question.
3. Capture the exact pre-application content or nonexistence of every target: root catalog, affected domain catalogs, Entity Models only if links/order require them, affected use cases, and every rewritten internal reference.
4. Apply file moves, content updates, catalog unions, and link rewrites as one uninterrupted specification-only phase. Do not stage anything.
5. Cross-validate the complete result before reporting success.
6. If a write or validation fails without a new semantic issue, finish the exact reviewed set if safe; otherwise restore every captured pre-image and validate restoration. If restoration fails, report the workflow as blocked and inconsistent.

## Stage 5 — Validation

Validate all of the following before completion:

- no unintended conflict markers remain in coordinator-owned `docs/spec` files;
- every root-domain entry is linked, resolves, and is alphabetically ordered;
- every domain catalog and Entity Model link resolves;
- every use-case file is linked under at least one owning requirement and every such link resolves;
- every catalog `Use cases` field is a nested Markdown list with one link per bullet;
- every domain has unique use-case numeric prefixes;
- merge-base sequences and gaps are unchanged;
- concurrent committed additions follow first-introducing-commit timestamp and path order;
- uncommitted additions follow current numeric prefix and path order after committed additions;
- every resequenced path reference is updated and no old path remains unintentionally;
- use-case title, body, status, and canonical structure were preserved during mechanical resequencing;
- no application code, tests, non-spec conflict, Git index, staging state, or merge state was changed;
- `git diff --check -- docs/spec` passes.

Report the mode, changed paths, sequence map, semantic blockers or decisions, preserved user work, exact validation results, and whether any recovery occurred. Do not echo complete specification files. Tell the user to review, stage, and complete the merge themselves.

## Handoff

If a semantic foundation conflict remains, use `AskUserQuestion` to offer **Continue with `/spec-domain`** or **Stop reconciliation**. If a one-interaction conflict remains, offer **Continue with `/spec-uc`** or **Stop reconciliation**. If no semantic conflict remains but the deterministic set is ready, use `AskUserQuestion` to offer **Apply complete deterministic set** or **Continue review**. A narrative response never authorizes writing.
