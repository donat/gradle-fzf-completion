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

gradlew="$project_dir/gradlew"

# get gradle_version
version_output="$("$gradlew" -p "$project_dir" --version)"
gradle_version="$(echo "$version_output" | grep -m1 '^Gradle ' | awk '{print $2}' | sed 's/-.*//')"

if [[ -z "$gradle_version" ]]; then
  echo "Failed to parse Gradle version in $project_dir" >&2
  exit 2
fi

# print the default tasks depending on the Gradle version

"$script_dir/print-gradle-tasks.sh" "$project_dir" | sort -u
"$script_dir/print-gradle-build-options.sh" "$project_dir" | sort -u
