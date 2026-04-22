# Gradle wrapper completion plugin for oh-my-zsh

# Common Gradle tasks with descriptions
_GRADLE_TASKS=(
  "assembleDebug:Build debug APK"
  "assembleRelease:Build release APK"
  "installDebug:Install debug APK on device"
  "testReleaseUnitTest:Run unit tests (release)"
  "testDebugUnitTest:Run unit tests (debug)"
  "recordScreenshots:Record Paparazzi screenshot baselines"
  "verifyScreenshots:Verify Paparazzi screenshots"
  "lint:Run lint checks"
  "clean:Clean build outputs"
  "dependencyGuard:Verify dependency guard"
  "dependencyGuardBaseline:Update dependency guard baseline"
  "assemble:Build all variants"
  "test:Run all tests"
  "tasks:List available tasks"
)

# Refresh the module cache for the current project
gradle-completion-index-modules() {
  local project_root
  project_root="$(_gradle_get_project_root)" || { echo "Not in a Gradle project"; return 1; }
  local cache_file="$(_gradle_cache_file "$project_root")"
  rm -f "$cache_file"
  _gradle_build_cache "$project_root" "$cache_file"
  echo "Cache refreshed: $(wc -l < "$cache_file" | tr -d ' ') modules found"
}

_gradle_get_project_root() {
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/settings.gradle.kts" || -f "$dir/settings.gradle" ]]; then
      echo "$dir"
      return 0
    fi
    dir="${dir:h}"
  done
  return 1
}

_gradle_cache_file() {
  local project_root="$1"
  local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/gradle-completions"
  mkdir -p "$cache_dir"
  local project_hash
  if command -v md5 &>/dev/null; then
    project_hash=$(echo "$project_root" | md5)
  else
    project_hash=$(echo "$project_root" | md5sum | cut -d' ' -f1)
  fi
  echo "$cache_dir/$project_hash.txt"
}

_gradle_build_cache() {
  local project_root="$1"
  local cache_file="$2"
  python3 "$HOME/.oh-my-zsh/custom/plugins/gradle-completion/gradle-scan-modules.py" "$project_root" "$cache_file"
}

_gradle_get_modules() {
  local project_root="$1"
  local cache_file
  cache_file="$(_gradle_cache_file "$project_root")"

  local settings_file="$project_root/settings.gradle.kts"
  [[ -f "$settings_file" ]] || settings_file="$project_root/settings.gradle"

  if [[ ! -f "$cache_file" ]] || [[ "$settings_file" -nt "$cache_file" ]]; then
    _gradle_build_cache "$project_root" "$cache_file"
  fi

  cat "$cache_file"
}

_gradlew_complete() {
  local project_root
  project_root="$(_gradle_get_project_root)" || return

  local current_word="${words[CURRENT]}"

  # User typed ':' — they want a module path
  if [[ "$current_word" == :* ]]; then
    local modules
    modules="$(_gradle_get_modules "$project_root")"

    # If the current word (with trailing colon stripped) matches a known module,
    # offer tasks — handles both :module:impl and :module:impl: (trailing colon)
    # Check if current word is :module:path: (trailing colon) or :module:path:taskprefix
    local module_candidate task_prefix
    if [[ "$current_word" == *: ]]; then
      # Trailing colon — no task prefix typed yet
      module_candidate="${current_word%:}"
      task_prefix=""
    else
      # Something typed after last colon — could be a task prefix
      module_candidate="${current_word%:*}"
      task_prefix="${current_word##*:}"
    fi

    local matched_module
    matched_module=$(echo "$modules" | grep -Fix "$module_candidate" | head -1)
    if [[ -n "$matched_module" ]]; then
      local prefix="${current_word%${task_prefix}}"

      # Offer sub-modules
      local -a sub_segments
      local -A seen_subs
      local sub_line
      local matched_module_lower="${matched_module:l}"
      local matched_module_len=${#matched_module}
      while IFS= read -r sub_line; do
        [[ "${sub_line:l}" == "${matched_module_lower}:"* ]] || continue
        local sub_remainder="${sub_line[${matched_module_len}+2,-1]}"
        local sub_segment="${sub_remainder%%:*}"
        [[ -n "$sub_segment" ]] || continue
        [[ -z "${seen_subs[$sub_segment]}" ]] || continue
        seen_subs[$sub_segment]=1
        sub_segments+=("$sub_segment")
      done <<< "$modules"
      [[ ${#sub_segments[@]} -gt 0 ]] && compadd -p "${module_candidate}:" -S '' -- "${sub_segments[@]}"

      # Offer tasks
      local -a matching_tasks
      local task_entry task_name
      for task_entry in "${_GRADLE_TASKS[@]}"; do
        task_name="${task_entry%%:*}"
        [[ "${task_name:l}" == "${task_prefix:l}"* ]] && matching_tasks+=("$task_name")
      done
      [[ ${#matching_tasks[@]} -gt 0 ]] && compadd -p "$prefix" -S '' -- "${matching_tasks[@]}"
      return
    fi

    # Otherwise complete the next path segment
    local -a next_segments
    local -A seen
    local line
    local current_word_lower="${current_word:l}"
    while IFS= read -r line; do
      [[ "${line:l}" == "${current_word_lower}"* ]] || continue
      local remainder="${line[${#current_word}+1,-1]}"
      # Take only up to the next colon — one segment at a time
      local next_segment="${remainder%%:*}"
      [[ -n "$next_segment" ]] || continue
      local candidate="${current_word}${next_segment}"
      [[ -z "${seen[$candidate]}" ]] || continue
      seen[$candidate]=1
      if echo "$modules" | grep -qFx "$candidate"; then
        # This is a full module — append : to invite task or sub-module completion
        next_segments+=("${candidate}:")
      else
        next_segments+=("${candidate}")
      fi
    done <<< "$modules"

    [[ ${#next_segments[@]} -gt 0 ]] && compadd -S '' "${next_segments[@]}"
    return
  fi

  # No ':' typed — offer bare tasks and hint that ':' starts a module path
  _describe 'gradle tasks' _GRADLE_TASKS
  compadd -S '' -- ':'
}

compdef _gradlew_complete gradlew
compdef _gradlew_complete './gradlew'
