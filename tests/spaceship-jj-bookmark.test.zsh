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

  [[ "$expanded" =~ $'\e\\[[0-9;]*34m' ]] \
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

  [[ "$expanded" =~ $'\e\\[[0-9;]*34m' ]] \
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

  [[ "$expanded" =~ $'\e\\[[0-9;]*34m' ]] \
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

  [[ "$expanded" =~ $'\e\\[[0-9;]*34m' ]] \
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

  [[ "$expanded" =~ $'\e\\[[0-9;]*34m' ]] \
    || fail "jj bookmark should be blue: <$expanded>"

  # Check that the prompt begins with bold 'on '
  [[ "$expanded" =~ $'^\e\\[[0-9;]*1m(on )' ]] \
    || fail "prompt prefix should be bold: <$expanded>"
}

test_spaceship_jj_bookmark_show_false() {
  export SPACESHIP_JJ_BOOKMARK_SHOW=false

  local actual="$(spaceship::testkit::render_prompt)"
  local expanded="$(print -P -- "$actual")"
  local raw_section_text="$(printf '%s' "$expanded" | sed -E $'s/\x1b\\[[0-9;]*[[:alpha:]]//g')"

  # Bookmark section must not appear; only the desc change_id should show
  local pattern='^on 🥋 [a-z0-9]{8} $'

  [[ "$raw_section_text" =~ "$pattern" ]] \
    || fail "render with BOOKMARK_SHOW=false was: <$raw_section_text>, expected no bookmark"

  export SPACESHIP_JJ_BOOKMARK_SHOW=true
}

test_spaceship_jj_no_bookmark() {
  local fresh_dir
  fresh_dir="$(mktemp -d)"
  cd "$fresh_dir"
  jj git init >/dev/null 2>&1

  local actual="$(spaceship::testkit::render_prompt)"
  local expanded="$(print -P -- "$actual")"
  local raw_section_text="$(printf '%s' "$expanded" | sed -E $'s/\x1b\\[[0-9;]*[[:alpha:]]//g')"

  # No bookmarks in this repo — bookmark section must not appear
  local pattern='^on 🥋 [a-z0-9]{8} $'

  [[ "$raw_section_text" =~ "$pattern" ]] \
    || fail "render with no bookmarks was: <$raw_section_text>, expected no bookmark section"

  cd "$SHUNIT_TMPDIR"
  rm -rf "$fresh_dir"
}

test_spaceship_jj_bookmark_name_is_not_expanded() {
  local fresh_dir
  fresh_dir="$(mktemp -d)"
  cd "$fresh_dir"
  jj git init >/dev/null 2>&1
  jj bookmark c '"$(touch${IFS}pwned)"' >/dev/null 2>&1

  local actual="$(spaceship::testkit::render_prompt)"
  # Expand the prompt escapes only, as is the case when the prompt is displayed
  local expanded="$(setopt no_prompt_subst; print -rP -- "$actual")"
  local raw_section_text="$(printf '%s' "$expanded" | sed -E $'s/\x1b\\[[0-9;]*[[:alpha:]]//g')"

  [[ ! -e pwned ]] \
    || fail "command embedded in the bookmark name was executed"

  local expected='("$(touch${IFS}pwned)" @)'

  [[ "$raw_section_text" == *"$expected"* ]] \
    || fail "render in jj dir was: <$raw_section_text>, expected literal: <$expected>"

  cd "$SHUNIT_TMPDIR"
  rm -rf "$fresh_dir"
}

test_spaceship_jj_conflicted_bookmark() {
  local fresh_dir
  fresh_dir="$(mktemp -d)"
  cd "$fresh_dir"
  jj git init >/dev/null 2>&1
  jj commit -m "base" >/dev/null 2>&1
  jj describe -m "A" >/dev/null 2>&1
  local commit_a="$(jj log --no-graph -r @ -T commit_id 2>/dev/null)"
  jj new @- -m "B" >/dev/null 2>&1
  local commit_b="$(jj log --no-graph -r @ -T commit_id 2>/dev/null)"
  jj bookmark c feat -r @- >/dev/null 2>&1

  # Move the bookmark in two concurrent operations, so that it is conflicted
  local op="$(jj op log --no-graph -n 1 -T 'id.short()' 2>/dev/null)"
  jj bookmark set feat -r "$commit_a" --at-op="$op" >/dev/null 2>&1
  jj bookmark set feat -r "$commit_b" --at-op="$op" >/dev/null 2>&1
  jj new "$commit_a" "$commit_b" >/dev/null 2>&1

  local actual="$(spaceship::testkit::render_prompt)"
  local expanded="$(print -P -- "$actual")"
  local raw_section_text="$(printf '%s' "$expanded" | sed -E $'s/\x1b\\[[0-9;]*[[:alpha:]]//g')"

  # The bookmark is on both parents, but must only be counted once
  local pattern='^on 🥋 [a-z0-9]{8} \(feat\?\? @-\) $'

  [[ "$raw_section_text" =~ "$pattern" ]] \
    || fail "render in jj dir was: <$raw_section_text>, expected pattern match: <$pattern>"

  cd "$SHUNIT_TMPDIR"
  rm -rf "$fresh_dir"
}

test_spaceship_jj_bookmark_distance_across_merge() {
  local fresh_dir
  fresh_dir="$(mktemp -d)"
  cd "$fresh_dir"
  jj git init >/dev/null 2>&1
  jj describe -m "base" >/dev/null 2>&1
  jj bookmark c a >/dev/null 2>&1

  # A long branch and a short branch from the bookmark, which are then merged
  jj new a -m "long 1" >/dev/null 2>&1
  jj new -m "long 2" >/dev/null 2>&1
  jj new -m "long 3" >/dev/null 2>&1
  local long_branch="$(jj log --no-graph -r @ -T commit_id 2>/dev/null)"
  jj new a -m "short 1" >/dev/null 2>&1
  jj new @ "$long_branch" -m "merge" >/dev/null 2>&1
  jj new >/dev/null 2>&1

  local actual="$(spaceship::testkit::render_prompt)"
  local expanded="$(print -P -- "$actual")"
  local raw_section_text="$(printf '%s' "$expanded" | sed -E $'s/\x1b\\[[0-9;]*[[:alpha:]]//g')"

  # The shortest path is: working copy, merge, short 1, base
  local pattern='^on 🥋 [a-z0-9]{8} \(a @-3\) $'

  [[ "$raw_section_text" =~ "$pattern" ]] \
    || fail "render in jj dir was: <$raw_section_text>, expected pattern match: <$pattern>"

  cd "$SHUNIT_TMPDIR"
  rm -rf "$fresh_dir"
}

# ------------------------------------------------------------------------------
# SHUNIT2
# Run tests with shunit2
# ------------------------------------------------------------------------------

source "$SPACESHIP_ROOT/tests/shunit2/shunit2"
