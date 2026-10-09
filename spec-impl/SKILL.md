---
name: spec-impl
description: Capture existing code paths with or without a paired use case, implement approved behavior, verify conformance, and refresh or reshape implementation records without repeated repository-wide discovery.
user-invocable: true
argument-hint: "<domain> [sequence or capture request]"
---

# Implement Use Case

Implement one reviewed use case through cohesive, reviewable batches. A matching implementation record is optional, lightweight navigation evidence: a short summary, entry, key locations, and verification state. Accepted specifications define intended observable behavior; records, code, and tests describe observed implementation.

## Input

The user supplies a domain and three-digit use-case sequence, for example `provider-admission 001`. Resolve that pair to exactly one `docs/spec/<domain>/<sequence>-<slug>.md` path; reject a missing or ambiguous sequence instead of guessing a slug. Its paired implementation-record path is `docs/spec/<domain>/implementation/<sequence>-<slug>.md`. Do not accept a use-case path, slash-form identifier, use-case name without a sequence, or current-open-file fallback. For unpaired Capture, accept only a domain plus an explicit implementation-capture request instead of a sequence.

For existing code with no use case, accept a domain plus an implementation-capture request. Gather the observable behavior and key locations in conversation, then return or continue to `/spec-uc`. Persist a compact record only when the user requested durable navigation evidence and only after a paired use-case path exists. Never allocate a use-case sequence or create a semantic use case here.

## Operating Modes

Select the first applicable mode below from repository state and the request. When another skill invokes `/spec-impl`, it supplies this mode as continuation intent; the command still resolves the use case by domain and sequence.

- **Removal:** the use case is an `Approved Removal` artifact. Remove the behavior and its proof, verify the required absence, then delete the specification artifact and any matching implementation record as one recoverable cleanup.
- **Reshape:** a resolved split or consolidation changes ownership of existing optional records. Prepare concise destination records without writing and return them to `/spec-uc`.
- **Execute:** accepted behavior is missing, incomplete, or drifting. Implement or repair it whether or not a record exists; refresh a record only when present or requested.
- **Capture:** the user wants durable navigation for existing conforming code. Create the optional compact record without changing behavior.
- **Refresh:** verified code changed and an existing record became stale. Update its summary, entry, key locations, and verification state.
- **Verify:** code appears complete and conforming. Verify the whole accepted contract; a record is not required.

Capture or Refresh may be part of an approved implementation batch. For a standalone operation, present the exact record and status changes. If verification exposes a proof gap or drift, include a downgrade from `Implemented` to `Approved`. Offer the applicable save action plus **Stop without saving**.

Apply a standalone record and conditional status change as one recoverable write set, validating pairing, links, required sections, status, and whitespace. Reshape is preparation only. A reconciliation-scoped Refresh changes only the existing record. When Capture begins before a use case exists, keep the evidence unpersisted until `/spec-uc` establishes the paired path. Use Execute whenever application behavior may change.

A standalone Capture or Refresh ends after its authorized write and validation. Reshape ends after returning its prepared set. These paths do not enter the implementation stages below.

## Decisions and Handoffs

- Ask only for material implementation choices with multiple viable approaches. Resolve them before presenting the plan; plan approval, not the choice itself, authorizes implementation.
- Use the host's native plan approval once per batch. If unavailable, offer **Approve implementation plan** and **Stop without implementing**. Approval covers only the behavior and files named in that plan.
- Obtain fresh approval when the observable result, owning responsibility, file set, validation layer, or recovery boundary materially changes. Continue within the approved plan for equivalent checks or repairs that preserve those boundaries.
- Behavioral decisions belong to `/spec-uc`; foundation decisions belong to `/spec-domain`. Offer one named continue-or-stop handoff and invoke it only after selection. Return to the skill that directly handed off this work.
- When entered from `/spec-reconcile`, preserve its domain and merge evidence, never stage or continue the merge, and limit a reconciliation-scoped Refresh to the selected record.

## Preconditions and Authority

Read repository instructions, working-tree changes, the catalog, selected domain document, Entity Model, use case, and any matching record. For Reshape, also read every affected accepted baseline, source record, and resolved destination proposal.

Run the shared specification validator when available. Stop on malformed structure, unresolved links, invalid record pairing, or a use case without an owning requirement. Route interaction structure or semantics to `/spec-uc` and foundation issues to `/spec-domain`.

Accepted specifications govern intended behavior; code and tests establish observed implementation. Treat a mismatch as implementation drift, never as permission to rewrite the contract. Require `Approved` for changed behavior and Removal. Use `Implemented` only for verification, repair, or behavior-preserving work. Reject `Draft`, `Review`, and Open Questions except for Reshape and a reconciliation-scoped Refresh, which must not implement or alter the pending proposal.

Confirm that a normal use case expresses one complete actor goal and that an Approved Removal artifact has its canonical shape. Unpaired Capture may inspect code but cannot change behavior, persist a record, claim conformance, or assign status before `/spec-uc` establishes an accepted use case.

## Implementation Record

One optional record pairs with one use case by identical sequence and slug:

```text
001-example.md
implementation/001-example.md
```

The record describes current code, never planned work. It is optional and deliberately lightweight.

```markdown
# [Use Case]

**Use Case:** [Use Case title](../NNN-use-case.md)

## Implementation

[One short summary of how the use case is realized.]

**Entry:** [Public user, API, command, job, callback, or resume entry.]

### Locations

- [repository-relative/path](relative-link-from-this-record) — [implementation responsibility]

### Verification

- [Covered behavior or concise `Missing —` gap.]
```

The `Use Case` backlink, `Implementation`, `Entry`, `Locations`, and `Verification` are required. `Locations` uses portable links to a small set of key repository files and names responsibilities rather than exhaustively listing components or symbols. `Verification` summarizes covered behavior and any specific missing proof without storing exact commands.

Omit styling mechanisms, internal API detail, full call chains, source revisions, change history, semantic constraints, and behavior already owned by the use case. A record never overrides the accepted specification. When it exists, verify it against current code before relying on it and broaden discovery whenever it is incomplete or stale.

## Reshape Accepted Records

When mode is `Reshape`, read each existing source record and current code, then determine whether each destination benefits from a compact record. Return exact summaries, entries, locations, verification states, backlinks, and file operations to `/spec-uc`. Do not invent records for destinations that do not need them, allocate sequences, decide semantics, write files, or claim conformance.

## Stage 1 — Inspect and Plan

Trace the public entry and any material asynchronous or resumed paths. Use a current implementation record as navigation when present, but verify it against code and broaden only when it is stale or incomplete. Compare observed behavior with the selected use case, its owning requirements and Entity Model rules, and materially overlapping accepted contracts. Check that diagrams agree with the textual behavior.

Identify the implementation gap, affected responsibility, exact files, distinguishing baseline, and focused proof. Run a safe non-mutating baseline before planning when possible. If code already conforms, plan verification only; do not manufacture changes.

Prefer one cohesive batch for the remaining use case. Split only when later work depends on current evidence, needs an unresolved decision, or has a materially different blast radius or recovery boundary. Keep production changes and their behavioral proof together; use increment labels only when the plan contains multiple independently verified changes.

Resolve material choices before presenting this plan:

```markdown
# [Outcome]

[One sentence describing the implementation gap and chosen approach.]

## Flow Changes

- **Before:** `Current control or data path.`
- **After:** `Proposed control or data path.`
- **Failure:** [Changed failure path or unchanged-state guarantee.] <!-- Omit when not material. -->

## File Changes

- `[path]`: [Concrete production, test, configuration, migration, specification, or record change.]

## Verification

- **Baseline:** `[command or check]` — [Observed result, or expected result when it must run after approval.]
- **Proof:** `[command or check]` — [Expected behavioral result.]
- **Final:** `[broader check]` — [Expected coexistence result.] <!-- Omit when unnecessary. -->

## Deferred

- [Accepted work intentionally excluded and why.] <!-- Omit when none. -->
```

Keep Flow Changes at the code-responsibility level rather than listing every call. Omit optional sections and empty placeholders. The plan is transient and must not be stored under `docs/spec`.

## Stage 2 — Implement and Verify

After approval:

1. Re-read the approved files and run the baseline. If it does not distinguish the expected current behavior, revise the check within the approved boundary or replan when that boundary changes.
2. If an `Implemented` use case has drift or lacks required behavioral proof, change it to `Approved` before repair.
3. Implement in dependency order, following repository architecture and preserving unrelated behavior and user changes. Keep each production change with its behavioral test; when a durable automated test cannot precede the change, exercise the installed or public path.
4. Run the smallest focused proof after each cohesive change and the planned broader check after the batch. Tests must protect observable behavior and postconditions rather than private structure.
5. Refresh an existing or requested implementation record only after its paths and proof are current. Record a specific `Missing —` gap when proof is incomplete and remove stale navigation.

Stop and replan when implementation exposes new behavior, responsibility, files, validation layers, recovery boundaries, or product decisions. Equivalent checks and repairs inside the approved boundary do not need another approval.

## Stage 3 — Close and Update Status

Compare the result with the complete accepted contract: owning requirements, applicable Entity Model rules, actors, preconditions, trigger, normal flow and inline branches, and success and failure postconditions. Run the smallest final check needed to show the paths coexist.

Set `Implemented` only when production behavior conforms completely, behavior-derived tests protect the applicable contract, every required check passes, and any existing record is current with no `Missing` gap. Otherwise keep or return the use case to `Approved` and identify the remaining contract or proof. `Implemented` does not imply deployment or operational health.

Removal follows the cleanup rules below instead of the `Implemented` status calculation.

If accepted work remains, plan the next cohesive batch under Stage 1. Do not create separate plans when the remaining work can be reviewed and verified together.

After changing status or a record, run:

```bash
python3 "$HOME/.claude/skills/spec-validator/validate_spec.py" docs/spec/<domain>
```

Report once:

```markdown
# Outcome

- **Result:** [Completed, partial, blocked, verification-only, or already conforming.]
- **Status:** [Approved, Implemented, or Removed, with reason.]
- **Changed files:** [Paths or none.]
- **Verification:** [Commands or checks and results.]
- **Remaining:** [Unimplemented or unverified contract, or none.]
```

## Removal

Preserve an Approved Removal artifact, any matching record, and all references until behavior and proof are removed and the required absence is verified. Make final specification cleanup one approved, recoverable write set: capture every affected pre-image, delete the artifact and matching record when present, remove or safely rewrite all references, and validate behavior plus the final specification. Finish the exact set when no decision is needed; otherwise restore and validate every pre-image. Report `Removed` only after the complete cleanup passes.

## Handoff

Do not create a status dashboard, persistent plan, duplicate catalog status, or requirement map. When another skill directly handed off this work, offer one return action containing the resolved evidence, status, changed paths, and validation; that caller rediscovers its scope. An implementation-originated unpaired Capture that returns from `/spec-uc` resumes and finishes here rather than returning to `/spec-uc` again. A directly invoked workflow otherwise ends without a return action.
