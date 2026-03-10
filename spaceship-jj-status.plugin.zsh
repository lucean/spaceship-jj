#
# jj
#
# jj is a supa-dupa cool tool for making you development easier.
# Link: https://www.jj.xyz

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
SPACESHIP_JJ_STATUS_PREFIX="${SPACESHIP_JJ_STATUS_PREFIX="["}"
SPACESHIP_JJ_STATUS_SUFFIX="${SPACESHIP_JJ_STATUS_SUFFIX="]"}"

SPACESHIP_JJ_STATUS_IGNORE_WORKING_COPY="${SPACESHIP_JJ_STATUS_IGNORE_WORKING_COPY=false}"

# ------------------------------------------------------------------------------
# Helper functions
# ------------------------------------------------------------------------------
spaceship_jj::status::run() {
  local -a args
  args=(--no-pager)

  if [[ "$SPACESHIP_JJ_STATUS_IGNORE_WORKING_COPY" == true ]]; then
    args+=(--ignore-working-copy --at-op=@)
  fi

  jj "${args[@]}" "$@" 2>/dev/null
}

spaceship_jj::status::is_repo() {
  spaceship::exists jj || return 1
  jj root >/dev/null 2>&1
}

# Returns a flat string of status chars for the working-copy commit, e.g. "MADR"
# Valid chars from jj are M, A, D, C, R.
spaceship_jj::status::chars() {
  spaceship_jj::status::run log \
    -r @ \
    --limit 1 \
    --no-graph \
    --template 'self.diff().files().map(|f| f.status_char()).join("")'
}

# Returns "1" if the working-copy commit contains conflicts, otherwise empty.
spaceship_jj::status::conflicted() {
  spaceship_jj::status::run log \
    -r @ \
    --limit 1 \
    --no-graph \
    --template 'if(self.conflict(), "1", "")'
}

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

spaceship_jj_status() {
  [[ $SPACESHIP_JJ_STATUS_SHOW == false ]] && return
  spaceship_jj::status::is_repo || return

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
    "${SPACESHIP_JJ_STATUS_PREFIX}${jj_status}${SPACESHIP_JJ_STATUS_SUFFIX}"
}

