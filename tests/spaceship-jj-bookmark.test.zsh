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

test_spaceship_jj_single_bookmark_at_working_copy() {
  # Prepare the environment
  jj git init > /dev/null 2>&1
  jj bookmark c base > /dev/null 2>&1
  jj commit -m "Initial commit" > /dev/null 2>&1
  jj bookmark c a > /dev/null 2>&1

  local actual="$(spaceship::testkit::render_prompt)"
  local expanded="$(print -P -- "$actual")"
  local raw_section_text="$(printf '%s' "$expanded" | sed -E $'s/\x1b\\[[0-9;]*[[:alpha:]]//g')"

  local pattern='^on 🥋 [a-z0-9]{8} \(a @\) $'

  [[ "$raw_section_text" =~ "$pattern" ]] \
    || fail "render in jj dir was: <$raw_section_text>, expected pattern match: <$pattern>"

  [[ "$expanded" =~ $'\e\\[[0-9;]*33m[k-z0-9]{8}' ]] \
    || fail "jj bookmark should be blue: <$expanded>"

  # Check that the prompt begins with bold 'on '
  [[ "$expanded" =~ $'^\e\\[[0-9;]*1m(on )' ]] \
    || fail "prompt prefix should be bold: <$expanded>"
}

test_spaceship_jj_single_bookmark_at_working_copy_minus_one() {
  # Prepare the environment
  touch file
  jj commit -m "Second commit" > /dev/null 2>&1

  local actual="$(spaceship::testkit::render_prompt)"
  local expanded="$(print -P -- "$actual")"
  local raw_section_text="$(printf '%s' "$expanded" | sed -E $'s/\x1b\\[[0-9;]*[[:alpha:]]//g')"

  local pattern='^on 🥋 [a-z0-9]{8} \(a @-\) $'

  [[ "$raw_section_text" =~ "$pattern" ]] \
    || fail "render in jj dir was: <$raw_section_text>, expected pattern match: <$pattern>"

  [[ "$expanded" =~ $'\e\\[[0-9;]*33m[k-z0-9]{8}' ]] \
    || fail "jj bookmark should be blue: <$expanded>"

  # Check that the prompt begins with bold 'on '
  [[ "$expanded" =~ $'^\e\\[[0-9;]*1m(on )' ]] \
    || fail "prompt prefix should be bold: <$expanded>"
}

test_spaceship_jj_single_bookmark_at_working_copy_minus_two() {
  # Prepare the environment
  touch new_file
  jj commit -m "Third commit" > /dev/null 2>&1

  local actual="$(spaceship::testkit::render_prompt)"
  local expanded="$(print -P -- "$actual")"
  local raw_section_text="$(printf '%s' "$expanded" | sed -E $'s/\x1b\\[[0-9;]*[[:alpha:]]//g')"

  local pattern='^on 🥋 [a-z0-9]{8} \(a @--\) $'

  [[ "$raw_section_text" =~ "$pattern" ]] \
    || fail "render in jj dir was: <$raw_section_text>, expected pattern match: <$pattern>"

  [[ "$expanded" =~ $'\e\\[[0-9;]*33m[k-z0-9]{8}' ]] \
    || fail "jj bookmark should be blue: <$expanded>"

  # Check that the prompt begins with bold 'on '
  [[ "$expanded" =~ $'^\e\\[[0-9;]*1m(on )' ]] \
    || fail "prompt prefix should be bold: <$expanded>"
}

test_spaceship_jj_single_bookmark_at_working_copy_minus_three() {
  # Prepare the environment
  touch another_new_file
  jj commit -m "Fourth commit" > /dev/null 2>&1

  local actual="$(spaceship::testkit::render_prompt)"
  local expanded="$(print -P -- "$actual")"
  local raw_section_text="$(printf '%s' "$expanded" | sed -E $'s/\x1b\\[[0-9;]*[[:alpha:]]//g')"

  local pattern='^on 🥋 [a-z0-9]{8} \(a @-3\) $'

  [[ "$raw_section_text" =~ "$pattern" ]] \
    || fail "render in jj dir was: <$raw_section_text>, expected pattern match: <$pattern>"

  [[ "$expanded" =~ $'\e\\[[0-9;]*33m[k-z0-9]{8}' ]] \
    || fail "jj bookmark should be blue: <$expanded>"

  # Check that the prompt begins with bold 'on '
  [[ "$expanded" =~ $'^\e\\[[0-9;]*1m(on )' ]] \
    || fail "prompt prefix should be bold: <$expanded>"
}

test_spaceship_jj_multiple_bookmarks() {
  # Prepare the environment
  jj new base > /dev/null 2>&1
  jj bookmark c b > /dev/null 2>&1

  jj new a b > /dev/null 2>&1

  local actual="$(spaceship::testkit::render_prompt)"
  local expanded="$(print -P -- "$actual")"
  local raw_section_text="$(printf '%s' "$expanded" | sed -E $'s/\x1b\\[[0-9;]*[[:alpha:]]//g')"

  local pattern='^on 🥋 [a-z0-9]{8} \(<2 bookmarks> @-\) $'

  [[ "$raw_section_text" =~ "$pattern" ]] \
    || fail "render in jj dir was: <$raw_section_text>, expected pattern match: <$pattern>"

  [[ "$expanded" =~ $'\e\\[[0-9;]*33m[k-z0-9]{8}' ]] \
    || fail "jj bookmark should be blue: <$expanded>"

  # Check that the prompt begins with bold 'on '
  [[ "$expanded" =~ $'^\e\\[[0-9;]*1m(on )' ]] \
    || fail "prompt prefix should be bold: <$expanded>"
}

# ------------------------------------------------------------------------------
# SHUNIT2
# Run tests with shunit2
# ------------------------------------------------------------------------------

source "$SPACESHIP_ROOT/tests/shunit2/shunit2"
