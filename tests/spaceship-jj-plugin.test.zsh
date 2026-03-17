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

test_spaceship_jj_no_jj_root() {
  local actual="$(spaceship::testkit::render_prompt)"
  local expanded="$(print -P -- "$actual")"
  local raw_section_text="$(printf '%s' "$expanded" | sed -E $'s/\x1b\\[[0-9;]*[[:alpha:]]//g')"

  local pattern='^$'

  [[ "$raw_section_text" =~ "$pattern" ]] \
    || fail "render in jj dir missing expected content: <$raw_section_text>"
}

# ------------------------------------------------------------------------------
# SHUNIT2
# Run tests with shunit2
# ------------------------------------------------------------------------------

source "$SPACESHIP_ROOT/tests/shunit2/shunit2"
