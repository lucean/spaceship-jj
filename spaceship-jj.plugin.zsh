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

# Escape repo-derived text so that it is rendered literally by the prompt,
# rather than being subjected to prompt, parameter or command expansion.
spaceship_jj::escape() {
  # Special characters are replaced with a `${(#):-<code>}` expansion, which
  # yields the literal character. Backslash escapes can't be used here, as they
  # are consumed by the `echo` calls that Spaceship uses to compose sections.
  local text="$1"
  local dollar='${(#):-36}' backslash='${(#):-92}' backtick='${(#):-96}'
  text="${text//\$/$dollar}"
  text="${text//\\/$backslash}"
  text="${text//\`/$backtick}"
  text="${text//\%/%%}"
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
  local commit_id='commit_id.shortest(8)'
  [[ $SPACESHIP_JJ_COMMIT_FULL == true ]] && commit_id='commit_id'

  local max_length="$SPACESHIP_JJ_DESC_MAX_LENGTH"
  [[ "$max_length" == <-> ]] || max_length=999

  # A "W" line holds the details of the working copy, followed by a "B" line
  # for each bookmarked commit or a "C" line for each other commit, between
  # the nearest bookmarked ancestors and the working copy.
  local template='
    if(current_working_copy,
      "W\t" ++ change_id.shortest(8)
        ++ "\t" ++ '"$commit_id"'
        ++ "\t" ++ if(empty, "1", "0")
        ++ "\t" ++ if(conflict, "1", "0")
        ++ "\t" ++ self.diff().files().map(|f| f.status_char()).join("")
        ++ "\t" ++ if(description, truncate_end('"$max_length"', description.first_line(), "…"))
        ++ "\n"
    ) ++
    if(local_bookmarks,
      "B\t" ++ commit_id ++ local_bookmarks.map(|b| "\t" ++ b.name()).join(""),
      "C"
    ) ++ "\n"'

  local output
  output="$(spaceship_jj::log '@ | heads(::@ & bookmarks())::@' "$template")"

  [[ -z "$output" ]] && return 1

  local line distance=0
  local -a fields bookmarks bookmark_heads

  for line in "${(@f)output}"; do
    fields=("${(@ps:\t:)line}")

    case "${fields[1]}" in
      W)
        spaceship_jj_data[change_id]="${fields[2]}"
        spaceship_jj_data[commit_id]="${fields[3]}"
        spaceship_jj_data[empty]="${fields[4]}"
        spaceship_jj_data[conflict]="${fields[5]}"
        spaceship_jj_data[status]="${fields[6]}"
        spaceship_jj_data[desc]="${(pj:\t:)fields[7,-1]}"
        ;;
      B)
        (( distance++ ))
        bookmark_heads+=("${fields[2]}")
        bookmarks+=("${(@)fields[3,-1]}")
        ;;
      C)
        (( distance++ ))
        ;;
    esac
  done

  [[ -z "${spaceship_jj_data[change_id]}" ]] && return 1

  # When there are several bookmarked heads, measure the distance from the
  # first of them, as the combined log covers the ancestry of them all.
  if (( ${#bookmark_heads} > 1 )); then
    output="$(spaceship_jj::log "::@ & ${bookmark_heads[1]}::" '"x\n"')"
    distance=${#${(@f)output}}
  fi

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
  spaceship_jj::fetch || return

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
