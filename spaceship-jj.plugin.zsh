#
# jj
#
# jj is a supa-dupa cool tool for making you development easier.
# Link: https://www.jj.xyz

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_JJ_SHOW="${SPACESHIP_JJ_SHOW=true}"
SPACESHIP_JJ_ASYNC="${SPACESHIP_JJ_ASYNC=true}"
SPACESHIP_JJ_PREFIX="${SPACESHIP_JJ_PREFIX="$SPACESHIP_PROMPT_DEFAULT_PREFIX"}"
SPACESHIP_JJ_SUFFIX="${SPACESHIP_JJ_SUFFIX="$SPACESHIP_PROMPT_DEFAULT_SUFFIX"}"
SPACESHIP_JJ_SYMBOL="${SPACESHIP_JJ_SYMBOL="🥋 "}"
SPACESHIP_JJ_COLOR="${SPACESHIP_JJ_COLOR="yellow"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show jj status
# spaceship_ prefix before section's name is required!
# Otherwise this section won't be loaded.
spaceship_jj() {
  # If SPACESHIP_JJ_SHOW is false, don't show jj section
  [[ $SPACESHIP_JJ_SHOW == false ]] && return

  # Check if jj command is available for execution
  spaceship::exists jj || return

  jj root >/dev/null 2>&1 || return

  local jj_info
  jj_info="$(
    jj --at-op=@ --ignore-working-copy --no-pager \
      log -r @ --limit 1 --no-graph \
      --template 'change_id.shortest(8) ++ if(description, " (" ++ description.first_line() ++ ")", "")' \
      2>/dev/null
  )"

  [[ -z "$jj_info" ]] && return

  # Display jj section
  spaceship::section::v4 \
    --color "$SPACESHIP_JJ_COLOR" \
    --prefix "$SPACESHIP_JJ_PREFIX" \
    --suffix "$SPACESHIP_JJ_SUFFIX" \
    --symbol "$SPACESHIP_JJ_SYMBOL" \
    "$jj_info"
}
