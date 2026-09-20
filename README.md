# Spec Skills

A small, explicit spec-driven workflow for Claude Code and Codex. The skills keep domain modeling, behavioral specification, and implementation separate without adding a large lifecycle framework.

## Skills

| Skill | Purpose |
|---|---|
| `spec-domain` | Create or revise a domain catalog and Entity Model, then identify candidate use cases. |
| `spec-uc` | Create or revise one observable system use case and manage its review status. |
| `spec-impl` | Plan, implement, test, and verify one approved use case. |

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
- A domain catalog defines scope, requirements, and its use-case index.
- An Entity Model defines concepts, properties, relationships, value types, policies, enumerations, and constraints.
- Each numbered file describes one observable use case.

## Specification Authority

A project adopts this workflow when `docs/spec/catalog.md` exists. From that point, `docs/spec/` is authoritative for intended behavior:

- Root and domain catalogs and Entity Models are the reviewed specification foundation.
- `Approved` and `Implemented` use cases are accepted implementation contracts.
- `Draft` and `Review` use cases are authoritative records of proposals, but they are not implementation targets.
- Code and tests describe observed implementation. When they differ from an accepted specification, treat the difference as implementation drift rather than silently rewriting the specification.
- When specification artifacts contradict each other, stop for human resolution. Use `spec-domain` for foundation, scope, shared-policy, or terminology conflicts and `spec-uc` for one interaction's boundary or behavior.

## Review and Artifact Delivery

For semantic specification work, keep domain foundations and use cases distinct:

1. Before changing a domain foundation, review a concise but behaviorally complete summary of the proposed semantics, decisions needed, assumptions or conflicts, and affected `docs/spec` paths. Do not persist a foundation change before explicit approval.
2. For a new use case or an existing `Draft` or `Review`, ask any required semantic question and wait for the answer before editing the persisted working artifact. Then update it incrementally as behavior is confirmed; keep unresolved matters in `## Open Questions`.
3. Keep an `Approved` or `Implemented` use case unchanged while discussing a semantic revision. When the user explicitly asks to save the working revision, write it as a recoverable `Review`.
4. Do not request final approval or promote a `Draft` or `Review` after one resolved topic. Only when the user explicitly asks to finalize the complete use case, resolve all decisions, remove `## Open Questions`, and obtain final confirmation before writing `Approved`.
5. Every normal use-case artifact contains a required Mermaid overview between Trigger and Main Flow, with named process diagrams only when they clarify a complex nested process. A durable `Approved Removal` record is the only structural exception.
6. For a Coordinated Domain Change, approve every foundation and use-case member before writing any finalized member. `/spec-domain` is the sole application coordinator and writes the complete approved set in one uninterrupted application phase.
7. Return a concise handoff with changed paths, resulting status, and validation; do not echo complete file contents.

Implementation plans are transient planning records, not specification artifacts, and may use the host's native planning mechanism. Clearly behavior-neutral editorial edits may be applied directly while preserving status; when classification is uncertain, use semantic review.

## Use-Case Boundaries

One use case covers one externally meaningful primary-actor goal, from an observable trigger through meaningful postconditions. Keep expected variants and visible failures in the same use case when they serve that goal. Split independent goals, not individual buttons, endpoints, CRUD operations, validations, internal components, or flow steps.

## Use-Case Statuses

| Status | Meaning |
|---|---|
| `Draft` | An editable persisted new use case under discussion; it may contain Open Questions and cannot be implemented. |
| `Review` | An editable persisted revision to accepted behavior under discussion; it may contain Open Questions and cannot be implemented. |
| `Approved` | The documented behavior is accepted for implementation. A use case approved for complete removal temporarily stores that accepted removal contract until deletion is implemented and verified. |
| `Implemented` | Code and behavior-derived tests conform, and required validation passes. |

New behavior is normally persisted as a `Draft` and revised behavior as a recoverable `Review` when the user asks to save it. Both remain open for incremental discussion until the user explicitly requests finalization; only then is the artifact promoted to `Approved`.

When accepted behavior must be removed with no enduring interaction, the existing use-case file temporarily holds a durable `Approved Removal` record. The file and catalog row remain until `spec-impl` removes the behavior and tests, verifies the required absence, and deletes both specification entries.

## Validation

Run the Claude workflow contract checks from the repository root:

```bash
bash tests/validate-skills.sh
```

The checks protect required use-case structure, coordinated-change ownership, rename handling, durable removals, and source skill identity.

## Install Globally

Choose the host explicitly:

```bash
bash install.sh claude
bash install.sh codex
bash install.sh all
```

The default destinations are:

| Host | Destination |
|---|---|
| Claude Code | `~/.claude/skills/` |
| Codex | `~/.agents/skills/` |

The installer refuses to replace different installed copies unless you pass `--force`:

```bash
bash install.sh all --force
```

Claude Code receives the source skills unchanged. Codex receives compatible installed copies with Claude-specific frontmatter removed and cross-skill command references converted to Codex skill syntax. The repository source files are not modified.

## Compatibility

The source skills intentionally use Claude Code frontmatter extensions:

```yaml
argument-hint: "..."
disable-model-invocation: true
user-invocable: true
```

The strict portable `skills-ref` validator reports those fields as unexpected. The Codex installer removes them from installed copies.

## License

Released under the [MIT License](LICENSE).
