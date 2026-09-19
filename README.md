# Spec Skills

A small, explicit spec-driven workflow for Claude Code. The skills keep domain modeling, behavioral specification, and implementation separate without adding a large lifecycle framework.

## Skills

| Command | Purpose |
|---|---|
| `/spec-domain` | Create or revise a domain catalog and Entity Model, then identify candidate use cases. |
| `/spec-uc` | Create or revise one observable system use case and manage its review status. |
| `/spec-impl` | Plan, implement, test, and verify one approved use case. |

The skills are manual-only. Invoke them explicitly in this order when starting a new domain:

```text
/spec-domain
    ↓
/spec-uc
    ↓
/spec-impl
```

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

- The root catalog provides product context, the shared layout, and domain cards.
- A domain catalog defines scope, requirements, and its use-case index.
- An Entity Model defines concepts, properties, relationships, value types, policies, enumerations, and constraints.
- Each numbered file describes one observable use case.

## Use-Case Statuses

| Status | Meaning |
|---|---|
| `Draft` | A new use case is not yet accepted. |
| `Review` | A revision to previously accepted behavior is under review. |
| `Approved` | The behavior is accepted and ready for implementation. |
| `Implemented` | Code and behavior-derived tests conform, and required validation passes. |

`/spec-impl` rejects `Draft`, `Review`, and any use case containing an `## Open Questions` heading.

## Install

Copy the three skill directories into your project-local Claude Code skills directory:

```bash
mkdir -p /path/to/project/.claude/skills
cp -R spec-domain spec-uc spec-impl /path/to/project/.claude/skills/
```

For hosts that discover the Agent Skills convention under `.agents/skills/`:

```bash
mkdir -p /path/to/project/.agents/skills
cp -R spec-domain spec-uc spec-impl /path/to/project/.agents/skills/
```

## Usage

Create or reconstruct a domain:

```text
/spec-domain auto-routing
```

Define a use case:

```text
/spec-uc auto-routing/select-route-target
```

Implement an approved use case:

```text
/spec-impl auto-routing/002-select-route-target
```

Request an implementation plan without editing code:

```text
/spec-impl auto-routing/002-select-route-target plan only
```

## Compatibility

These skills intentionally use Claude Code frontmatter extensions:

```yaml
argument-hint: "..."
disable-model-invocation: true
user-invocable: true
```

Those fields provide explicit slash-command invocation and autocomplete hints. The strict portable `skills-ref` validator accepts only the base Agent Skills fields, so it reports these extensions as unexpected. This does not prevent Claude Code from using the skills.

## License

Released under the [MIT License](LICENSE).
