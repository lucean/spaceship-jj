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
SPACESHIP_JJ_DESC_MAX_LENGTH="${SPACESHIP_JJ_DESC_MAX_LENGTH=999}"
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

  spaceship::exists jj || return

  # Use the details collected by the jj section, or collect them if this
  # section is being rendered on its own
  (( ${+spaceship_jj_data} )) || { local -A spaceship_jj_data; spaceship_jj::fetch || return }

  local jj_desc="${spaceship_jj_data[change_id]}"
  [[ -n "${spaceship_jj_data[desc]}" ]] && jj_desc+=" (${spaceship_jj_data[desc]})"

  local jj_empty=""
  [[ $SPACESHIP_JJ_DESC_EMPTY_SHOW == true && "${spaceship_jj_data[empty]}" == "1" ]] \
    && jj_empty="(empty)"

  # The jj_desc content is mandatory
  [[ -z "$jj_desc" ]] && return

  # The description is arbitrary text, so must not be expanded by the prompt
  jj_desc="$(spaceship_jj::escape "$jj_desc")"

  # Collect the active parts into the full descr
  jj_desc+="${jj_empty:+ $jj_empty}"

  # Display jj desc section
  spaceship::section::v4 \
    --color "$SPACESHIP_JJ_DESC_COLOR" \
    --prefix "$SPACESHIP_JJ_DESC_PREFIX" \
    --suffix "$SPACESHIP_JJ_DESC_SUFFIX" \
    "$jj_desc"
}
