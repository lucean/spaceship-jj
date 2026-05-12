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

  local status_raw jj_status=""
  status_raw="$(spaceship_jj::log @ 'self.diff().files().map(|f| f.status_char()).join("") ++ ":" ++ if(self.conflict(), "1", "0")')"

  [[ -z "$status_raw" ]] && return

  local chars="${status_raw%%:*}"
  local conflicted="${status_raw##*:}"

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

