#!/usr/bin/env bash

# Usage: print-gradle-task-and-options.sh <project-dir>
# Prints build options and task paths (one per line) to stdout
# Prints error messages to stderr and exits with non-zero code on failure

# absolute directory of this script (so we can reference sibling files reliably)
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

# set -u

# make sure the target location is a valid Gradle project with an executable wrapper
project_dir="${1:-}"
if [[ -z "$project_dir" ]]; then
  echo "Must specify Gradle project directory" >&2
  exit 2
fi

if [[ ! -f "$project_dir/gradlew" ]]; then
  echo "Gradle wrapper is not present in $project_dir" >&2
  exit 2
fi

if [[ ! -x "$project_dir/gradlew" ]]; then
  echo "Gradle wrapper is not executable in $project_dir" >&2
  exit 2
fi

# canonicalize project_dir to an absolute path to avoid relying on the caller's working directory
project_dir="$(cd -- "$project_dir" && pwd -P)"

gradlew="$project_dir/gradlew"

# get gradle_version
version_output="$("$gradlew" -p "$project_dir" --version)"
gradle_version="$(echo "$version_output" | grep -m1 '^Gradle ' | awk '{print $2}' | sed 's/-.*//')"

if [[ -z "$gradle_version" ]]; then
  echo "Failed to parse Gradle version in $project_dir" >&2
  exit 2
fi

# print project tasks (w/ leading ':') and task selectors (wo/ leading ':')
tasks_output="$("$gradlew" -p "$project_dir" tasks --all --no-scan 2>/dev/null)"
tasks_exit_code=$?
if [[ $tasks_exit_code -ne 0 ]]; then
  echo "Failed to run ./gradlew tasks --all in $project_dir" >&2
  exit 2
fi

echo "$tasks_output" | awk '
  function emit(x) {
    if (x == "" || seen[x]++) return
    print x
  }
  {
    # Task lines are either:
    #   <taskPath> - <description...>
    # or a single token like:
    #   <taskPath>
    if (NF == 1 || $2 == "-") {
      name = $1
      # ignore non-task markers
      if (name == "BUILD" || name == "BUILD" || name == "USAGE:" || name == ">") next
      if (name ~ /^-+$/) next
      if (name ~ /^>/) next

      # normalize leading colon
      gsub(/^:/, "", name)

      # leaf task name (after the last colon)
      leaf = name
      sub(/^.*:/, "", leaf)

      emit(leaf)
      emit(":" leaf)
      emit(name)
      emit(":" name)
    }
  }
'