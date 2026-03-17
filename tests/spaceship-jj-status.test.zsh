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

test_spaceship_jj_added_file_status() {
  # Prepare the environment
  jj git init > /dev/null 2>&1
  touch new_file
  jj file track new_file > /dev/null 2>&1

  export SPACESHIP_JJ_DESC_SHOW=false

  local actual="$(spaceship::testkit::render_prompt)"
  local expanded="$(print -P -- "$actual")"
  local raw_section_text="$(printf '%s' "$expanded" | sed -E $'s/\x1b\\[[0-9;]*[[:alpha:]]//g')"

  local pattern='^on 🥋 \[\+\] $'

  [[ "$raw_section_text" =~ "$pattern" ]] \
    || fail "render in jj dir was: <$raw_section_text>, expected pattern match: <$pattern>"
}

test_spaceship_jj_modified_file_status() {
  # Prepare the environment
  jj new > /dev/null 2>&1
  echo "test" > new_file

  export SPACESHIP_JJ_DESC_SHOW=false

  local actual="$(spaceship::testkit::render_prompt)"
  local expanded="$(print -P -- "$actual")"
  local raw_section_text="$(printf '%s' "$expanded" | sed -E $'s/\x1b\\[[0-9;]*[[:alpha:]]//g')"

  local pattern='^on 🥋 \[\!\] $'

  [[ "$raw_section_text" =~ "$pattern" ]] \
    || fail "render in jj dir was: <$raw_section_text>, expected pattern match: <$pattern>"

}

test_spaceship_jj_renamed_file_status() {
  # Prepare the environment
  jj new > /dev/null 2>&1
  mv new_file other_file

  export SPACESHIP_JJ_DESC_SHOW=false

  local actual="$(spaceship::testkit::render_prompt)"
  local expanded="$(print -P -- "$actual")"
  local raw_section_text="$(printf '%s' "$expanded" | sed -E $'s/\x1b\\[[0-9;]*[[:alpha:]]//g')"

  local pattern='^on 🥋 \[\»\] $'

  [[ "$raw_section_text" =~ "$pattern" ]] \
    || fail "render in jj dir was: <$raw_section_text>, expected pattern match: <$pattern>"
}

test_spaceship_jj_deleted_file_status() {
  # Prepare the environment
  jj new > /dev/null 2>&1
  rm other_file

  export SPACESHIP_JJ_DESC_SHOW=false

  local actual="$(spaceship::testkit::render_prompt)"
  local expanded="$(print -P -- "$actual")"
  local raw_section_text="$(printf '%s' "$expanded" | sed -E $'s/\x1b\\[[0-9;]*[[:alpha:]]//g')"

  local pattern='^on 🥋 \[\✘\] $'

  [[ "$raw_section_text" =~ "$pattern" ]] \
    || fail "render in jj dir was: <$raw_section_text>, expected pattern match: <$pattern>"
}

test_spaceship_jj_conflicted_file_status() {
  touch file
  jj file track file > /dev/null 2>&1
  jj commit -m "base" > /dev/null 2>&1
  jj bookmark create base -r @- > /dev/null 2>&1

  echo "content" > file
  jj commit -m "a" > /dev/null 2>&1
  jj bookmark create a -r @- > /dev/null 2>&1

  jj new base > /dev/null 2>&1
  echo "update" > file
  jj commit -m "b" > /dev/null 2>&1
  jj bookmark create b -r @- > /dev/null 2>&1

  jj new a b > /dev/null 2>&1

  export SPACESHIP_JJ_DESC_SHOW=false
  export SPACESHIP_JJ_BOOKMARK_SHOW=false

  local actual="$(spaceship::testkit::render_prompt)"
  local expanded="$(print -P -- "$actual")"
  local raw_section_text="$(printf '%s' "$expanded" | sed -E $'s/\x1b\\[[0-9;]*[[:alpha:]]//g')"

  local pattern='^on 🥋 \[\=\] $'

  [[ "$raw_section_text" =~ "$pattern" ]] \
    || fail "render in jj dir was: <$raw_section_text>, expected pattern match: <$pattern>"
}

# ------------------------------------------------------------------------------
# SHUNIT2
# Run tests with shunit2
# ------------------------------------------------------------------------------

source "$SPACESHIP_ROOT/tests/shunit2/shunit2"
