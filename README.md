# Spec Skills

A small, explicit spec-driven workflow for Claude Code. The skills keep domain modeling, behavioral specification, implementation, and merge reconciliation separate without adding a large lifecycle framework.

## Skills

| Skill | Purpose |
|---|---|
| `spec-domain` | Create or revise a domain specification and Entity Model, then identify candidate use cases. It accepts a free-form request and infers the domain, asking the user to choose only when resolution is ambiguous. |
| `spec-uc` | Create, revise, split, consolidate, or review one observable use-case goal. It requires the domain, infers the use case from the request, and asks only when the target is ambiguous. |
| `spec-impl` | Capture paired or unpaired code paths, execute approved code plans, verify behavior, and refresh or reshape implementation records. |
| `spec-reconcile` | Reconcile one merged specification domain, paired implementation records, and deterministic references, then identify use cases that may be consolidated. |

## Specification Layout

The skills maintain specifications under `docs/spec/`:

```text
docs/spec/
├── catalog.md
└── <domain>/
    ├── domain.md
    ├── entity-model.md
    ├── NNN-<use-case>.md
    └── implementation/
        └── NNN-<use-case>.md
```

- The root catalog provides product context, specification authority, the shared layout, and an alphabetical set of linked domain headings with one-sentence descriptions.
- A domain document defines the domain boundary and self-contained requirement contracts with their owning use-case links.
- An Entity Model defines external dependencies, one relationship diagram, owned concepts and properties, concept-local invariants, and optional shared value types.
- Each numbered file in the domain root describes one observable use case.
- Each optional matching file under `implementation/` records the current code path, locations, constraints, and verification for that use case. It is observed-code evidence, not semantic authority. When it exists, the use case links to it immediately below `Status`, and the record links back to the use case.

## Specification Authority

A project adopts this workflow when `docs/spec/catalog.md` exists. From that point, the semantic specification artifacts in `docs/spec/` are authoritative for intended behavior; files under `implementation/` remain observed-code evidence:

- The root catalog, domain documents, and Entity Models are the reviewed specification foundation.
- `Approved` and `Implemented` use cases are accepted implementation contracts.
- `Draft` and `Review` use cases are authoritative records of proposals, but they are not implementation targets.
- Code and tests describe observed implementation. When they differ from an accepted specification, treat the difference as implementation drift rather than silently rewriting the specification.
- When specification artifacts contradict each other, stop for human resolution. Use `spec-domain` for foundation, scope, cross-use-case invariant, or terminology conflicts and `spec-uc` for one interaction's boundary or behavior.

## Review, Stage Gates, and Artifact Delivery

For semantic specification work, keep domain foundations and use cases distinct and make every actionable transition explicit:

1. Use the host-provided **Other** response for free text; do not add a duplicate option. Only selection of a named action authorizes approval, writing, deletion, abandonment, application, or skill continuation. Free text revises the proposal; use distinct **Keep** or **Stop** actions for non-writing outcomes.
2. Use `AskUserQuestion` for user decisions and actionable stage gates. A semantic answer may write a `Draft` or `Review` only when its question explicitly discloses that update.
3. Invoke a cross-skill continuation only through its named action. After specification validation, use a named `/spec-impl <domain> <sequence>` action for implementation follow-up or an explicit stop action. Return to `/spec-reconcile <domain>` with the original domain so it can rediscover scoped repository state.
4. Keep foundation proposals unpersisted until final approval. Apply every approved multi-path semantic change as one complete write set; finish that exact set or restore and validate all captured pre-images.
5. When creating or reconstructing a use case, read and validate its implementation record first. Inspect only its named locations unless the record is missing, stale, contradictory, or insufficient; only then trace the necessary public execution path and its material validation, authorization, state changes, external effects, retries, and failures. Translate confirmed observable logic into one integrated flow whose normal steps carry inline alternate and exception branches, followed by postconditions, without persisting implementation details.
6. For every semantic use-case change, compare the proposed behavior with each owning requirement's `Capabilities`, `Guarantees`, and `Constraints` in the domain document; explicitly record whether the requirement remains accurate or needs an exact delta. Save new work as `Draft` and accepted-behavior revisions as `Review` only through the applicable gate. Keep unresolved matters in `## Open Questions`; defer any directly required domain requirement or Entity Model delta until final approval.
7. Before replacing accepted content with `Review`, capture the exact current accepted content and prior status. Abandonment restores that baseline and its links, including removal of Review-only split paths.
8. Offer **Mark Approved** only when the complete use case is resolved. Only that selection removes `## Open Questions` and writes `Approved`; after validation, offer the appropriate `/spec-impl` mode or **Stop after specification**.
9. Every normal root-level numbered use case contains a Mermaid overview between Trigger and `## Flow`. In `## Flow`, top-level numbered items form the normal path and alternate or exception branches sit beneath their divergence steps. Named process diagrams are optional. A durable `Approved Removal` record is the sole structural exception and must have exactly its canonical H1, Approved status, section, and three fields.
10. `/spec-domain` reviews and atomically applies a coordinated foundation-and-use-case set. A conflicting `Draft` or `Review` must first be resolved through an explicitly selected `/spec-uc` continuation.
11. `/spec-impl` uses an implementation record as its code-first context when one exists, captures every current implementation flow from existing code, uses native plan approval for each cohesive implementation batch, refreshes complete flow cards after verification, prepares reshaped cards for final split/consolidation review, and owns `Implemented` conformance evidence.
12. `/spec-reconcile <domain>` preserves staged, unstaged, and untracked work while repairing deterministic structure, paired implementation records, and references in that domain. After validation it reviews every domain use case for evidence-backed consolidation candidates, but never merges them itself.
13. Return a concise outcome with changed paths, resulting status, validation, recovery, and the selected next-stage handoff; do not echo complete artifacts.

Implementation plans are transient code-workflow records, not specification artifacts. `/spec-impl` reads the selected use case and matching implementation record when one exists. When no record exists for existing code and no accepted-behavior drift is known, `Capture` inventories every current outer entry and independently resumed path, then records the entry points, flows, locations, state boundaries, constraints, and tests without changing behavior. When accepted behavior is missing or drifting, `Execute` takes precedence even if no record exists and builds the complete record from verified implementation work. When no code exists yet, it plans the first approved implementation flow and creates the paired record after that flow is verified. `Reshape` is a preparation-only operation for a resolved split or consolidation proposal over accepted use cases; it returns the exact record set to `/spec-uc` for final review without writing. A normal plan may cover the complete remaining use case and contains one or more ordered behavioral increments. Its compact approval record is headed by the desired outcome and contains `Decision`, `Approaches`, `Flow Changes`, `File Changes`, `Verification`, and `Next`; stable increment labels connect every affected file and exact edit to a distinguishing baseline and focused proof. `Approaches` records each resolved implementation decision, or states that existing architecture leaves no user choice, while plan approval separately authorizes implementation. After a verified batch, `/spec-impl` refreshes the complete flow-card set, preserving covered flows and adding or removing cards when the runtime inventory changes; it does not duplicate accepted behavior in the record.

Group related normal, alternate, and exception behavior in one batch when it shares a public path, implementation responsibility, migration, fixture, or validation setup and can be safely reviewed together. Split into another batch only when later work depends on current evidence, needs an unresolved product or non-routine architectural decision, has a materially different blast radius or recovery boundary, requires an intermediate review point, or would make the current plan too broad to review reliably. Independent provability alone is not a reason for another approval. Never choose granularity by file, architecture layer, normal-versus-error path, or arbitrary size.

Each approved increment is implemented and proven in order without a new approval gate, then `/spec-impl` validates the complete batch, refreshes the complete implementation flow-card set, and recomputes remaining conformance. Accepted work outside the approved scope receives another cohesive batch plan and fresh approval. The use case stays `Approved` until all contract areas and final coexistence checks pass; one completed batch never establishes `Implemented` without complete conformance verification. Clearly behavior-neutral editorial edits may be applied directly while preserving status; when classification is uncertain, use semantic review.

For existing code with no use case, `/spec-impl` may capture the implementation path in conversation, continue to `/spec-uc` for the semantic contract, and persist the record only after the use case has a final paired path. For an existing use case with no record and no known behavioral drift, `/spec-impl` captures the verified current path directly; known drift uses `Execute`. A record describes current code only; planned future code remains in the transient implementation plan until verification passes.

One implementation record contains exactly one named card for every current implementation flow: each distinct outer entry or independently resumed path needed by the use case, with architecture layers and branches kept inside their owning end-to-end card. The paired files provide bidirectional navigation: the use case contains exactly one `Implementation` link immediately below `Status`, and the record contains exactly one `Use Case` backlink. Omit the forward link when no record exists. An individual card may additionally link to a relevant use-case heading with a Markdown fragment. Each card requires `Entry`, `Flow`, `Locations`, and `Tests`; `Locations` uses resolving Markdown links to repository files followed by key symbols, and `Tests` records a specific `Missing` gap when focused proof does not exist. A missing proof blocks `Implemented` but never causes the flow to be omitted; a standalone Capture or Refresh that exposes such a gap downgrades an existing `Implemented` use case to `Approved`. A card may add `State` and `Constraints` only when they preserve material implementation knowledge. Cards stay code-focused and omit source revisions, freshness labels, change history, behavioral prose already owned by the use case, placeholders, and exhaustive call graphs. The forward link is navigation metadata, not implementation detail or semantic authority.

## Merge Reconciliation

Invoke `/spec-reconcile <domain>` after `git merge` pauses or completes. It scopes inventory, conflicts, sequence repair, writing, and gating validation to that domain, its changed root-catalog entry, and confirmed references to its paths; other-domain failures are reported separately and do not roll back a valid scoped repair. Committed additions are ordered by their first-introducing commit's committer timestamp (`%ct`) and source-relative path, followed by uncommitted additions in current sequence order. An empty merge-base sequence set has maximum zero, so its first allocation is `001`. Ambiguous provenance and semantic conflicts stop for user resolution, and deterministic repairs never alter the index.

After the selected domain is conflict-free and mechanically validated, reconciliation reviews every use case of every status. It proposes consolidation only for artifacts that appear to express one primary-actor goal with compatible triggers, outcomes, and flow behavior—not merely shared entities, requirements, or implementation. It never performs the merge; the user may continue into `/spec-uc` for independent semantic review. Completion guidance follows the detected mode: continue a merge only for Active Merge, commit reconciliation changes as appropriate for Completed Merge, and treat Audit Only repairs as ordinary changes.

## Domain Document Structure

A domain document starts with its definition and Entity Model link, followed by:

1. `Boundary` contains one broad `Owns` statement and one broad `Excludes` statement.
2. `Requirements` contains one H3 section per coherent domain responsibility.
3. Every requirement has `Capabilities` and may add only the `Guarantees`, `Constraints`, and existing `Use cases` it owns; empty optional fields are omitted. Render each `Use cases` field as a nested Markdown list with one link per bullet.
4. A use case may be linked by multiple requirements when it materially implements each one. Domain documents contain no separate use-case index.

## Entity Model Structure

Entity Models use a compact, fixed reading order:

1. `External Concepts` defines connected concepts owned elsewhere and is omitted when empty.
2. `Entity Relationship Diagram` is one Mermaid `erDiagram` and is the sole source of relationships and relationship cardinalities. Labels use active source-to-target verbs, preferring `owns`, `contains`, `uses`, `references`, `maps_to`, `compares_to`, `results_in`, and `affects`.
3. `Concepts` defines owned concepts, properties, and only necessary concept-local invariants; it contains no relationship tables.
4. `Shared Value Types` is optional and contains only reused values or values with important reusable representation or security semantics.

Closed enumeration values belong in their owning property rows. Entity Models have no global `Policies`, `Concept Constraints`, or `Enumerations` sections; requirements own domain obligations and use cases own interaction behavior.

## Use-Case Boundaries

One use case covers one externally meaningful primary-actor goal, from an observable trigger through meaningful postconditions. Keep expected variants and visible failures as inline branches beneath their divergence steps when they serve that goal; split independent goals. When multiple files appear to describe the same goal, `/spec-reconcile <domain>` may propose consolidation and `/spec-uc` performs the semantic review.

## Use-Case Statuses

| Status | Meaning |
|---|---|
| `Draft` | An editable persisted new use case under discussion; it may contain Open Questions and cannot be implemented. |
| `Review` | An editable persisted revision to accepted behavior under discussion; it may contain Open Questions and cannot be implemented. |
| `Approved` | The documented behavior is accepted for implementation. A use case approved for complete removal temporarily stores that accepted removal contract until deletion is implemented and verified. |
| `Implemented` | Code and behavior-derived tests conform, and required validation passes. |

New behavior is normally persisted as `Draft`. Revised accepted behavior may be persisted as `Review` only after the exact current accepted content and status have been captured. Both remain open until the complete artifact is ready for **Mark Approved**. Directly required foundation deltas remain unpersisted until that approval. When all consolidation sources are Drafts, **Consolidate Drafts** atomically writes one combined Draft, removes absorbed Draft paths, updates all links and references, and preserves both confirmed behavior and unresolved questions without promoting status.

Use-case sequences are local to each domain root and append-only. Allocate `max(existing sequence) + 1`; an empty sequence set has maximum zero, so the first use case is `001`.

When accepted behavior must be removed with no enduring interaction, the existing use-case file temporarily holds a canonical durable `Approved Removal` record. After behavior and tests are removed and the required absence is verified, `spec-impl` atomically deletes the use-case and matching implementation record, removes or safely rewrites every `docs/spec` reference, and validates the resulting specification state; failure restores the captured pre-images.

## Install Globally

Install the Claude Code skills with one command:

```bash
bash install.sh
```

The installer always replaces installed copies in `~/.claude/skills/` and does not modify the repository source files.

## Compatibility

The source skills intentionally use Claude Code frontmatter extensions:

```yaml
argument-hint: "..."
user-invocable: true
```

The skills remain directly user-invocable and are also visible to Claude so an explicit `AskUserQuestion` selection can continue into another specification skill. The strict portable `skills-ref` validator reports these fields as unexpected.

## License

Released under the [MIT License](LICENSE).
