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
SPACESHIP_JJ_PREFIX="${SPACESHIP_JJ_PREFIX="on "}"
SPACESHIP_JJ_SUFFIX="${SPACESHIP_JJ_SUFFIX=" "}"
SPACESHIP_JJ_SYMBOL="${SPACESHIP_JJ_SYMBOL="🥋 "}"

typeset -g SPACESHIP_JJ_ROOT
SPACESHIP_JJ_ROOT="${${(%):-%N}:A:h}"

if [ -z "$SPACESHIP_JJ_ORDER" ]; then
  SPACESHIP_JJ_ORDER=(jj_desc jj_status)
fi

# ------------------------------------------------------------------------------
# Dependencies
# ------------------------------------------------------------------------------

source "$SPACESHIP_JJ_ROOT/spaceship-jj-desc.plugin.zsh"
source "$SPACESHIP_JJ_ROOT/spaceship-jj-status.plugin.zsh"

# spaceship::precompile "$SPACESHIP_ROOT/sections/jj_desc.zsh"
# spaceship::precompile "$SPACESHIP_ROOT/sections/jj_status.zsh"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show both jj description and jj status
spaceship_jj() {
  [[ $SPACESHIP_JJ_SHOW == false ]] && return

  # Check if jj command is available for execution
  spaceship::exists jj || return

  # Refresh parts of the jj section
  for subsection in "${SPACESHIP_JJ_ORDER[@]}"; do
    spaceship::core::refresh_section --sync "$subsection"
  done

  local jj_data="$(spaceship::core::compose_order $SPACESHIP_JJ_ORDER)"

  # Display jj section
  spaceship::section::v4 \
    --color "white" \
    --prefix "$SPACESHIP_JJ_PREFIX" \
    --suffix "$SPACESHIP_JJ_SUFFIX" \
    "$jj_data"
}
