# Spec Skills

A small, explicit spec-driven workflow for Claude Code. The skills keep domain modeling, behavioral specification, implementation, and merge reconciliation separate without adding a large lifecycle framework.

## Skills

| Skill | Purpose |
|---|---|
| `spec-domain` | Create or revise a domain catalog and Entity Model, then identify candidate use cases. |
| `spec-uc` | Create or revise one observable system use case and manage its review status. |
| `spec-impl` | Plan, implement, test, and verify one approved use case. |
| `spec-reconcile` | Reconcile merged specification artifacts with no arguments while preserving reviewed content and user work. |

## Specification Layout

The skills maintain specifications under `docs/spec/`:

```text
docs/spec/
├── catalog.md
└── <domain>/
    ├── catalog.md
    ├── entity-model.md
    └── NNN-<use-case>.md
```

- The root catalog provides product context, specification authority, the shared layout, and an alphabetical set of linked domain headings with one-sentence descriptions.
- A domain catalog defines the domain boundary and self-contained requirement contracts with their owning use-case links.
- An Entity Model defines external dependencies, one relationship diagram, owned concepts and properties, concept-local invariants, and optional shared value types.
- Each numbered file describes one observable use case.

## Specification Authority

A project adopts this workflow when `docs/spec/catalog.md` exists. From that point, `docs/spec/` is authoritative for intended behavior:

- Root and domain catalogs and Entity Models are the reviewed specification foundation.
- `Approved` and `Implemented` use cases are accepted implementation contracts.
- `Draft` and `Review` use cases are authoritative records of proposals, but they are not implementation targets.
- Code and tests describe observed implementation. When they differ from an accepted specification, treat the difference as implementation drift rather than silently rewriting the specification.
- When specification artifacts contradict each other, stop for human resolution. Use `spec-domain` for foundation, scope, cross-use-case invariant, or terminology conflicts and `spec-uc` for one interaction's boundary or behavior.

## Review, Stage Gates, and Artifact Delivery

For semantic specification work, keep domain foundations and use cases distinct while making every actionable transition explicit:

1. Use `AskUserQuestion` whenever the user must authorize a persisted state transition, advance to another actionable stage, or transfer control to another specification skill. Narrative handoffs alone never authorize advancement.
2. When the user selects a cross-skill continuation, invoke that skill directly with the resolved artifact and reason. If invocation is unavailable or denied, preserve state and provide the exact command as a fallback.
3. Before changing a domain foundation, review a concise but behaviorally complete summary of the proposed semantics, decisions needed, assumptions or conflicts, and affected `docs/spec` paths. Do not persist a foundation change before explicit approval.
4. For a new use case or an existing `Draft` or `Review`, ask any required semantic question and wait for the answer before editing the persisted working artifact. Use an explicit save gate when no prior semantic answer already authorized that transition; then update it incrementally as behavior is confirmed and keep unresolved matters in `## Open Questions`.
5. Keep an `Approved` or `Implemented` use case unchanged while discussing a standalone semantic revision. Save it as a recoverable `Review` only after the applicable `AskUserQuestion` gate.
6. Do not request final approval or promote a `Draft` or `Review` after one resolved topic. Only when the complete use case is ready, resolve all decisions, remove `## Open Questions`, and obtain final confirmation through **Mark Approved** before writing `Approved`.
7. Every normal use-case artifact contains a required Mermaid overview between Trigger and Main Flow, with named process diagrams only when they clarify a complex nested process. A durable `Approved Removal` record is the only structural exception.
8. For a Coordinated Domain Change, `/spec-domain` discovers the foundation and all affected use cases, resolves semantic choices, presents one combined review, obtains one final whole-set `AskUserQuestion` approval, and immediately applies the complete set in the same workflow. It captures target pre-images and must finish the approved set or restore and validate those pre-images rather than report partial success.
9. An affected `Draft` or `Review` that conflicts with the proposed foundation blocks coordinated approval and application. Resolve it through an explicitly consented `/spec-uc` continuation; that workflow then offers direct continuation back to `/spec-domain`, which rediscovers the complete set.
10. `/spec-impl` uses the host's native plan-and-approval mechanism for the completed implementation plan as the sole non-`AskUserQuestion` actionable gate. It does not duplicate that approval; all other decisions and cross-skill transfers use `AskUserQuestion`.
11. `/spec-reconcile` is a no-argument repository-wide structural coordinator for an active merge, a just-completed merge, or an audit-only run. It treats committed merge parents, index stages, and staged, unstaged, and untracked `docs/spec` work as inputs; it repairs only deterministic domain, catalog, link, and concurrent-sequence differences, asks the user to decide every semantic conflict, and never stages files or completes a merge.
12. Return a concise outcome with changed paths, resulting status, and validation; do not echo complete file contents.

Implementation plans are transient planning records, not specification artifacts, and use the host's native planning mechanism. Clearly behavior-neutral editorial edits may be applied directly while preserving status; when classification is uncertain, use semantic review.

## Merge Reconciliation

Invoke `/spec-reconcile` with no arguments from the repository root after `git merge` pauses or after a merge completes. During an active merge it reads the merge base, ours, theirs, index stages, and current working tree; staged, unstaged, and untracked `docs/spec` changes are preserved as a fourth input. Committed concurrent use cases are ordered by first-introducing-commit time and path, while uncommitted additions follow their current numeric sequence and path; filesystem timestamps are not used. Semantic conflicts are presented for user choice and routed to `/spec-domain` or `/spec-uc`; deterministic repairs leave the index untouched, and the user reviews, stages, and completes the merge manually.

## Domain Catalog Structure

A domain catalog starts with its definition and Entity Model link, followed by:

1. `Boundary` contains one broad `Owns` statement and one broad `Excludes` statement.
2. `Requirements` contains one H3 section per coherent domain responsibility.
3. Every requirement has `Capabilities` and may add only the `Guarantees`, `Constraints`, and existing `Use cases` it owns; empty optional fields are omitted. Render each `Use cases` field as a nested Markdown list with one link per bullet.
4. A use case may be linked by multiple requirements when it materially implements each one. Domain catalogs contain no separate use-case index.

## Entity Model Structure

Entity Models use a compact, fixed reading order:

1. `External Concepts` defines connected concepts owned elsewhere and is omitted when empty.
2. `Entity Relationship Diagram` is one Mermaid `erDiagram` and is the sole source of relationships and relationship cardinalities. Labels use active source-to-target verbs, preferring `owns`, `contains`, `uses`, `references`, `maps_to`, `compares_to`, `results_in`, and `affects`.
3. `Concepts` defines owned concepts, properties, and only necessary concept-local invariants; it contains no relationship tables.
4. `Shared Value Types` is optional and contains only reused values or values with important reusable representation or security semantics.

Closed enumeration values belong in their owning property rows. Entity Models have no global `Policies`, `Concept Constraints`, or `Enumerations` sections; requirements own domain obligations and use cases own interaction behavior.

## Use-Case Boundaries

One use case covers one externally meaningful primary-actor goal, from an observable trigger through meaningful postconditions. Keep expected variants and visible failures in the same use case when they serve that goal. Split independent goals, not individual buttons, endpoints, CRUD operations, validations, internal components, or flow steps.

## Use-Case Statuses

| Status | Meaning |
|---|---|
| `Draft` | An editable persisted new use case under discussion; it may contain Open Questions and cannot be implemented. |
| `Review` | An editable persisted revision to accepted behavior under discussion; it may contain Open Questions and cannot be implemented. |
| `Approved` | The documented behavior is accepted for implementation. A use case approved for complete removal temporarily stores that accepted removal contract until deletion is implemented and verified. |
| `Implemented` | Code and behavior-derived tests conform, and required validation passes. |

New behavior is normally persisted as a `Draft` and revised behavior as a recoverable `Review` after the applicable `AskUserQuestion` save gate. Both remain open for incremental discussion until the complete artifact is ready for **Mark Approved**; only then is it promoted to `Approved`.

When accepted behavior must be removed with no enduring interaction, the existing use-case file temporarily holds a durable `Approved Removal` record. The file and its owning-requirement links remain until `spec-impl` removes the behavior and tests, verifies the required absence, and deletes both the artifact and links.

## Validation

Run the Claude workflow contract checks from the repository root:

```bash
bash tests/validate-skills.sh
```

The checks protect catalog requirement contracts and owning-use-case links, Entity Model structure and rule ownership, actionable stage gates, direct cross-skill continuation, required use-case structure, single-workflow coordinated changes and recovery, rename handling, durable removals, and source skill identity.

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
