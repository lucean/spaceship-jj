#
# spaceship-jj
#
# A Jujutsu section for Spaceship prompt
# Link: https://github.com/lucean/spaceship-jj

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_JJ_BOOKMARK_SHOW="${SPACESHIP_JJ_BOOKMARK_SHOW=true}"
SPACESHIP_JJ_BOOKMARK_ASYNC="${SPACESHIP_JJ_BOOKMARK_ASYNC=true}"
SPACESHIP_JJ_BOOKMARK_PREFIX="${SPACESHIP_JJ_BOOKMARK_PREFIX=""}"
SPACESHIP_JJ_BOOKMARK_SUFFIX="${SPACESHIP_JJ_BOOKMARK_SUFFIX=" "}"
SPACESHIP_JJ_BOOKMARK_COLOR="${SPACESHIP_JJ_BOOKMARK_COLOR="blue"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show jj bookmark
spaceship_jj_bookmark() {
  [[ $SPACESHIP_JJ_BOOKMARK_SHOW == false ]] && return

  spaceship::exists jj || return

  local jj_bookmark_names
  jj_bookmark_names="$(
    spaceship_jj::log "heads(::@ & bookmarks())" \
      'local_bookmarks.map(|b| b.name() ++ "\n").join("")'
  )"

  [[ -z "$jj_bookmark_names" ]] && return

  local -a jj_bookmarks=("${(f)${jj_bookmark_names}}")
  local jj_bookmark_count=${#jj_bookmarks}
  local jj_bookmark_name="${jj_bookmarks[1]}"

  local jj_distance
  jj_distance="$(
    spaceship_jj::log "::@ & $jj_bookmark_name::" 'self.commit_id() ++ "\n"' \
      | wc -l | tr -d ' '
  )"

  [[ -z "$jj_distance" ]] && return

  local jj_position
  case "$jj_distance" in
    1)
      jj_position='@'
      ;;
    2)
      jj_position='@-'
      ;;
    3)
      jj_position='@--'
      ;;
    *)
      jj_position="@-$((jj_distance - 1))"
      ;;
  esac

  local jj_bookmark
  if [[ "$jj_bookmark_count" -gt 1 ]]; then
    jj_bookmark="<${jj_bookmark_count} bookmarks> ${jj_position}"
  else
    jj_bookmark="${jj_bookmark_name} ${jj_position}"
  fi

  spaceship::section::v4 \
    --color "$SPACESHIP_JJ_BOOKMARK_COLOR" \
    --prefix "$SPACESHIP_JJ_BOOKMARK_PREFIX" \
    --suffix "$SPACESHIP_JJ_BOOKMARK_SUFFIX" \
    "($jj_bookmark)"
}
