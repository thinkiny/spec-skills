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

for skill in spec-domain spec-uc spec-impl; do
  check_skill_name "$skill"
done

DOMAIN="$ROOT/spec-domain/SKILL.md"
USE_CASE="$ROOT/spec-uc/SKILL.md"
IMPLEMENTATION="$ROOT/spec-impl/SKILL.md"

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
require_text "$IMPLEMENTATION" 'For every normal use case, require exactly one Status line and exactly one Goal, Actors, Preconditions, Trigger, Behavior Diagrams, Main Flow, and Postconditions section.'
require_text "$IMPLEMENTATION" 'Required Behavior Diagrams overview, named process diagrams, Mermaid validity, and text consistency for a normal use case.'

reject_text "$USE_CASE" 'Optional sequenceDiagram'
reject_text "$USE_CASE" 'A Behavior Diagram, when present'
reject_text "$USE_CASE" 'when a diagram exists'
reject_text "$USE_CASE" '### Diagram Notes'
reject_text "$IMPLEMENTATION" 'When a Behavior Diagram exists'
reject_text "$IMPLEMENTATION" 'Behavior Diagram consistency when present'
reject_text "$IMPLEMENTATION" 'Diagram Notes'
reject_text "$IMPLEMENTATION" 'Require the Behavior Diagram between Trigger and Main Flow with exactly one fenced `mermaid` block.'

require_text "$DOMAIN" '/spec-domain` is the sole application coordinator'
require_text "$DOMAIN" 'apply the complete approved foundation and use-case set in one uninterrupted application phase'
require_text "$USE_CASE" 'write no member and hand the set to `/spec-domain` for application'
require_text "$USE_CASE" 'approved summary was handed to `/spec-domain` for coordinated application'

require_text "$USE_CASE" '## Rename a Use Case'
require_text "$USE_CASE" 'Preserve the numeric sequence and current status.'
require_text "$USE_CASE" '## Approved Removal Artifact'
require_text "$IMPLEMENTATION" 'When the file contains `## Approved Removal`'
require_text "$IMPLEMENTATION" 'preserve the artifact and catalog row so interrupted work remains recoverable'

reject_text "$USE_CASE" 'temporary contract for `/spec-impl` in the current session'
reject_text "$USE_CASE" 'Ordinary new or revised behavior remains an unpersisted concise review summary until approval'
reject_text "$USE_CASE" 'never write semantic changes before the required answers and approval'
reject_text "$IMPLEMENTATION" 'removal decision from `/spec-uc` in the current conversation'

printf '%s\n' 'Claude skill contract checks passed.'
