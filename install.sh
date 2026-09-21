#!/usr/bin/env bash

set -euo pipefail

SKILLS=(spec-domain spec-uc spec-impl spec-reconcile)
STAGES=()
NEW_STAGE=""

usage() {
  cat <<'EOF'
Usage: bash install.sh

Installs the skills globally for Claude Code and replaces installed copies:
  $HOME/.claude/skills

Options:
  -h, --help
EOF
}

fail() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

cleanup() {
  local stage
  for stage in "${STAGES[@]}"; do
    if [[ -n "$stage" && -d "$stage" ]]; then
      rm -rf "$stage"
    fi
  done
}
trap cleanup EXIT

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      fail "unknown argument: $1"
      ;;
  esac
  shift
done

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude/skills"

validate_sources() {
  local skill source declared_name
  for skill in "${SKILLS[@]}"; do
    source="$SCRIPT_DIR/$skill/SKILL.md"
    [[ -f "$source" ]] || fail "missing source skill: $source"
    declared_name="$(awk '
      NR == 1 && $0 != "---" { exit 2 }
      /^name: / { sub(/^name: /, ""); print; exit }
    ' "$source")"
    [[ "$declared_name" == "$skill" ]] || fail "$source declares name '$declared_name', expected '$skill'"
  done
}

new_stage() {
  local destination stage
  destination="$1"
  mkdir -p "$destination"
  stage="$(mktemp -d "$destination/.spec-skills-install.XXXXXX")"
  STAGES+=("$stage")
  NEW_STAGE="$stage"
}

prepare_skills() {
  local stage skill
  stage="$1"
  for skill in "${SKILLS[@]}"; do
    mkdir -p "$stage/$skill"
    cp "$SCRIPT_DIR/$skill/SKILL.md" "$stage/$skill/SKILL.md"
  done
}

install_stage() {
  local stage destination skill source installed backup
  stage="$1"
  destination="$2"

  for skill in "${SKILLS[@]}"; do
    source="$stage/$skill"
    installed="$destination/$skill"

    if [[ -e "$installed" || -L "$installed" ]]; then
      if diff -qr "$source" "$installed" >/dev/null 2>&1; then
        printf 'Claude Code: %s already installed\n' "$skill"
        continue
      fi

      backup="$destination/.${skill}.spec-skills-backup.$$"
      rm -rf "$backup"
      mv "$installed" "$backup"
      if mv "$source" "$installed"; then
        rm -rf "$backup"
      else
        mv "$backup" "$installed"
        fail "failed to replace $installed; previous installation restored"
      fi
    else
      mv "$source" "$installed"
    fi

    printf 'Claude Code: installed %s to %s\n' "$skill" "$installed"
  done
}

validate_sources
new_stage "$CLAUDE_DIR"
prepare_skills "$NEW_STAGE"
install_stage "$NEW_STAGE" "$CLAUDE_DIR"

printf '%s\n' 'Claude Code commands: /spec-domain, /spec-uc, /spec-impl, /spec-reconcile'
printf '%s\n' 'Start a new Claude Code session to load newly installed user skills.'
