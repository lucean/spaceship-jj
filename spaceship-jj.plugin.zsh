#
# spaceship-jj
#
# A Jujutsu section for Spaceship prompt
# Link: https://github.com/lucean/spaceship-jj

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_JJ_SHOW="${SPACESHIP_JJ_SHOW=true}"
SPACESHIP_JJ_ASYNC="${SPACESHIP_JJ_ASYNC=true}"
SPACESHIP_JJ_PREFIX="${SPACESHIP_JJ_PREFIX="on "}"
SPACESHIP_JJ_SUFFIX="${SPACESHIP_JJ_SUFFIX=""}"
SPACESHIP_JJ_SYMBOL="${SPACESHIP_JJ_SYMBOL="🥋 "}"
SPACESHIP_JJ_SNAPSHOT="${SPACESHIP_JJ_SNAPSHOT=true}"
SPACESHIP_JJ_ERROR="${SPACESHIP_JJ_ERROR="?"}"

typeset -g SPACESHIP_JJ_ROOT
SPACESHIP_JJ_ROOT="${${(%):-%N}:A:h}"

if [ -z "$SPACESHIP_JJ_ORDER" ]; then
  SPACESHIP_JJ_ORDER=(jj_desc jj_commit jj_bookmark jj_status)
fi

# ------------------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------------------

spaceship_jj::run() {
  local -a jj_opts=(--at-op=@ --no-pager --color=never)
  [[ $SPACESHIP_JJ_SNAPSHOT == false ]] && jj_opts+=(--ignore-working-copy)

  jj "${jj_opts[@]}" "$@" 2>/dev/null
}

spaceship_jj::log() {
  spaceship_jj::run log --no-graph -r "$1" -T "$2"
}

# Escape repo-derived text so that it is rendered literally by the prompt.
spaceship_jj::escape() {
  # Percent signs would otherwise be treated as prompt escapes. Backslashes
  # would otherwise be consumed by the `echo` calls that Spaceship uses to
  # compose sections, so each is followed by an empty `%{%}` sequence, which
  # stops it from forming an escape sequence and disappears on rendering.
  local text="$1"
  text="${text//\%/%%}"
  text="${text//\\/\\%{%\}}"
  print -rn -- "$text"
}

# Check if the current directory is within a jj workspace, without running jj
spaceship_jj::in_workspace() {
  local dir="$PWD"

  while true; do
    [[ -d "$dir/.jj" ]] && return 0
    [[ "$dir" == "/" || -z "$dir" ]] && return 1
    dir="${dir:h}"
  done
}

# Collect everything that the subsections need with a single jj invocation.
# The results are stored in the spaceship_jj_data associative array, which must
# be declared by the caller.
spaceship_jj::fetch() {
  spaceship_jj::in_workspace || return 1

  local commit_id='commit_id.shortest(8)'
  [[ $SPACESHIP_JJ_COMMIT_FULL == true ]] && commit_id='commit_id'

  local max_length="$SPACESHIP_JJ_DESC_MAX_LENGTH"
  [[ "$max_length" == <-> ]] || max_length=999

  # A "W" line holds the details of the working copy. An "N" line holds the
  # parents and bookmarks of each commit between the nearest bookmarked
  # ancestors and the working copy.
  local template='
    if(current_working_copy,
      "W\t" ++ commit_id
        ++ "\t" ++ change_id.shortest(8)
        ++ "\t" ++ '"$commit_id"'
        ++ "\t" ++ if(empty, "1", "0")
        ++ "\t" ++ if(conflict, "1", "0")
        ++ "\t" ++ self.diff().files().map(|f| f.status_char()).join("")
        ++ "\t" ++ if(description, truncate_end('"$max_length"', description.first_line(), "…"))
        ++ "\n"
    ) ++
    "N\t" ++ commit_id
      ++ "\t" ++ parents.map(|p| p.commit_id()).join(",")
      ++ local_bookmarks.map(|b| "\t" ++ b.name() ++ if(b.conflict(), "??")).join("")
      ++ "\n"'

  local output
  output="$(spaceship_jj::log '@ | heads(::@ & bookmarks())::@' "$template")"

  [[ -z "$output" ]] && return 1

  local line working_copy=""
  local -a fields
  local -A commit_parents commit_bookmarks

  for line in "${(@f)output}"; do
    fields=("${(@ps:\t:)line}")

    case "${fields[1]}" in
      W)
        working_copy="${fields[2]}"
        spaceship_jj_data[change_id]="${fields[3]}"
        spaceship_jj_data[commit_id]="${fields[4]}"
        spaceship_jj_data[empty]="${fields[5]}"
        spaceship_jj_data[conflict]="${fields[6]}"
        spaceship_jj_data[status]="${fields[7]}"
        spaceship_jj_data[desc]="${(pj:\t:)fields[8,-1]}"
        ;;
      N)
        commit_parents[${fields[2]}]="${fields[3]}"
        (( ${#fields} > 3 )) && commit_bookmarks[${fields[2]}]="${(pj:\n:)fields[4,-1]}"
        ;;
    esac
  done

  [[ -z "$working_copy" ]] && return 1

  # Walk back from the working copy, one generation at a time, until reaching
  # the nearest bookmarks. The distance is then the length of the shortest
  # path to them, however many other commits have been merged in along the way.
  local id parent distance=0
  local -a frontier=("$working_copy") next bookmarks
  local -A seen

  while (( ${#frontier} )); do
    (( distance++ ))
    next=()

    for id in "${frontier[@]}"; do
      [[ -n "${commit_bookmarks[$id]}" ]] && bookmarks+=("${(@f)commit_bookmarks[$id]}")

      for parent in "${(@s:,:)commit_parents[$id]}"; do
        [[ -n "$parent" ]] || continue
        (( ${+commit_parents[$parent]} )) || continue
        (( ${+seen[$parent]} )) && continue
        seen[$parent]=1
        next+=("$parent")
      done
    done

    (( ${#bookmarks} )) && break
    frontier=("${next[@]}")
  done

  # A conflicted bookmark can be present on several commits
  bookmarks=("${(@u)bookmarks}")

  spaceship_jj_data[bookmark]="${bookmarks[1]}"
  spaceship_jj_data[bookmark_count]=${#bookmarks}
  spaceship_jj_data[distance]=$distance

  return 0
}

# ------------------------------------------------------------------------------
# Dependencies
# ------------------------------------------------------------------------------

source "$SPACESHIP_JJ_ROOT/spaceship-jj-desc.plugin.zsh"
source "$SPACESHIP_JJ_ROOT/spaceship-jj-commit.plugin.zsh"
source "$SPACESHIP_JJ_ROOT/spaceship-jj-bookmark.plugin.zsh"
source "$SPACESHIP_JJ_ROOT/spaceship-jj-status.plugin.zsh"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show both jj description and jj status
spaceship_jj() {
  [[ $SPACESHIP_JJ_SHOW == false ]] && return

  # Check if jj command is available for execution
  spaceship::exists jj || return

  # Check if the current directory contains a jj project
  spaceship_jj::in_workspace || return

  # Collect the details shared by the subsections
  local -A spaceship_jj_data
  if ! spaceship_jj::fetch; then
    # Indicate that jj failed, rather than silently hiding the section
    [[ -z "$SPACESHIP_JJ_ERROR" ]] && return

    spaceship::section::v4 \
      --color "red" \
      --prefix "$SPACESHIP_JJ_PREFIX" \
      --suffix "$SPACESHIP_JJ_SUFFIX" \
      --symbol "$SPACESHIP_JJ_SYMBOL" \
      "$(spaceship_jj::escape "$SPACESHIP_JJ_ERROR") "
    return
  fi

  # Refresh parts of the jj section
  local subsection
  for subsection in "${SPACESHIP_JJ_ORDER[@]}"; do
    spaceship::core::refresh_section --sync "$subsection"
  done

  local jj_section="$(spaceship::core::compose_order $SPACESHIP_JJ_ORDER)"

  # Display jj section
  spaceship::section::v4 \
    --color "white" \
    --prefix "$SPACESHIP_JJ_PREFIX" \
    --suffix "$SPACESHIP_JJ_SUFFIX" \
    --symbol "$SPACESHIP_JJ_SYMBOL" \
    "$jj_section"
}
