#
# spaceship-jj
#
# A Jujutsu section for Spaceship prompt
# Link: https://github.com/lucean/spaceship-jj

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_JJ_COMMIT_SHOW="${SPACESHIP_JJ_COMMIT_SHOW=false}"
SPACESHIP_JJ_COMMIT_ASYNC="${SPACESHIP_JJ_COMMIT_ASYNC=true}"
SPACESHIP_JJ_COMMIT_PREFIX="${SPACESHIP_JJ_COMMIT_PREFIX=""}"
SPACESHIP_JJ_COMMIT_SUFFIX="${SPACESHIP_JJ_COMMIT_SUFFIX=" "}"
SPACESHIP_JJ_COMMIT_COLOR="${SPACESHIP_JJ_COMMIT_COLOR="magenta"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show jj commit
spaceship_jj_commit() {
  # If SPACESHIP_JJ_COMMIT_SHOW is false, don't show jj commit section
  [[ $SPACESHIP_JJ_COMMIT_SHOW == false ]] && return

  local jj_commit
  jj_commit="$(spaceship_jj::log @ 'commit_id.shortest(8)')"

  # The jj_commit content is mandatory
  [[ -z "$jj_commit" ]] && return

  # Display jj commit section
  spaceship::section::v4 \
    --color "$SPACESHIP_JJ_COMMIT_COLOR" \
    --prefix "$SPACESHIP_JJ_COMMIT_PREFIX" \
    --suffix "$SPACESHIP_JJ_COMMIT_SUFFIX" \
    "$jj_commit"
}
