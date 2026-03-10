#
# jj
#
# jj is a supa-dupa cool tool for making you development easier.
# Link: https://www.jj.xyz

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_JJ_DESC_SHOW="${SPACESHIP_JJ_DESC_SHOW=true}"
SPACESHIP_JJ_DESC_ASYNC="${SPACESHIP_JJ_DESC_ASYNC=true}"
SPACESHIP_JJ_DESC_PREFIX="${SPACESHIP_JJ_DESC_PREFIX="$SPACESHIP_PROMPT_DEFAULT_PREFIX"}"
SPACESHIP_JJ_DESC_SUFFIX="${SPACESHIP_JJ_DESC_SUFFIX=""}"
SPACESHIP_JJ_DESC_SYMBOL="${SPACESHIP_JJ_DESC_SYMBOL="🥋 "}"
SPACESHIP_JJ_DESC_COLOR="${SPACESHIP_JJ_DESC_COLOR="yellow"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show jj desc
# spaceship_ prefix before section's name is required!
# Otherwise this section won't be loaded.
spaceship_jj_desc() {
  # If SPACESHIP_JJ_DESC_SHOW is false, don't show jj section
  [[ $SPACESHIP_JJ_DESC_SHOW == false ]] && return

  # Check if jj command is available for execution
  spaceship::exists jj || return

  local jj_desc
  jj_desc="$(
    jj --at-op=@ --ignore-working-copy --no-pager \
      log -r @ --limit 1 --no-graph \
      --template 'change_id.shortest(8) ++ if(description, " (" ++ description.first_line() ++ ")", "")' \
      2>/dev/null
  )"

  [[ -z "$jj_desc" ]] && return

  # Display jj desc section
  spaceship::section::v4 \
    --color "$SPACESHIP_JJ_DESC_COLOR" \
    --prefix "$SPACESHIP_JJ_DESC_PREFIX" \
    --suffix "$SPACESHIP_JJ_DESC_SUFFIX" \
    --symbol "$SPACESHIP_JJ_DESC_SYMBOL" \
    "$jj_desc"
}
