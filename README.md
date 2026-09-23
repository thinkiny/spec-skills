# Spec Skills

A small, explicit spec-driven workflow for Claude Code. The skills keep domain modeling, behavioral specification, implementation, and merge reconciliation separate without adding a large lifecycle framework.

## Skills

| Skill | Purpose |
|---|---|
| `spec-domain` | Create or revise a domain specification and Entity Model, then identify candidate use cases. It accepts a free-form request and infers the domain, asking the user to choose only when resolution is ambiguous. |
| `spec-uc` | Create, revise, split, consolidate, or review one observable use-case goal. It requires the domain, infers the use case from the request, and asks only when the target is ambiguous. |
| `spec-impl` | Implement and verify one approved use case through cohesive batches of independently testable behavioral increments. |
| `spec-reconcile` | Reconcile one merged specification domain, then identify use cases that may be consolidated. |

## Specification Layout

The skills maintain specifications under `docs/spec/`:

```text
docs/spec/
├── catalog.md
└── <domain>/
    ├── domain.md
    ├── entity-model.md
    └── NNN-<use-case>.md
```

- The root catalog provides product context, specification authority, the shared layout, and an alphabetical set of linked domain headings with one-sentence descriptions.
- A domain document defines the domain boundary and self-contained requirement contracts with their owning use-case links.
- An Entity Model defines external dependencies, one relationship diagram, owned concepts and properties, concept-local invariants, and optional shared value types.
- Each numbered file describes one observable use case.

## Specification Authority

A project adopts this workflow when `docs/spec/catalog.md` exists. From that point, `docs/spec/` is authoritative for intended behavior:

- The root catalog, domain documents, and Entity Models are the reviewed specification foundation.
- `Approved` and `Implemented` use cases are accepted implementation contracts.
- `Draft` and `Review` use cases are authoritative records of proposals, but they are not implementation targets.
- Code and tests describe observed implementation. When they differ from an accepted specification, treat the difference as implementation drift rather than silently rewriting the specification.
- When specification artifacts contradict each other, stop for human resolution. Use `spec-domain` for foundation, scope, cross-use-case invariant, or terminology conflicts and `spec-uc` for one interaction's boundary or behavior.

## Review, Stage Gates, and Artifact Delivery

For semantic specification work, keep domain foundations and use cases distinct and make every actionable transition explicit:

1. Use the host-provided **Other** response for free text; do not add a duplicate option. Only selection of a named action authorizes approval, writing, deletion, abandonment, application, or skill continuation. Free text revises the proposal; use distinct **Keep** or **Stop** actions for non-writing outcomes.
2. Use `AskUserQuestion` for user decisions and actionable stage gates. A semantic answer may write a `Draft` or `Review` only when its question explicitly discloses that update.
3. Invoke a cross-skill continuation only through its named action. Return to `/spec-reconcile <domain>` with the original domain so it can rediscover scoped repository state.
4. Keep foundation proposals unpersisted until final approval. Apply every approved multi-path semantic change as one complete write set; finish that exact set or restore and validate all captured pre-images.
5. When creating or reconstructing a use case, trace the current public execution path and its material validation, authorization, state changes, external effects, retries, and failures. Translate confirmed observable logic into one integrated flow whose normal steps carry inline alternate and exception branches, followed by postconditions, without persisting implementation details.
6. For every semantic use-case change, compare the proposed behavior with each owning requirement's `Capabilities`, `Guarantees`, and `Constraints` in the domain document; explicitly record whether the requirement remains accurate or needs an exact delta. Save new work as `Draft` and accepted-behavior revisions as `Review` only through the applicable gate. Keep unresolved matters in `## Open Questions`; defer any directly required domain requirement or Entity Model delta until final approval.
7. Before replacing accepted content with `Review`, capture the exact current accepted content and prior status. Abandonment restores that baseline and its links, including removal of Review-only split paths.
8. Offer **Mark Approved** only when the complete use case is resolved. Only that selection removes `## Open Questions` and writes `Approved`.
9. Every normal use case contains a Mermaid overview between Trigger and `## Flow`. In `## Flow`, top-level numbered items form the normal path and alternate or exception branches sit beneath their divergence steps. Named process diagrams are optional. A durable `Approved Removal` record is the sole structural exception and must have exactly its canonical H1, Approved status, section, and three fields.
10. `/spec-domain` reviews and atomically applies a coordinated foundation-and-use-case set. A conflicting `Draft` or `Review` must first be resolved through an explicitly selected `/spec-uc` continuation.
11. `/spec-impl` uses native plan approval for each cohesive implementation batch. When that mechanism is unavailable, one `AskUserQuestion` offers named approve and stop actions. One approval covers every vertical increment explicitly named in that batch; approval never carries into a later batch.
12. `/spec-reconcile <domain>` preserves staged, unstaged, and untracked work while repairing only deterministic structure in that domain. After validation it reviews every domain use case for evidence-backed consolidation candidates, but never merges them itself.
13. Return a concise outcome with changed paths, resulting status, validation, and recovery; do not echo complete artifacts.

Implementation plans are transient planning records, not specification artifacts, and use the host's native planning mechanism. `/spec-impl` chooses the largest cohesive, reviewable batch that can be safely implemented and validated without another product decision or material replan. A batch may cover the complete remaining use case and contains one or more ordered behavioral increments. Its compact approval record is headed by the desired outcome and contains `Decision`, `Approaches`, `Flow Changes`, `File Changes`, `Verification`, and `Next`; stable increment labels connect every affected file and exact edit to a distinguishing baseline and focused proof. `Approaches` records each resolved implementation decision, or states that existing architecture leaves no user choice, while plan approval separately authorizes implementation. It does not repeat accepted behavior except when a short rationale is needed to understand an implementation choice.

Group related normal, alternate, and exception behavior in one batch when it shares a public path, implementation responsibility, migration, fixture, or validation setup and can be safely reviewed together. Split into another batch only when later work depends on current evidence, needs an unresolved product or non-routine architectural decision, has a materially different blast radius or recovery boundary, requires an intermediate review point, or would make the current plan too broad to review reliably. Independent provability alone is not a reason for another approval. Never choose granularity by file, architecture layer, normal-versus-error path, or arbitrary size.

Each approved increment is implemented and proven in order without a new approval gate, then `/spec-impl` validates the complete batch and recomputes remaining conformance. Accepted work outside the approved scope receives another cohesive batch plan and fresh approval. The use case stays `Approved` until all contract areas and final coexistence checks pass; one completed batch never establishes `Implemented` without complete conformance verification. Clearly behavior-neutral editorial edits may be applied directly while preserving status; when classification is uncertain, use semantic review.

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

Use-case sequences are local and append-only. Allocate `max(existing sequence) + 1`; an empty sequence set has maximum zero, so the first use case is `001`.

When accepted behavior must be removed with no enduring interaction, the existing use-case file temporarily holds a canonical durable `Approved Removal` record. After behavior and tests are removed and the required absence is verified, `spec-impl` atomically deletes the artifact, removes or safely rewrites every `docs/spec` reference, and validates the resulting specification state; failure restores the captured pre-images.

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
