---
name: spec-domain
description: Create, reconstruct, or revise a bounded product domain as reviewed requirements and an entity model under docs/spec. Use when explicitly invoked to establish or change a domain boundary, extract intended behavior from existing evidence, or reorganize domain specifications.
disable-model-invocation: true
user-invocable: true
argument-hint: "<domain> [brief-or-scope]"
---

# Specify Domain

Create, reconstruct, or revise the specification foundation for one bounded product domain. Before this workflow is adopted, existing code, tests, plans, and documentation are evidence for human review. After `docs/spec/catalog.md` exists, `docs/spec/` is authoritative for intended behavior, while code and tests remain evidence of observed implementation.

Detailed use-case semantics are reviewed through `/spec-uc`. For an approved Coordinated Domain Change, this skill is the sole application coordinator and may write use-case artifacts already reviewed there.

## Input

The user provides a domain name and may provide a brief, scope, or evidence paths. Normalize the directory name to lowercase kebab case without changing the human-readable title.

## User Decisions and Approval

Call `AskUserQuestion` whenever a user decision is needed before recording a semantic change as settled. Give only the needed context and concrete mutually exclusive options, with the recommended option first; do not ask the user to decide repository facts or leave actionable choices only in a summary or handoff. **For every semantic foundation change that needs a decision, call `AskUserQuestion` and wait for the answer before using Write/Edit on any specification file.** Resolve summary decisions before requesting final approval through `AskUserQuestion`, and continue independent discovery while answers are pending when possible. Never write a semantic change before the required decisions and approval.

## Invariants

- Store specifications only under `docs/spec/`.
- Each domain owns one `catalog.md`, one `entity-model.md`, and flat numbered use cases created by `/spec-uc`.
- The root catalog contains product context, specification authority, the shared path convention, and one linked heading with a one-sentence description per domain.
- Domain catalogs contain no use-case status, owner, date, or progress fields.
- Existing non-specification documents remain where they are unless the user separately requests a move.
- This skill changes specification documents only, never application code or tests.

## Specification Authority

When `docs/spec/catalog.md` exists, root and domain catalogs and Entity Models are the reviewed foundation; `Approved` and `Implemented` use cases are accepted implementation contracts; and `Draft` and `Review` use cases are authoritative proposals, not implementation targets. Code and tests remain evidence of observed implementation, and differences from accepted specifications are implementation drift.

Stop on specification contradictions. Route product, domain, requirement, Entity Model, shared-policy, and terminology conflicts to `/spec-domain`; route one interaction's behavior or status conflicts to `/spec-uc`.

## Stage 1 — Discover and Propose

1. Read the repository's `AGENTS.md`, `CLAUDE.md`, or equivalent instructions.
2. Read `docs/spec/catalog.md` when present and inspect neighboring domain catalogs and Entity Models.
3. Inspect relevant product documents, source, tests, and historical plans, using Specification Authority to distinguish intended behavior from implementation evidence.
4. Separate stated intent, observed behavior, implementation drift, contradictions, gaps, and assumptions. Surface conflicts inside the specification set instead of resolving them from code.
5. Bound the domain around one coherent product capability. Propose smaller domains when the vocabulary or responsibility is not comfortably reviewable as one unit.
6. Identify atomic requirements, Entity Model concepts and properties, relationships, value types, shared policies, enumerations, concept constraints, and candidate use cases.
7. Screen each candidate as one externally meaningful primary-actor goal spanning an observable trigger through a meaningful outcome. Keep variants and failures serving the same goal together; do not create separate candidates merely for endpoints, buttons, CRUD operations, internal components, validations, or individual steps. Split independently valuable goals, triggers, or outcomes.
8. Identify existing use cases affected by a proposed domain-boundary or Entity Model change. Do not rewrite them in this skill.

Before any semantic write, prepare only this concise review summary and ask all required questions before editing:

```markdown
# Domain Review: [Domain]

## Proposed Semantic Changes

- **Product or domain definition:** [Behaviorally material change, if any.]
- **Boundary and scope:** [Owns, excludes, and responsibility changes.]
- **Requirements:** [Atomic capabilities, outcomes, qualities, and external obligations.]
- **Entity Model:** [Concepts, relationships, value types, policies, enumerations, and constraints that would change.]
- **Candidate use cases:** [Names and one observable outcome each.]

## Affected Accepted Use Cases

## Decisions Needed

## Contradictions and Assumptions

## Evidence Consulted

## Affected Specification Paths
```

The summary must expose every behaviorally material choice without reproducing a complete catalog or Entity Model. Do not print or persist generated specification artifacts before approval, choose business intent, or interpret silence as approval. Keep existing accepted files unchanged.

## Coordinated Domain Changes

When a proposed domain or Entity Model change affects existing `Approved` or `Implemented` use cases, `/spec-domain` is the sole application coordinator:

1. Keep every persisted specification unchanged while reviewing a concise pending-change summary.
2. List every affected use-case path and exact `/spec-uc` command.
3. The user invokes `/spec-uc` in the same session for each affected use case. That skill reviews each use case against the pending summary, records explicit approval, and writes no coordinated member.
4. Obtain explicit approval for the foundation and every affected use case before application. If any member is unresolved or rejected, write none of them.
5. After every member is approved, direct the user back to `/spec-domain ... apply coordinated change`.
6. On that invocation, re-read every target and approved summary. If anything requires a new semantic decision, stop without writing and return the affected member to review.
7. Otherwise use Write/Edit to apply the complete approved foundation and use-case set in one uninterrupted application phase, even though `/spec-uc` ordinarily owns detailed use-case artifacts.
8. Cross-validate the complete set before reporting success. If application is interrupted or a write fails, finish the approved set or restore the pre-application state before claiming consistency.

## Stage 2 — Write After Explicit Approval

After explicit approval:

1. Re-read every target file so the merge uses current content. If this exposes a new semantic decision, prepare it and ask the user before writing.
2. Use Write/Edit only after every required `AskUserQuestion` answer and explicit approval; generate complete specification artifacts directly under `docs/spec`, not in the response.
3. For `apply coordinated change`, follow Coordinated Domain Changes as the sole application coordinator.
4. If `docs/spec/catalog.md` is absent, create the canonical root structure below.
5. If the root catalog exists, preserve its product definition, Specification Authority section, and Structure section unless the user explicitly approved a shared change. Add or update only the affected linked domain heading and description and preserve unrelated entries.
6. Create or merge `docs/spec/<domain>/catalog.md` and `entity-model.md`.
7. For a new domain, leave the Use Cases table empty. Do not add links to files that do not exist.
8. For an existing domain, preserve unrelated use-case rows and detailed use-case files.
9. If the accepted domain or Entity Model change would contradict an existing `Approved` or `Implemented` use case and this is not an approved coordinated application, follow Coordinated Domain Changes; do not write the foundation independently.
10. Report other affected use cases as `/spec-uc` follow-ups without changing their content or status.
11. Apply focused deltas rather than regenerating reviewed documents.
12. Do not persist evidence lists, traceability IDs, lifecycle history, or generated metadata in the specification set.

## Canonical Postapproval File Structures

Use these structures to generate files with Write/Edit after approval. They are not response templates.

### `docs/spec/catalog.md`

````markdown
# Product Specifications

[One short product definition.]

## Specification Authority

The presence of this catalog means the project has adopted the specification workflow. Within `docs/spec/`:

- Root and domain catalogs and Entity Models are the reviewed specification foundation.
- `Approved` and `Implemented` use cases are accepted implementation contracts.
- `Draft` and `Review` use cases are authoritative records of proposals, but they are not implementation targets.
- Code and tests describe observed implementation. When they differ from an accepted specification, treat the difference as implementation drift rather than silently rewriting the specification.
- When specification artifacts contradict each other, stop for human resolution. Use `/spec-domain` for conflicts in the product definition, domain boundaries, requirements, Entity Model, shared policies, or shared terminology, and `/spec-uc` for one interaction's goal, boundary, flows, outcomes, or status.

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

[One-sentence domain description.]
````

State the path convention and authority policy once. Sort domain entries alphabetically. Each entry contains one linked H3 domain name followed by one description paragraph. Do not add a standalone code-formatted directory-name line; the link already identifies the path.

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

- Confirm the root Domains entries link to domain catalogs, all links resolve, entries are alphabetical, and each linked H3 is followed by one description without a standalone directory-name line.
- Confirm the root catalog contains the canonical Specification Authority semantics.
- Confirm domain-catalog links resolve.
- Confirm the Entity Model uses explicit properties, cardinality, and relationships consistently.
- Confirm every non-primitive property type and relationship target resolves to a Concept, External Concept, Value Type, Policy, or Enumeration.
- Confirm conditional cardinality is represented with unconditional cardinality plus a separate state-dependent constraint.
- Confirm normative statements are owned by exactly one layer: domain requirement, Entity Model policy/constraint, or use-case flow/postcondition. Downstream layers may elaborate but must not duplicate them.
- Confirm candidate use cases each span one externally meaningful primary-actor goal from an observable trigger through one meaningful outcome.
- Confirm variants and failures serving the same goal were not split into separate candidates, and independently valuable goals, triggers, or outcomes were not bundled.
- Confirm no candidate exists merely for an endpoint, button, CRUD operation, internal component, validation, or individual step.
- Confirm no nonexistent use-case files are linked.
- For ordinary domain work, confirm existing use-case files and statuses were not modified. For a coordinated application, validate the complete set under Coordinated Domain Changes.
- Confirm no status dashboard, owner/date field, identifier registry, persisted implementation plan, or code traceability instruction was introduced.

## Handoff

Report only a concise handoff: changed paths, resulting state, approved assumptions, unresolved decisions, affected existing use cases, and validation performed. For a pending coordinated set, give the exact `/spec-uc` review commands or final `/spec-domain ... apply coordinated change` command as appropriate. Do not echo complete file contents.
