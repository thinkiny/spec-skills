#!/usr/bin/env bash

set -euo pipefail

SKILLS=(spec-domain spec-uc spec-impl)
TARGET=""
FORCE=0
STAGES=()
NEW_STAGE=""

usage() {
  cat <<'EOF'
Usage: bash install.sh <claude|codex|all> [--force]

Installs the skills globally for the selected host:
  claude  $HOME/.claude/skills
  codex   $HOME/.agents/skills
  all     both destinations

Options:
  --force  Replace installed skills when their contents differ.
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
    claude|codex|all)
      [[ -z "$TARGET" ]] || fail "specify only one installation target"
      TARGET="$1"
      ;;
    --force)
      FORCE=1
      ;;
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

[[ -n "$TARGET" ]] || {
  usage >&2
  fail "installation target is required"
}

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude/skills"
CODEX_DIR="$HOME/.agents/skills"

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

prepare_claude() {
  local stage skill
  stage="$1"
  for skill in "${SKILLS[@]}"; do
    mkdir -p "$stage/$skill"
    cp "$SCRIPT_DIR/$skill/SKILL.md" "$stage/$skill/SKILL.md"
  done
}

prepare_codex() {
  local stage skill source destination
  stage="$1"
  for skill in "${SKILLS[@]}"; do
    source="$SCRIPT_DIR/$skill/SKILL.md"
    destination="$stage/$skill/SKILL.md"
    mkdir -p "$stage/$skill"
    awk '
      BEGIN { frontmatter = 0 }
      NR == 1 && $0 == "---" { frontmatter = 1; print; next }
      frontmatter && $0 == "---" { frontmatter = 0; print; next }
      frontmatter && /^(argument-hint|disable-model-invocation|user-invocable):/ { next }
      {
        gsub("Use when explicitly invoked", "Use when")
        gsub("`/spec-domain`", "`$spec-domain`")
        gsub("`/spec-uc`", "`$spec-uc`")
        gsub("`/spec-impl`", "`$spec-impl`")
        print
      }
    ' "$source" > "$destination"
  done
}

preflight() {
  local stage destination host skill installed
  stage="$1"
  destination="$2"
  host="$3"

  for skill in "${SKILLS[@]}"; do
    installed="$destination/$skill"
    if [[ -e "$installed" || -L "$installed" ]]; then
      if diff -qr "$stage/$skill" "$installed" >/dev/null 2>&1; then
        continue
      fi
      if [[ "$FORCE" -ne 1 ]]; then
        fail "$host skill '$skill' already exists with different contents at $installed; rerun with --force to replace it"
      fi
    fi
  done
}

install_stage() {
  local stage destination host skill source installed backup
  stage="$1"
  destination="$2"
  host="$3"

  for skill in "${SKILLS[@]}"; do
    source="$stage/$skill"
    installed="$destination/$skill"

    if [[ -e "$installed" || -L "$installed" ]]; then
      if diff -qr "$source" "$installed" >/dev/null 2>&1; then
        printf '%s: %s already installed\n' "$host" "$skill"
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

    printf '%s: installed %s to %s\n' "$host" "$skill" "$installed"
  done
}

validate_sources

CLAUDE_STAGE=""
CODEX_STAGE=""

if [[ "$TARGET" == "claude" || "$TARGET" == "all" ]]; then
  new_stage "$CLAUDE_DIR"
  CLAUDE_STAGE="$NEW_STAGE"
  prepare_claude "$CLAUDE_STAGE"
fi

if [[ "$TARGET" == "codex" || "$TARGET" == "all" ]]; then
  new_stage "$CODEX_DIR"
  CODEX_STAGE="$NEW_STAGE"
  prepare_codex "$CODEX_STAGE"
fi

# Check every requested destination before changing any installed skill.
if [[ -n "$CLAUDE_STAGE" ]]; then
  preflight "$CLAUDE_STAGE" "$CLAUDE_DIR" "Claude Code"
fi
if [[ -n "$CODEX_STAGE" ]]; then
  preflight "$CODEX_STAGE" "$CODEX_DIR" "Codex"
fi

if [[ -n "$CLAUDE_STAGE" ]]; then
  install_stage "$CLAUDE_STAGE" "$CLAUDE_DIR" "Claude Code"
fi
if [[ -n "$CODEX_STAGE" ]]; then
  install_stage "$CODEX_STAGE" "$CODEX_DIR" "Codex"
fi

if [[ "$TARGET" == "claude" || "$TARGET" == "all" ]]; then
  printf '%s\n' 'Claude Code commands: /spec-domain, /spec-uc, /spec-impl'
  printf '%s\n' 'Start a new Claude Code session to load newly installed user skills.'
fi
if [[ "$TARGET" == "codex" || "$TARGET" == "all" ]]; then
  printf '%s\n' 'Codex skills: $spec-domain, $spec-uc, $spec-impl'
  printf '%s\n' 'Codex normally detects new skills automatically; restart it if they do not appear.'
fi
