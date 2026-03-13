#!/usr/bin/env zsh

# Required for shunit2 to run correctly
CWD="${${(%):-%x}:A:h}"
setopt shwordsplit
SHUNIT_PARENT=$0

# Use system Spaceship or fallback to Spaceship Docker on CI
typeset -g SPACESHIP_ROOT="${SPACESHIP_ROOT:=/spaceship}"

# ------------------------------------------------------------------------------
# SHUNIT2 HOOKS
# ------------------------------------------------------------------------------

setUp() {
  # Enter the test directory
  cd $SHUNIT_TMPDIR
}

oneTimeSetUp() {
  export TERM="xterm-256color"

  source "$SPACESHIP_ROOT/spaceship.zsh"
  source "$(dirname $CWD)/spaceship-jj.plugin.zsh"

  SPACESHIP_PROMPT_ASYNC=false
  SPACESHIP_PROMPT_FIRST_PREFIX_SHOW=true
  SPACESHIP_PROMPT_ADD_NEWLINE=false
  SPACESHIP_PROMPT_ORDER=(jj)

  echo "Spaceship version: $(spaceship --version)"
}

oneTimeTearDown() {
  unset SPACESHIP_PROMPT_ASYNC
  unset SPACESHIP_PROMPT_FIRST_PREFIX_SHOW
  unset SPACESHIP_PROMPT_ADD_NEWLINE
  unset SPACESHIP_PROMPT_ORDER
}

# ------------------------------------------------------------------------------
# TEST CASES
# ------------------------------------------------------------------------------

test_jj_no_jj_repo() {
  local expected=""
  local actual="$(spaceship::testkit::render_prompt)"

  assertEquals "render in dir with no jj repo" "$expected" "$actual"
}

test_jj_dir_without_desc() {
  # Prepare the environment
  jj git init >/dev/null 2>&1

  local actual="$(spaceship::testkit::render_prompt)"
  local expanded="$(print -P -- "$actual")"
  local raw_section_text="$(printf '%s' "$expanded" | sed -E $'s/\x1b\\[[0-9;]*[[:alpha:]]//g')"

  local pattern='^on 🥋 [a-z0-9]{8} $'

  [[ "$raw_section_text" =~ "$pattern" ]] \
    || fail "render in jj dir missing expected content: <$raw_section_text>"

  [[ "$expanded" =~ $'\e\\[[0-9;]*33m🥋 [a-z0-9]{8}' ]] \
    || fail "jj change id should be yellow: <$expanded>"

  # Check that the prompt begins with bold 'on '
  [[ "$expanded" =~ $'^\e\\[[0-9;]*1m(on )' ]] \
    || fail "prompt prefix should be bold: <$expanded>"
}

test_jj_dir_with_desc() {
  # Prepare the environment
  jj desc -m "Init" > /dev/null 2>&1

  local actual="$(spaceship::testkit::render_prompt)"
  local expanded="$(print -P -- "$actual")"
  local raw_section_text="$(printf '%s' "$expanded" | sed -E $'s/\x1b\\[[0-9;]*[[:alpha:]]//g')"

  local pattern='^on 🥋 [a-z0-9]{8} \(Init\) $'

  [[ "$raw_section_text" =~ "$pattern" ]] \
    || fail "render in jj dir missing expected content: <$raw_section_text>"
}

test_jj_dir_added_file_status() {
  # Prepare the environment
  touch new_file
  jj file track new_file > /dev/null 2>&1

  local actual="$(spaceship::testkit::render_prompt)"
  local expanded="$(print -P -- "$actual")"
  local raw_section_text="$(printf '%s' "$expanded" | sed -E $'s/\x1b\\[[0-9;]*[[:alpha:]]//g')"

  local pattern='^on 🥋 [a-z0-9]{8} \(Init\) \[\+\] $'

  [[ "$raw_section_text" =~ $pattern ]] \
    || fail "render in jj dir with pattern: <$pattern>, but was <$raw_section_text>"
}

# ------------------------------------------------------------------------------
# SHUNIT2
# Run tests with shunit2
# ------------------------------------------------------------------------------

source "$SPACESHIP_ROOT/tests/shunit2/shunit2"
