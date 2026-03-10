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
  jj git init

  local pattern='%{%B%}via %{%b%}%{%B%F{white}%}%{%B%F{yellow}%}🥋 [a-z0-9]{8}%{%b%f%}%{%b%f%}%{%B%} %{%b%}'
  local actual="$(spaceship::testkit::render_prompt)"

  [[ "$actual" =~ $pattern ]] \
    || fail "render in jj dir with pattern: <$pattern>, but was <$actual>"
}

test_jj_dir_with_desc() {
  # Prepare the environment
  jj desc -m "Init" 2>&1 > /dev/null

  local pattern='%{%B%}via %{%b%}%{%B%F{white}%}%{%B%F{yellow}%}🥋 [a-z0-9]{8} \(Init\)%{%b%f%}%{%b%f%}%{%B%} %{%b%}'
  local actual="$(spaceship::testkit::render_prompt)"

  [[ "$actual" =~ $pattern ]] \
    || fail "render in jj dir with pattern: <$pattern>, but was <$actual>"
}

test_jj_dir_added_file_status() {
  # Prepare the environment
  touch new_file
  jj file track new_file

  local pattern='%{%B%}via %{%b%}%{%B%F{white}%}%{%B%F{yellow}%}🥋 [a-z0-9]{8} \(Init\)%{%b%f%}%{%B%F{red}%} \[\+\]%{%b%f%}%{%b%f%}%{%B%} %{%b%}'
  local actual="$(spaceship::testkit::render_prompt)"

  [[ "$actual" =~ $pattern ]] \
    || fail "render in jj dir with pattern: <$pattern>, but was <$actual>"

}

# ------------------------------------------------------------------------------
# SHUNIT2
# Run tests with shunit2
# ------------------------------------------------------------------------------

source "$SPACESHIP_ROOT/tests/shunit2/shunit2"
