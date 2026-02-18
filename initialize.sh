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

# Convert Gradle version (e.g. 3.0, 9.14.1) to a comparable integer in the form: MMmmpp
# where MM=major (2 digits), mm=minor (2 digits), pp=patch (2 digits).
# Examples: 3.0 -> 030000, 9.14.1 -> 091401, 9.14 -> 091400
__gradle_version_to_number() {
  local v="$1"
  local major minor patch

  # Strip any suffix just in case (we already do this above, but keep it robust)
  v="${v%%-*}"

  IFS='.' read -r major minor patch <<<"$v"
  major="${major:-0}"
  minor="${minor:-0}"
  patch="${patch:-0}"

  printf '%02d%02d%02d' "$major" "$minor" "$patch"
}

gradleVersionNumber="$(__gradle_version_to_number "$gradle_version")"

# Print built-in tasks for the detected Gradle version.
# IMPORTANT: Keep output free of duplicates.
# NOTE: The big comment list below is the source of truth; this if/elif chain is derived from it.

# Force base-10 for numbers with leading zeros.
if [ $((10#$gradleVersionNumber)) -lt 30100 ]; then
  # < 3.1.0  (use 3.0/3.1 task set)
  echo buildEnvironment
  echo components
  echo dependencies
  echo dependencyInsight
  echo help
  echo init
  echo model
  echo projects
  echo properties
  echo tasks
  echo wrapper
elif [ $((10#$gradleVersionNumber)) -lt 60000 ]; then
  # < 6.0.0  (3.2+ adds dependentComponents)
  echo buildEnvironment
  echo components
  echo dependencies
  echo dependencyInsight
  echo dependentComponents
  echo help
  echo init
  echo model
  echo projects
  echo properties
  echo tasks
  echo wrapper
elif [ $((10#$gradleVersionNumber)) -lt 60800 ]; then
  # < 6.8.0  (6.0+ adds outgoingVariants)
  echo buildEnvironment
  echo components
  echo dependencies
  echo dependencyInsight
  echo dependentComponents
  echo help
  echo init
  echo model
  echo outgoingVariants
  echo projects
  echo properties
  echo tasks
  echo wrapper
elif [ $((10#$gradleVersionNumber)) -lt 70500 ]; then
  # < 7.5.0  (6.8+ adds javaToolchains)
  echo buildEnvironment
  echo components
  echo dependencies
  echo dependencyInsight
  echo dependentComponents
  echo help
  echo init
  echo javaToolchains
  echo model
  echo outgoingVariants
  echo projects
  echo properties
  echo tasks
  echo wrapper
elif [ $((10#$gradleVersionNumber)) -lt 80800 ]; then
  # < 8.8.0  (7.5+ adds resolvableConfigurations)
  echo buildEnvironment
  echo components
  echo dependencies
  echo dependencyInsight
  echo dependentComponents
  echo help
  echo init
  echo javaToolchains
  echo model
  echo outgoingVariants
  echo projects
  echo properties
  echo resolvableConfigurations
  echo tasks
  echo wrapper
elif [ $((10#$gradleVersionNumber)) -lt 81300 ]; then
  # < 8.13.0  (8.8+ adds updateDaemonJvm)
  echo buildEnvironment
  echo components
  echo dependencies
  echo dependencyInsight
  echo dependentComponents
  echo help
  echo init
  echo javaToolchains
  echo model
  echo outgoingVariants
  echo projects
  echo properties
  echo resolvableConfigurations
  echo tasks
  echo updateDaemonJvm
  echo wrapper
elif [ $((10#$gradleVersionNumber)) -lt 90000 ]; then
  # < 9.0.0  (8.13+ adds artifactTransforms)
  echo artifactTransforms
  echo buildEnvironment
  echo components
  echo dependencies
  echo dependencyInsight
  echo dependentComponents
  echo help
  echo init
  echo javaToolchains
  echo model
  echo outgoingVariants
  echo projects
  echo properties
  echo resolvableConfigurations
  echo tasks
  echo updateDaemonJvm
  echo wrapper
else
  # >= 9.0.0  (9.x task set from comment block)
  echo artifactTransforms
  echo buildEnvironment
  echo dependencies
  echo dependencyInsight
  echo help
  echo init
  echo javaToolchains
  echo outgoingVariants
  echo projects
  echo properties
  echo resolvableConfigurations
  echo tasks
  echo updateDaemonJvm
  echo wrapper
fi

"$script_dir/print-gradle-build-options.sh" "$project_dir" | sort -u