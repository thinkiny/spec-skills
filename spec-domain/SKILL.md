---
name: spec-domain
description: Create, reconstruct, or revise a bounded product domain as reviewed requirements and an entity model under docs/spec. Use when explicitly invoked to establish or change a domain boundary, extract intended behavior from existing evidence, or reorganize domain specifications.
disable-model-invocation: true
user-invocable: true
argument-hint: "<domain> [brief-or-scope]"
---

# Specify Domain

Create, reconstruct, or revise the specification foundation for one bounded product domain. Existing code, tests, plans, and documentation are evidence of current behavior; they do not become intended behavior without human review.

Detailed use-case files belong exclusively to `/spec-uc`. This skill identifies candidate use cases but does not create or revise them.

## Input

The user provides a domain name and may provide a brief, scope, or evidence paths. Normalize the directory name to lowercase kebab case without changing the human-readable title.

## Invariants

- Store specifications only under `docs/spec/`.
- Each domain owns one `catalog.md`, one `entity-model.md`, and flat numbered use cases created by `/spec-uc`.
- The root catalog contains product context, the shared path convention, and one compact card per domain.
- Domain catalogs contain no use-case status, owner, date, or progress fields.
- Existing non-specification documents remain where they are unless the user separately requests a move.
- This skill changes specification documents only, never application code or tests.

## Stage 1 — Discover and Propose

1. Read the repository's `AGENTS.md`, `CLAUDE.md`, or equivalent instructions.
2. Read `docs/spec/catalog.md` when present and inspect neighboring domain catalogs and entity models.
3. Inspect relevant product documents, source, tests, and historical plans. Use code and tests to establish observed behavior, not to decide intended behavior silently.
4. Separate stated intent, observed behavior, contradictions, gaps, and assumptions.
5. Bound the domain around one coherent product capability. Propose smaller domains when the vocabulary or responsibility is not comfortably reviewable as one unit.
6. Identify atomic requirements, entity-model concepts and properties, relationships, value types, shared policies, enumerations, concept constraints, and candidate one-goal use cases.
7. Identify existing use cases affected by a proposed domain-boundary or entity-model change. Do not rewrite them in this skill.

Present this packet before writing:

```markdown
# Domain Review: [Domain]

## Proposed Product Definition

[Include only when creating the root catalog or when the user explicitly requested a product-definition change.]

## Proposed Definition

## Proposed Scope

### Owns

### Excludes

## Proposed Requirements

| Type | Name | Requirement |
|---|---|---|

## Proposed Entity Model

### Concepts

| Concept | Definition |
|---|---|

### Relationships, Value Types, Policies, and Constraints

## Candidate Use Cases

| Suggested Order | Use Case | One Observable Outcome |
|---:|---|---|

## Affected Existing Use Cases

## Contradictions and Assumptions

## Decisions Needed

## Evidence Consulted

## Files That Would Be Created or Updated
```

Stop after the packet. Do not write files, choose business intent, or interpret silence as approval.

## Coordinated Domain Changes

When a proposed domain or Entity Model change affects existing `Approved` or `Implemented` use cases:

1. Keep the domain proposal conversation-only.
2. List every affected use-case path and exact `/spec-uc` command.
3. The user invokes `/spec-uc` in the same session. That skill reviews each use case against the pending domain packet rather than treating the stored foundation as the proposed intent.
4. Keep all proposed domain and use-case edits conversation-only until the foundation and every affected use case are accepted.
5. Apply the accepted root catalog, domain catalog, Entity Model, and use-case revisions in one working-tree change set. `/spec-domain` writes the foundation; `/spec-uc` writes the accepted use cases immediately afterward.
6. Do not report the coordinated change complete until every file is written and cross-validated. If the sequence is interrupted before application, leave persisted specifications unchanged.

## Stage 2 — Create or Merge After Review

After explicit review:

1. Re-read every target file so the merge uses current content.
2. If `docs/spec/catalog.md` is absent, create the canonical root structure below.
3. If the root catalog exists, preserve its product definition and Structure section unless the user explicitly requested a shared-structure change. Add or update only the affected domain card and preserve unrelated cards.
4. Create or merge `docs/spec/<domain>/catalog.md` and `entity-model.md`.
5. For a new domain, leave the Use Cases table empty. Do not add links to files that do not exist.
6. For an existing domain, preserve unrelated use-case rows and detailed use-case files.
7. If the accepted domain or Entity Model change would contradict an existing `Approved` or `Implemented` use case, follow Coordinated Domain Changes; do not write the foundation independently.
8. Report other affected use cases as `/spec-uc` follow-ups without changing their content or status.
9. Apply focused deltas rather than regenerating reviewed documents.
10. Do not persist evidence lists, traceability IDs, lifecycle history, or generated metadata in the specification set.

## Canonical Structures

### `docs/spec/catalog.md`

````markdown
# Product Specifications

[One short product definition.]

## Structure

Each domain uses the same layout:

```text
<domain>/
├── catalog.md
├── entity-model.md
└── NNN-<use-case>.md
```

- `catalog.md` defines the domain, scope, requirements, and use-case index.
- `entity-model.md` defines concepts, properties, relationships, policies, enumerations, and concept constraints.
- `NNN-<use-case>.md` defines one observable system use case.
- Use-case sequence numbers are append-only and local to the domain.

## Domains

### [[Domain]]([domain]/catalog.md)

`[domain]/`

[One-sentence domain definition.]
````

State the path convention once. Each domain card contains only a linked name, directory, and one-sentence definition. Sort cards alphabetically.

### `docs/spec/<domain>/catalog.md`

```markdown
# [Domain] Catalog

## Domain

| Property | Value |
|---|---|
| Name | [Domain] |
| Definition | [One-sentence definition.] |
| Entity Model | [[Domain] Entity Model](entity-model.md) |

## Scope

| Kind | Capability |
|---|---|
| Owns | [Behavior owned by this domain] |
| Excludes | [Closely related behavior owned elsewhere] |

## Requirements

| Type | Name | Requirement |
|---|---|---|
| Functional | [Short name] | [One atomic capability or outcome.] |
| Quality | [Short name] | [One measurable quality.] |
| Constraint | [Short name] | [One external or domain-wide obligation.] |

## Use Cases

| Sequence | Use Case | Outcome |
|---:|---|---|
```

The domain catalog owns definition, scope, requirements, and use-case navigation. Requirement constraints are external or domain-wide obligations such as access, compatibility, security, or platform boundaries. They do not restate concept invariants from the Entity Model.

### `docs/spec/<domain>/entity-model.md`

```markdown
# [Domain] Entity Model

## Concepts

### [Concept]

[Definition in domain language.]

#### Properties

| Property | Type | Cardinality | Meaning | Constraints |
|---|---|---:|---|---|
| [Property] | [Type or concept] | [1, 0..1, 0..*, or 1..*] | [Domain meaning] | [Property constraint] |

#### Relationships

| Relationship | Target | Cardinality | Meaning |
|---|---|---:|---|
| [Relationship] | [Concept] | [1, 0..1, 0..*, or 1..*] | [Meaning] |

## External Concepts

### [External Concept]

[Definition and the facts this domain relies on.]

## Value Types

| Type | Meaning | Constraints |
|---|---|---|
| [Value Type] | [Domain meaning] | [Validation or representation constraint] |

## Policies

### [Policy]

- [Shared behavioral rule involving domain concepts.]

## Enumerations

### [Enumeration]

| Value | Meaning |
|---|---|
| [Value] | [Domain meaning.] |

## Concept Constraints

- [Invariant about concepts, properties, cardinality, or relationships.]
```

`External Concepts`, `Value Types`, `Policies`, and `Enumerations` are optional.

Treat `String`, `Boolean`, `Integer`, `Decimal`, `Duration`, and `Timestamp` as built-in primitives unless the project defines stricter domain types. Define every other property type and relationship target as a Concept, External Concept, Value Type, Policy, or Enumeration. Use cardinality for multiplicity instead of inventing collection types such as `Thing Set`.

Use cardinality for all valid lifecycle states. Put state-dependent minimums or maximums in a property constraint, policy, or Concept Constraint. For example, if a disabled draft may have no targets, model `contains Route Target` as `0..*` and add the constraint “An enabled Route Model has at least one enabled Route Target.”

Entity Model constraints are semantic invariants about concepts, properties, or relationships. Domain-catalog constraints are external or domain-wide obligations. Interaction-specific behavior belongs in use-case flows and postconditions. Keep each normative statement in exactly one layer.

`/spec-domain` owns domain boundaries, broad shared-policy changes, Entity Model restructuring, and terminology-wide changes. `/spec-uc` may apply only the smallest catalog or Entity Model delta directly required by one accepted use case. Any change that affects multiple use cases or redefines domain scope returns to `/spec-domain`.

Exclude SQL types, indexes, ORM tags, migrations, controllers, services, caches, and implementation-only fields.

## Validation

Before reporting completion:

- Confirm the root card links to the domain catalog.
- Confirm domain-catalog links resolve.
- Confirm the Entity Model uses explicit properties, cardinality, and relationships consistently.
- Confirm every non-primitive property type and relationship target resolves to a Concept, External Concept, Value Type, Policy, or Enumeration.
- Confirm conditional cardinality is represented with unconditional cardinality plus a separate state-dependent constraint.
- Confirm normative statements are owned by exactly one layer: domain requirement, Entity Model policy/constraint, or use-case flow/postcondition. Downstream layers may elaborate but must not duplicate them.
- Confirm candidate use cases each have one observable outcome.
- Confirm no nonexistent use-case files are linked.
- Confirm existing use-case files and statuses were not modified.
- Confirm no status dashboard, owner/date field, identifier registry, persisted implementation plan, or code traceability instruction was introduced.

## Handoff

Report files changed, accepted assumptions, unresolved decisions, affected existing use cases, evidence used only for discovery, and validation performed. List the exact `/spec-uc` commands needed to create candidate use cases or reconcile affected ones.
