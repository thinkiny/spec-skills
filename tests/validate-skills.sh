#!/usr/bin/env bash
# Contract assertions are literal Markdown and must not expand shell expressions.
# shellcheck disable=SC2016

set -euo pipefail

ROOT="$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

require_text() {
  local file="$1"
  local text="$2"
  grep -Fq -- "$text" "$file" || fail "$file is missing required contract text: $text"
}

reject_text() {
  local file="$1"
  local text="$2"
  if grep -Fq -- "$text" "$file"; then
    fail "$file contains stale contract text: $text"
  fi
}

check_skill_name() {
  local skill="$1"
  local file="$ROOT/$skill/SKILL.md"
  local declared_name

  [[ -f "$file" ]] || fail "missing source skill: $file"
  declared_name="$(awk '
    NR == 1 && $0 != "---" { exit 2 }
    /^name: / { sub(/^name: /, ""); print; exit }
  ' "$file")"
  [[ "$declared_name" == "$skill" ]] || fail "$file declares '$declared_name', expected '$skill'"
}

for skill in spec-domain spec-uc spec-impl spec-reconcile; do
  check_skill_name "$skill"
done

DOMAIN="$ROOT/spec-domain/SKILL.md"
USE_CASE="$ROOT/spec-uc/SKILL.md"
IMPLEMENTATION="$ROOT/spec-impl/SKILL.md"
RECONCILIATION="$ROOT/spec-reconcile/SKILL.md"
README="$ROOT/README.md"
INSTALLER="$ROOT/install.sh"

for file in "$DOMAIN" "$USE_CASE" "$IMPLEMENTATION"; do
  require_text "$file" 'user-invocable: true'
  require_text "$file" 'An actionable stage gate is a point where the user must authorize a persisted state transition, choose whether work advances, or transfer control to another specification skill.'
  require_text "$file" "If the user selects continuation, immediately invoke the target through the host's skill mechanism with the resolved path and intent."
  require_text "$file" 'If invocation is unavailable or permission is denied, preserve the current state, report the limitation, and provide the exact manual command as a fallback.'
  reject_text "$file" 'disable-model-invocation: true'
done

require_text "$RECONCILIATION" 'This skill takes no arguments. Invoke it as `/spec-reconcile` from the repository root.'
require_text "$RECONCILIATION" 'active merge'
require_text "$RECONCILIATION" 'Completed Merge'
require_text "$RECONCILIATION" 'Audit Only'
require_text "$RECONCILIATION" "Git's ours/theirs index stages"
require_text "$RECONCILIATION" 'staged, unstaged, and untracked `docs/spec` work'
require_text "$RECONCILIATION" 'Never run `git add`, `git commit`, `git merge --continue`'
require_text "$RECONCILIATION" 'Never use filesystem birth or modification times'
require_text "$RECONCILIATION" 'Allocate the combined cohort consecutively from `max(sequence in the merge base) + 1`'
require_text "$RECONCILIATION" 'uncommitted additions after committed additions'
require_text "$RECONCILIATION" 'Stop and present the evidence'
require_text "$RECONCILIATION" 'Apply complete deterministic set'
require_text "$RECONCILIATION" 'restore every captured pre-image'
require_text "$RECONCILIATION" 'Never report a partial repair as success.'
require_text "$RECONCILIATION" 'Resolve through `/spec-domain`'
require_text "$RECONCILIATION" 'Resolve through `/spec-uc`'
require_text "$RECONCILIATION" 'Stop and leave the set unchanged'
require_text "$RECONCILIATION" 'every catalog `Use cases` field is a nested Markdown list with one link per bullet'
reject_text "$RECONCILIATION" 'Use cases` field: [NNN'
reject_text "$RECONCILIATION" 'argument-hint:'
require_text "$DOMAIN" 'continued from `/spec-reconcile`'
require_text "$USE_CASE" 'continued from `/spec-reconcile`'
require_text "$INSTALLER" 'SKILLS=(spec-domain spec-uc spec-impl spec-reconcile)'
require_text "$INSTALLER" 'Usage: bash install.sh'
require_text "$INSTALLER" 'replaces installed copies'
reject_text "$INSTALLER" 'TARGET='
reject_text "$INSTALLER" 'FORCE='
reject_text "$INSTALLER" '--force'
reject_text "$INSTALLER" 'codex'
reject_text "$INSTALLER" 'CODEX'
reject_text "$README" 'Codex'
reject_text "$README" '--force'

require_text "$USE_CASE" 'If the specification cannot be found, try the current open file before asking for its path.'
require_text "$IMPLEMENTATION" 'If the specification cannot be found, try the current open file before asking for its path.'
require_text "$USE_CASE" 'For every semantic change that needs a decision, call `AskUserQuestion` and wait for the answer before using Write/Edit on any specification file.'
require_text "$USE_CASE" 'For a semantic update, call `AskUserQuestion` and wait before using Write/Edit.'
require_text "$DOMAIN" 'For every semantic foundation change that needs a decision, call `AskUserQuestion` and wait for the answer before using Write/Edit on any specification file.'
require_text "$DOMAIN" 'Use Write/Edit only after every required `AskUserQuestion` answer and explicit approval'
require_text "$USE_CASE" 'Then update a `Draft` or `Review` under `docs/spec` with confirmed behavior'
require_text "$USE_CASE" 'Persist a new use case as `Draft` and an accepted-use-case revision as recoverable `Review`'
require_text "$USE_CASE" 'When discussion finishes, ask the user to **Mark Approved** or enter what to discuss next.'
require_text "$USE_CASE" 'entered text continues the discussion'
require_text "$USE_CASE" 'A normal `Approved` use-case artifact contains exactly one Status line and exactly one Goal, Actors, Preconditions, Trigger, Behavior Diagrams, Main Flow, and Postconditions section.'
require_text "$USE_CASE" 'contain one `### Overview` subsection with exactly one fenced `mermaid` block'
require_text "$USE_CASE" 'may contain up to three named process subsections'
require_text "$USE_CASE" 'Put an always-valid rule involving multiple properties, states, or connected concepts under the owning concept'"'"'s `#### Invariants`'
require_text "$USE_CASE" 'Use-case flows and postconditions do not duplicate Entity Model property constraints or concept-local invariants.'
require_text "$USE_CASE" 'Every use case must be linked under at least one existing owning requirement in the domain catalog.'
require_text "$USE_CASE" 'When saving a new `Draft`, add its link under every confirmed owning requirement in the same write'
require_text "$IMPLEMENTATION" 'For every normal use case, require exactly one Status line and exactly one Goal, Actors, Preconditions, Trigger, Behavior Diagrams, Main Flow, and Postconditions section.'
require_text "$IMPLEMENTATION" 'Required Behavior Diagrams overview, named process diagrams, Mermaid validity, and text consistency for a normal use case.'
require_text "$IMPLEMENTATION" 'Entity Model property constraint or concept invariant'
require_text "$IMPLEMENTATION" 'Confirm the selected use case is linked under at least one existing requirement in the domain catalog.'
reject_text "$USE_CASE" 'Entity Model policies or constraints'
reject_text "$IMPLEMENTATION" 'Entity Model policies and constraints'

reject_text "$USE_CASE" 'Optional sequenceDiagram'
reject_text "$USE_CASE" 'A Behavior Diagram, when present'
reject_text "$USE_CASE" 'when a diagram exists'
reject_text "$USE_CASE" '### Diagram Notes'
reject_text "$IMPLEMENTATION" 'When a Behavior Diagram exists'
reject_text "$IMPLEMENTATION" 'Behavior Diagram consistency when present'
reject_text "$IMPLEMENTATION" 'Diagram Notes'
reject_text "$IMPLEMENTATION" 'Require the Behavior Diagram between Trigger and Main Flow with exactly one fenced `mermaid` block.'

require_text "$DOMAIN" '/spec-domain` is the sole application coordinator and owns combined review and application in the current workflow'
require_text "$DOMAIN" 'Call one final `AskUserQuestion` offering **Approve and apply complete set** or continued review.'
require_text "$DOMAIN" 'immediately capture the exact pre-application content or nonexistence of every coordinator-owned target'
require_text "$DOMAIN" 'invalidates the whole-set approval'
require_text "$DOMAIN" 'obtain whole-set approval again'
require_text "$DOMAIN" 'apply the complete approved foundation and use-case set in one uninterrupted application phase'
require_text "$DOMAIN" 'finish the exact approved set when doing so needs no new semantics'
require_text "$DOMAIN" 'Never report partial application as success.'
require_text "$DOMAIN" 'A revised `Approved` member remains `Approved`; a revised `Implemented` member becomes `Approved`'
require_text "$DOMAIN" 'A proposal that would conflict with the revised foundation blocks approval and application'
require_text "$USE_CASE" 'Foundation-led coordinated accepted members were neither reviewed nor written here; `/spec-domain` owns their combined review and application.'

require_text "$DOMAIN" 'The domain catalog uses the order shown above: definition, Entity Model link, Boundary, then Requirements.'
require_text "$DOMAIN" 'Boundary contains one broad `Owns` statement and one broad `Excludes` statement'
require_text "$DOMAIN" 'Each requirement is one coherent domain responsibility.'
require_text "$DOMAIN" '`Capabilities` is required.'
require_text "$DOMAIN" 'A use case may be linked by multiple requirements when it materially implements each one.'
require_text "$DOMAIN" 'omit the `Use cases` field from a requirement until at least one linked use-case file exists'
require_text "$DOMAIN" 'render every use-case link as a nested Markdown list with one link per bullet'
require_text "$DOMAIN" 'renders `Use cases` as a nested one-link-per-bullet Markdown list'
require_text "$USE_CASE" 'same write as a nested Markdown list item'
require_text "$USE_CASE" 'every catalog `Use cases` field is a nested Markdown list with one link per bullet'
reject_text "$DOMAIN" '| Functional | [Short name] |'
reject_text "$DOMAIN" '| Sequence | Use Case | Outcome |'
require_text "$README" 'A domain catalog starts with its definition and Entity Model link, followed by:'

require_text "$DOMAIN" 'Use the section order shown above: external concepts first, then the Entity Relationship Diagram, owned concepts, and optional shared value types.'
require_text "$DOMAIN" 'The Entity Relationship Diagram is the sole representation of relationships and relationship cardinalities.'
require_text "$DOMAIN" 'Write every relationship label as an active, present-tense source-to-target verb.'
require_text "$DOMAIN" 'Prefer the standard names `owns`, `contains`, `uses`, `references`, `maps_to`, `compares_to`, `results_in`, and `affects`.'
require_text "$DOMAIN" 'For `Enumeration`, list the complete allowed values in that property'"'"'s `Constraints` cell and explain only value semantics that are not evident from the property meaning and value name; do not create a global enumeration section.'
require_text "$DOMAIN" 'Use `## Shared Value Types` only for a value reused by multiple properties or use cases, or for a value with important reusable representation or security semantics.'
require_text "$DOMAIN" 'Do not create global `Policies`, `Concept Constraints`, or `Enumerations` sections.'
reject_text "$DOMAIN" '#### Relationships'
reject_text "$DOMAIN" '### [Enumeration]'
reject_text "$DOMAIN" '### Policy Admission'
require_text "$README" 'Entity Models use a compact, fixed reading order:'

require_text "$IMPLEMENTATION" "This is the sole actionable gate that does not use \`AskUserQuestion\`"
require_text "$IMPLEMENTATION" 'do not duplicate implementation-plan approval through `AskUserQuestion`'
require_text "$IMPLEMENTATION" 'After plan approval, deterministic baseline work, implementation, testing, recovery, validation, and status calculation continue without another prompt'
reject_text "$IMPLEMENTATION" 'use `AskUserQuestion` to approve the implementation plan'

for file in "$DOMAIN" "$USE_CASE" "$README"; do
  reject_text "$file" 'The user invokes `/spec-uc` in the same session'
  reject_text "$file" 'apply coordinated change'
  reject_text "$file" 'write no member and hand the set to `/spec-domain`'
  reject_text "$file" 'write no finalized member and hand the approved set to `/spec-domain`'
  reject_text "$file" 'approved summary was handed to `/spec-domain` for coordinated application'
done

for file in "$DOMAIN" "$USE_CASE" "$IMPLEMENTATION"; do
  reject_text "$file" 'direct the user to `/spec'
  reject_text "$file" 'return to `/spec'
  reject_text "$file" 'Return to `/spec'
done

require_text "$USE_CASE" '## Rename a Use Case'
require_text "$USE_CASE" 'Preserve the numeric sequence and current status.'
require_text "$USE_CASE" '## Approved Removal Artifact'
require_text "$IMPLEMENTATION" 'When the file contains `## Approved Removal`'
require_text "$IMPLEMENTATION" 'preserve the artifact and links so interrupted work remains recoverable'

reject_text "$USE_CASE" 'temporary contract for `/spec-impl` in the current session'
reject_text "$USE_CASE" 'Ordinary new or revised behavior remains an unpersisted concise review summary until approval'
reject_text "$USE_CASE" 'never write semantic changes before the required answers and approval'
reject_text "$IMPLEMENTATION" 'removal decision from `/spec-uc` in the current conversation'

require_text "$README" 'one final whole-set `AskUserQuestion` approval'
require_text "$README" "The skills remain directly user-invocable and are also visible to Claude so an explicit \`AskUserQuestion\` selection can continue into another specification skill."
reject_text "$README" 'disable-model-invocation: true'

printf '%s\n' 'Claude skill contract checks passed.'
