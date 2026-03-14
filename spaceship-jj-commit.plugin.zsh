#
# jj
#
# jj is a supa-dupa cool tool for making you development easier.
# Link: https://www.jj.xyz

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_JJ_COMMIT_SHOW="${SPACESHIP_JJ_COMMIT_SHOW=false}"
SPACESHIP_JJ_COMMIT_SHOW_ID="${SPACESHIP_JJ_COMMIT_SHOW_COMMIT_ID=false}"
SPACESHIP_JJ_COMMIT_ASYNC="${SPACESHIP_JJ_COMMIT_ASYNC=true}"
SPACESHIP_JJ_COMMIT_PREFIX="${SPACESHIP_JJ_COMMIT_PREFIX=" "}"
SPACESHIP_JJ_COMMIT_SUFFIX="${SPACESHIP_JJ_COMMIT_SUFFIX=""}"
SPACESHIP_JJ_COMMIT_SYMBOL="${SPACESHIP_JJ_COMMIT_SYMBOL=""}"
SPACESHIP_JJ_COMMIT_COLOR="${SPACESHIP_JJ_COMMIT_COLOR="magenta"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show jj commit
# spaceship_ prefix before section's name is required!
# Otherwise this section won't be loaded.
spaceship_jj_commit() {
  # If SPACESHIP_JJ_COMMIT_SHOW is false, don't show jj commit section
  [[ $SPACESHIP_JJ_COMMIT_SHOW == false ]] && return

  # Check if jj command is available for execution
  spaceship::exists jj || return

  local jj_commit
  jj_commit="$(
    jj log -r @ -T 'commit_id.shortest(8)' --no-graph
  )"

  # The jj_commit content is mandatory
  [[ -z "$jj_commit" ]] && return

  # Display jj commit section
  spaceship::section::v4 \
    --color "$SPACESHIP_JJ_COMMIT_COLOR" \
    --prefix "$SPACESHIP_JJ_COMMIT_PREFIX" \
    --suffix "$SPACESHIP_JJ_COMMIT_SUFFIX" \
    --symbol "$SPACESHIP_JJ_COMMIT_SYMBOL" \
    "$jj_commit"
}
