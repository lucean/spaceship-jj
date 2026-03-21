#
# spaceship-jj
#
# A Jujutsu section for Spaceship prompt
# Link: https://github.com/lucean/spaceship-jj

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_JJ_DESC_SHOW="${SPACESHIP_JJ_DESC_SHOW=true}"
SPACESHIP_JJ_DESC_EMPTY_SHOW="${SPACESHIP_JJ_DESC_EMPTY_SHOW=false}"
SPACESHIP_JJ_DESC_ASYNC="${SPACESHIP_JJ_DESC_ASYNC=true}"
SPACESHIP_JJ_DESC_PREFIX="${SPACESHIP_JJ_DESC_PREFIX="$SPACESHIP_PROMPT_DEFAULT_PREFIX"}"
SPACESHIP_JJ_DESC_SUFFIX="${SPACESHIP_JJ_DESC_SUFFIX=" "}"
SPACESHIP_JJ_DESC_COLOR="${SPACESHIP_JJ_DESC_COLOR="yellow"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show jj desc
spaceship_jj_desc() {
  # If SPACESHIP_JJ_DESC_SHOW is false, don't show jj section
  [[ $SPACESHIP_JJ_DESC_SHOW == false ]] && return

  local jj_desc
  jj_desc="$(
    spaceship_jj::log @ \
      'change_id.shortest(8) ++ if(description, " (" ++ description.first_line() ++ ")", "")'
  )"

  local jj_empty=""
  [[ -z "$(spaceship_jj::run diff -r @ --summary)" && $SPACESHIP_JJ_DESC_EMPTY_SHOW != false ]] \
    && jj_empty="(empty)"

  # The jj_desc content is mandatory
  [[ -z "$jj_desc" ]] && return

  # Collect the active parts into the full descr
  jj_desc+="${jj_empty:+ $jj_empty}"

  # Display jj desc section
  spaceship::section::v4 \
    --color "$SPACESHIP_JJ_DESC_COLOR" \
    --prefix "$SPACESHIP_JJ_DESC_PREFIX" \
    --suffix "$SPACESHIP_JJ_DESC_SUFFIX" \
    "$jj_desc"
}
