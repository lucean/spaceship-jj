#
# spaceship-jj
#
# A Jujutsu section for Spaceship prompt
# Link: https://github.com/lucean/spaceship-jj

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_JJ_STATUS_ADDED="${SPACESHIP_JJ_STATUS_ADDED="+"}"
SPACESHIP_JJ_STATUS_MODIFIED="${SPACESHIP_JJ_STATUS_MODIFIED="!"}"
SPACESHIP_JJ_STATUS_RENAMED="${SPACESHIP_JJ_STATUS_RENAMED="»"}"
SPACESHIP_JJ_STATUS_DELETED="${SPACESHIP_JJ_STATUS_DELETED="✘"}"
SPACESHIP_JJ_STATUS_COPIED="${SPACESHIP_JJ_STATUS_COPIED="⊕"}"
SPACESHIP_JJ_STATUS_CONFLICTED="${SPACESHIP_JJ_STATUS_CONFLICTED="="}"
SPACESHIP_JJ_STATUS_COLOR="${SPACESHIP_JJ_STATUS_COLOR="red"}"
SPACESHIP_JJ_STATUS_PREFIX="${SPACESHIP_JJ_STATUS_PREFIX=""}"
SPACESHIP_JJ_STATUS_SUFFIX="${SPACESHIP_JJ_STATUS_SUFFIX=" "}"

# Returns a flat string of status chars for the working-copy commit, e.g. "MADR"
# Valid chars from jj are M, A, D, C, R.
spaceship_jj::status::chars() {
  spaceship_jj::log @ 'self.diff().files().map(|f| f.status_char()).join("")'
}

# Returns "1" if the working-copy commit contains conflicts, otherwise empty.
spaceship_jj::status::conflicted() {
  spaceship_jj::log @ 'if(self.conflict(), "1", "")'
}

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show jj status
spaceship_jj_status() {
  [[ $SPACESHIP_JJ_STATUS_SHOW == false ]] && return

  local chars conflicted jj_status=""
  chars="$(spaceship_jj::status::chars)"
  conflicted="$(spaceship_jj::status::conflicted)"

  [[ "$chars" == *A* ]] && jj_status+="$SPACESHIP_JJ_STATUS_ADDED"
  [[ "$chars" == *M* ]] && jj_status+="$SPACESHIP_JJ_STATUS_MODIFIED"
  [[ "$chars" == *R* ]] && jj_status+="$SPACESHIP_JJ_STATUS_RENAMED"
  [[ "$chars" == *D* ]] && jj_status+="$SPACESHIP_JJ_STATUS_DELETED"
  [[ "$chars" == *C* ]] && jj_status+="$SPACESHIP_JJ_STATUS_COPIED"
  [[ -n "$conflicted" ]] && jj_status+="$SPACESHIP_JJ_STATUS_CONFLICTED"

  [[ -n "$jj_status" ]] || return

  spaceship::section::v4 \
    --color "$SPACESHIP_JJ_STATUS_COLOR" \
    --prefix "$SPACESHIP_JJ_STATUS_PREFIX" \
    --suffix "$SPACESHIP_JJ_STATUS_SUFFIX" \
    "[${jj_status}]"
}

