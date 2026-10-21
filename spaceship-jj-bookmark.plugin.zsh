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

  # Use the details collected by the jj section, or collect them if this
  # section is being rendered on its own
  (( ${+spaceship_jj_data} )) || { local -A spaceship_jj_data; spaceship_jj::fetch || return }

  local jj_bookmark_name="${spaceship_jj_data[bookmark]}"
  local jj_bookmark_count="${spaceship_jj_data[bookmark_count]}"
  local jj_distance="${spaceship_jj_data[distance]}"

  [[ -z "$jj_bookmark_name" ]] && return
  [[ "$jj_distance" -ge 1 ]] || return

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
    # The bookmark name is arbitrary text, so must not be expanded by the prompt
    jj_bookmark="$(spaceship_jj::escape "$jj_bookmark_name") ${jj_position}"
  fi

  spaceship::section::v4 \
    --color "$SPACESHIP_JJ_BOOKMARK_COLOR" \
    --prefix "$SPACESHIP_JJ_BOOKMARK_PREFIX" \
    --suffix "$SPACESHIP_JJ_BOOKMARK_SUFFIX" \
    "($jj_bookmark)"
}
