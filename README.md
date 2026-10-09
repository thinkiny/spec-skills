# Spec Skills

A small, explicit spec-driven workflow for Claude Code. The skills keep domain modeling, behavioral specification, implementation, and merge reconciliation separate without adding a large lifecycle framework.

## Skills

| Skill | Purpose |
|---|---|
| `spec-domain` | Create or revise a domain specification and Entity Model, then identify candidate use cases. It accepts a free-form request and infers the domain, asking the user to choose only when resolution is ambiguous. |
| `spec-uc` | Create, revise, split, consolidate, or review one observable use-case goal. It requires the domain, infers the use case from the request, and asks only when the target is ambiguous. |
| `spec-impl` | Capture code-path evidence, execute approved code plans, verify behavior, and optionally maintain implementation records. |
| `spec-reconcile` | Reconcile one merged specification domain, optional implementation records, and deterministic references, then identify use cases that may be consolidated. |

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
- A domain document starts with a compact table of contents, then defines the boundary and domain-wide requirement contracts with links to their use cases.
- An Entity Model defines external and owned concepts, their properties, relationships, invariants, and shared value types. Every Entity Model keeps its Mermaid relationship diagram.
- Each numbered file describes one observable use case and keeps a concise, UI-independent Mermaid overview.
- Each optional matching file under `implementation/` is a lightweight navigation aid: a short implementation summary, entry, key locations, and verification state. It links back to the use case and is observed-code evidence, not semantic authority.

## Validate Specifications

Use the shared mechanical checker after specification structure or link changes:

```bash
python3 "$HOME/.claude/skills/spec-validator/validate_spec.py" docs/spec
python3 "$HOME/.claude/skills/spec-validator/validate_spec.py" docs/spec/<domain>
```

`install.sh` installs the shared checker at that path. The path argument may also be one use-case or implementation file. Use `--repo-root PATH` when the specification tree is outside the repository containing the linked source files. Within the selected scope, the checker validates the required catalog and domain foundation, domain navigation and ownership links, use-case structure and diagrams, sequence uniqueness, local links, and optional implementation records. It does not replace semantic, code, runtime, or test verification.

## Specification Authority

A project adopts this workflow when `docs/spec/catalog.md` exists. From that point, the semantic specification artifacts in `docs/spec/` are authoritative for intended behavior; files under `implementation/` remain observed-code evidence:

- The root catalog, domain documents, and Entity Models are the reviewed specification foundation.
- `Approved` and `Implemented` use cases are accepted implementation contracts.
- `Draft` and `Review` use cases are authoritative records of proposals, but they are not implementation targets.
- Code and tests describe observed implementation. When they differ from an accepted specification, treat the difference as implementation drift rather than silently rewriting the specification.
- When specification artifacts contradict each other, stop for human resolution before changing affected behavior.

## Workflow

- `/spec-domain` owns the catalog, domain boundaries, requirements, Entity Models, and coordinated changes to affected use cases.
- `/spec-uc` owns one interaction artifact. Persisted Draft and Review files keep the canonical sections and Mermaid Overview, record unresolved decisions in Open Questions, and never change the domain foundation.
- `/spec-impl` implements or verifies accepted behavior. Its compact implementation record is optional and contains only a backlink, summary, entry, key locations, and verification state.
- `/spec-reconcile <domain>` repairs deterministic merge structure without deciding semantics or altering the Git index.
- A named user action authorizes every specification write or cross-skill handoff. Multi-path changes apply as one recoverable set. Implementation batches use the host's plan approval.

The individual skills are the normative workflow instructions. This README describes their boundaries and artifact formats without duplicating their complete stage-gate, recovery, or implementation-planning procedures.

## Merge Reconciliation

Invoke `/spec-reconcile <domain>` after `git merge` pauses or completes. It scopes inventory, conflicts, sequence repair, writing, and gating validation to that domain, its changed root-catalog entry, and confirmed references to its paths; other-domain failures are reported separately and do not roll back a valid scoped repair. Committed additions are ordered by their first-introducing commit's committer timestamp (`%ct`) and source-relative path, followed by uncommitted additions in current sequence order. An empty merge-base sequence set has maximum zero, so its first allocation is `001`. Ambiguous provenance and semantic conflicts stop for user resolution, and deterministic repairs never alter the index.

After the selected domain is conflict-free and mechanically validated, reconciliation reviews every use case of every status. It proposes consolidation only for artifacts that appear to express one primary-actor goal with compatible triggers, outcomes, and flow behavior—not merely shared entities, requirements, or implementation. It never performs the merge; the user may continue into `/spec-uc` for independent semantic review. Completion guidance follows the detected mode: continue a merge only for Active Merge, commit reconciliation changes as appropriate for Completed Merge, and treat Audit Only repairs as ordinary changes.

## Domain Document Structure

A domain document starts with its definition and Entity Model link, followed by:

1. `Contents` links to `Boundary`, `Requirements`, and every requirement heading in document order. It does not link fields or use cases.
2. `Boundary` contains one broad `Owns` statement and one broad `Excludes` statement.
3. `Requirements` contains one H3 section per coherent domain responsibility.
4. Every requirement has a short `Capabilities` list and may add only the `Guarantees`, `Constraints`, and existing `Use cases` lists it owns; empty optional sections are omitted.
5. A use case may be linked by multiple requirements when it materially implements each one. Domain documents contain no separate use-case index.

## Entity Model Structure

Entity Models use a compact, fixed reading order:

1. `External Concepts` defines connected concepts owned elsewhere and is omitted when empty.
2. `Entity Relationship Diagram` is one Mermaid `erDiagram` and is the sole source of relationships and relationship cardinalities. Labels use active source-to-target verbs, preferring `owns`, `contains`, `uses`, `references`, `maps_to`, `compares_to`, `results_in`, and `affects`.
3. `Concepts` defines owned concepts, complete property tables, and only necessary concept-local invariants; it contains no relationship tables, UI behavior, code mechanics, or interaction procedure.
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

New behavior is normally persisted as `Draft`. Revised accepted behavior may be persisted as `Review` only after the exact current accepted content and status have been captured. Both keep the canonical structure, remain open until **Mark Approved**, and cannot change requirements or the Entity Model; required foundation work returns to `spec-domain` first.

Use-case sequences are local to each domain root and append-only. Allocate `max(existing sequence) + 1`; an empty sequence set has maximum zero, so the first use case is `001`.

When accepted behavior must be removed with no enduring interaction, the existing use-case file temporarily holds a canonical durable `Approved Removal` record. After behavior and tests are removed and the required absence is verified, `spec-impl` atomically deletes the use-case and any matching implementation record, removes or safely rewrites every `docs/spec` reference, and validates the resulting specification state; failure restores the captured pre-images.

## Install Globally

Install the Claude Code skills with one command:

```bash
bash install.sh
```

The installer replaces changed copies in `~/.claude/skills/`, retains identical copies, and does not modify the repository source files.

## Compatibility

The source skills intentionally use Claude Code frontmatter extensions:

```yaml
argument-hint: "..."
user-invocable: true
```

The skills remain directly user-invocable and are also visible to Claude so an explicit `AskUserQuestion` selection can continue into another specification skill. The strict portable `skills-ref` validator reports these fields as unexpected.

## License

Released under the [MIT License](LICENSE).
