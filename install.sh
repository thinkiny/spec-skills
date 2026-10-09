#!/usr/bin/env bash

set -euo pipefail

SKILLS=(spec-domain spec-uc spec-impl spec-reconcile)
COMPONENTS=(spec-domain spec-uc spec-impl spec-reconcile spec-validator)
STAGES=()
NEW_STAGE=""
BACKUP_ROOT=""
CHANGED_COMPONENTS=()
INSTALLED_COMPONENTS=()
TRANSACTION_ACTIVE=0

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

rollback_install() {
  local index component installed backup failed=0

  for ((index=${#INSTALLED_COMPONENTS[@]} - 1; index >= 0; index--)); do
    component="${INSTALLED_COMPONENTS[index]}"
    installed="$CLAUDE_DIR/$component"
    if [[ -e "$installed" || -L "$installed" ]]; then
      rm -rf -- "$installed" || failed=1
    fi
  done

  for ((index=${#CHANGED_COMPONENTS[@]} - 1; index >= 0; index--)); do
    component="${CHANGED_COMPONENTS[index]}"
    backup="$BACKUP_ROOT/$component"
    installed="$CLAUDE_DIR/$component"
    if [[ -e "$backup" || -L "$backup" ]]; then
      mv "$backup" "$installed" || failed=1
    fi
  done

  if [[ -n "$BACKUP_ROOT" ]]; then
    rmdir "$BACKUP_ROOT" 2>/dev/null || true
  fi
  if [[ "$failed" -eq 0 ]]; then
    printf '%s\n' 'Claude Code: installation failed; previous components restored' >&2
  else
    printf 'Error: installation failed and recovery is incomplete; preserved backups under %s\n' "$BACKUP_ROOT" >&2
  fi
}

on_exit() {
  local status=$?
  trap - EXIT
  set +e
  if [[ "$TRANSACTION_ACTIVE" -eq 1 ]]; then
    rollback_install
  fi
  cleanup
  exit "$status"
}
trap on_exit EXIT

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
  [[ -f "$SCRIPT_DIR/scripts/validate_spec.py" ]] || fail "missing shared validator: $SCRIPT_DIR/scripts/validate_spec.py"
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
  mkdir -p "$stage/spec-validator"
  cp "$SCRIPT_DIR/scripts/validate_spec.py" "$stage/spec-validator/validate_spec.py"
}

install_stage() {
  local stage destination component source installed
  stage="$1"
  destination="$2"

  for component in "${COMPONENTS[@]}"; do
    source="$stage/$component"
    installed="$destination/$component"

    if [[ -e "$installed" || -L "$installed" ]]; then
      if diff -qr "$source" "$installed" >/dev/null 2>&1; then
        printf 'Claude Code: %s already installed\n' "$component"
        continue
      fi
    fi

    CHANGED_COMPONENTS+=("$component")
  done

  if [[ "${#CHANGED_COMPONENTS[@]}" -eq 0 ]]; then
    return
  fi

  BACKUP_ROOT="$(mktemp -d "$destination/.spec-skills-backup.XXXXXX")"
  TRANSACTION_ACTIVE=1

  for component in "${CHANGED_COMPONENTS[@]}"; do
    installed="$destination/$component"
    if [[ -e "$installed" || -L "$installed" ]]; then
      mv "$installed" "$BACKUP_ROOT/$component" || fail "failed to back up $installed"
    fi
  done

  for component in "${CHANGED_COMPONENTS[@]}"; do
    source="$stage/$component"
    installed="$destination/$component"
    mv "$source" "$installed" || fail "failed to install $installed"
    INSTALLED_COMPONENTS+=("$component")
  done

  TRANSACTION_ACTIVE=0
  rm -rf -- "$BACKUP_ROOT"
  BACKUP_ROOT=""

  for component in "${CHANGED_COMPONENTS[@]}"; do
    installed="$destination/$component"
    printf 'Claude Code: installed %s to %s\n' "$component" "$installed"
  done
}

validate_sources
new_stage "$CLAUDE_DIR"
prepare_skills "$NEW_STAGE"
install_stage "$NEW_STAGE" "$CLAUDE_DIR"

printf '%s\n' 'Claude Code commands: /spec-domain, /spec-uc, /spec-impl, /spec-reconcile'
printf '%s\n' 'Start a new Claude Code session to load newly installed user skills.'
