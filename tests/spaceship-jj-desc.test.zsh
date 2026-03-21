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

  source "$SPACESHIP_ROOT/spaceship.zsh" > /dev/null 2>&1
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

test_spaceship_jj_no_description() {
  # Prepare the environment
  jj git init >/dev/null 2>&1

  local actual="$(spaceship::testkit::render_prompt)"
  local expanded="$(print -P -- "$actual")"
  local raw_section_text="$(printf '%s' "$expanded" | sed -E $'s/\x1b\\[[0-9;]*[[:alpha:]]//g')"

  local pattern='^on 🥋 [k-z0-9]{8} $'

  [[ "$raw_section_text" =~ "$pattern" ]] \
    || fail "render in jj dir was: <$raw_section_text>, expected pattern match: <$pattern>"

  [[ "$expanded" =~ $'\e\\[[0-9;]*33m[k-z0-9]{8}' ]] \
    || fail "jj change id should be yellow: <$expanded>"

  # Check that the prompt begins with bold 'on '
  [[ "$expanded" =~ $'^\e\\[[0-9;]*1m(on )' ]] \
    || fail "prompt prefix should be bold: <$expanded>"
}

test_spaceship_jj_description() {
  # Prepare the environment
  jj desc -m "Init" > /dev/null 2>&1

  local actual="$(spaceship::testkit::render_prompt)"
  local expanded="$(print -P -- "$actual")"
  local raw_section_text="$(printf '%s' "$expanded" | sed -E $'s/\x1b\\[[0-9;]*[[:alpha:]]//g')"

  local pattern='^on 🥋 [k-z0-9]{8} \(Init\) $'

  [[ "$raw_section_text" =~ "$pattern" ]] \
    || fail "render in jj dir was: <$raw_section_text>, expected pattern match: <$pattern>"
}

test_spaceship_jj_empty_description() {
  # Prepare the environment
  export SPACESHIP_JJ_DESC_EMPTY_SHOW=true

  local actual="$(spaceship::testkit::render_prompt)"
  local expanded="$(print -P -- "$actual")"
  local raw_section_text="$(printf '%s' "$expanded" | sed -E $'s/\x1b\\[[0-9;]*[[:alpha:]]//g')"

  local pattern='^on 🥋 [k-z0-9]{8} \(Init\) \(empty\) $'

  [[ "$raw_section_text" =~ "$pattern" ]] \
    || fail "render in jj dir was: <$raw_section_text>, expected pattern match: <$pattern>"

  # The '(empty)' message disappears if you add a file to the working copy
  touch new_file

  local actual="$(spaceship::testkit::render_prompt)"
  local expanded="$(print -P -- "$actual")"
  local raw_section_text="$(printf '%s' "$expanded" | sed -E $'s/\x1b\\[[0-9;]*[[:alpha:]]//g')"

  local pattern='^on 🥋 [k-z0-9]{8} \(Init\) \[\+\] $'

  [[ "$raw_section_text" =~ "$pattern" ]] \
    || fail "render in jj dir was: <$raw_section_text>, expected pattern match: <$pattern>"
}

test_spaceship_jj_truncated_description() {
  # Prepare the environment
  export SPACESHIP_JJ_DESC_EMPTY_SHOW=false
  export SPACESHIP_JJ_DESC_MAX_LENGTH=10

  rm new_file

  jj desc -m "A much longer init message" > /dev/null 2>&1

  local actual="$(spaceship::testkit::render_prompt)"
  local expanded="$(print -P -- "$actual")"
  local raw_section_text="$(printf '%s' "$expanded" | sed -E $'s/\x1b\\[[0-9;]*[[:alpha:]]//g')"

  local pattern='^on 🥋 [k-z0-9]{8} \(A much ...\) $'

  [[ "$raw_section_text" =~ $pattern ]] \
    || fail "render in jj dir with pattern: <$pattern>, but was <$raw_section_text>"
}

# ------------------------------------------------------------------------------
# SHUNIT2
# Run tests with shunit2
# ------------------------------------------------------------------------------

source "$SPACESHIP_ROOT/tests/shunit2/shunit2"
