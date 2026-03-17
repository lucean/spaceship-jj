#!/usr/bin/env zsh
set -euo pipefail

export SPACESHIP_ROOT="${1:-$SPACESHIP_ROOT}"

export CWD="${${(%):-%x}:A:h}"

run_test_file() {
  local label="$1"
  local script="$2"
  local output status

  print
  print "== $label =="

  output="$("$script" 2>&1)"
  exit_code=$?

  printf '%s\n' "$output" \
    | sed '/^Spaceship version:/d' \
    | sed 's/^/  /'

  return $exit_code
}

run_test_file "spaceship-jj Description" $CWD/spaceship-jj-desc.test.zsh

run_test_file "spaceship-jj Commit" $CWD/spaceship-jj-commit.test.zsh

run_test_file "spaceship-jj Status" $CWD/spaceship-jj-status.test.zsh
