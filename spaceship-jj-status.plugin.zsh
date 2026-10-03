#
# spaceship-jj
#
# A Jujutsu section for Spaceship prompt
# Link: https://github.com/lucean/spaceship-jj

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_JJ_STATUS_SHOW="${SPACESHIP_JJ_STATUS_SHOW=true}"
SPACESHIP_JJ_STATUS_ADDED="${SPACESHIP_JJ_STATUS_ADDED="+"}"
SPACESHIP_JJ_STATUS_MODIFIED="${SPACESHIP_JJ_STATUS_MODIFIED="!"}"
SPACESHIP_JJ_STATUS_RENAMED="${SPACESHIP_JJ_STATUS_RENAMED="»"}"
SPACESHIP_JJ_STATUS_DELETED="${SPACESHIP_JJ_STATUS_DELETED="✘"}"
SPACESHIP_JJ_STATUS_COPIED="${SPACESHIP_JJ_STATUS_COPIED="⊕"}"
SPACESHIP_JJ_STATUS_CONFLICTED="${SPACESHIP_JJ_STATUS_CONFLICTED="="}"
SPACESHIP_JJ_STATUS_COLOR="${SPACESHIP_JJ_STATUS_COLOR="red"}"
SPACESHIP_JJ_STATUS_PREFIX="${SPACESHIP_JJ_STATUS_PREFIX=""}"
SPACESHIP_JJ_STATUS_SUFFIX="${SPACESHIP_JJ_STATUS_SUFFIX=" "}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show jj status
spaceship_jj_status() {
  [[ $SPACESHIP_JJ_STATUS_SHOW == false ]] && return

  spaceship::exists jj || return

  # Use the details collected by the jj section, or collect them if this
  # section is being rendered on its own
  (( ${+spaceship_jj_data} )) || { local -A spaceship_jj_data; spaceship_jj::fetch || return }

  local jj_status=""
  local chars="${spaceship_jj_data[status]}"
  local conflicted="${spaceship_jj_data[conflict]}"

  [[ "$chars" == *A* ]] && jj_status+="$SPACESHIP_JJ_STATUS_ADDED"
  [[ "$chars" == *M* ]] && jj_status+="$SPACESHIP_JJ_STATUS_MODIFIED"
  [[ "$chars" == *R* ]] && jj_status+="$SPACESHIP_JJ_STATUS_RENAMED"
  [[ "$chars" == *D* ]] && jj_status+="$SPACESHIP_JJ_STATUS_DELETED"
  [[ "$chars" == *C* ]] && jj_status+="$SPACESHIP_JJ_STATUS_COPIED"
  [[ "$conflicted" == "1" ]] && jj_status+="$SPACESHIP_JJ_STATUS_CONFLICTED"

  [[ -n "$jj_status" ]] || return

  spaceship::section::v4 \
    --color "$SPACESHIP_JJ_STATUS_COLOR" \
    --prefix "$SPACESHIP_JJ_STATUS_PREFIX" \
    --suffix "$SPACESHIP_JJ_STATUS_SUFFIX" \
    "[${jj_status}]"
}

