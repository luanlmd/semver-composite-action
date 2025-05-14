#!/bin/bash

git log -1 --pretty=%s
# git fetch --tags
# git fetch --all
git log --merges --first-parent -n 1 --pretty=%s | cut -d'/' -f2

# Function to validate and parse current version
parse_version() {
    local version=$1
    # Remove 'v' prefix if present
    version=${version#v}
    if [[ $version =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
        major=${BASH_REMATCH[1]}
        minor=${BASH_REMATCH[2]}
        patch=${BASH_REMATCH[3]}
        return 0
    else
        echo "Error: Invalid version format. Expected vX.Y.Z or X.Y.Z, got $version"
        exit 1
    fi
}

# Function to get current version from git tags
get_current_version() {
    # Get the latest tag that looks like a SemVer with optional 'v' prefix
    local latest_tag=$(git tag --sort=-v:refname --list "v*.*.*" | head -n 1)
    if [ -z "$latest_tag" ]; then
        echo "No valid SemVer tags found. Using v0.0.0 as default."
        echo "v0.0.0"
    else
        echo "$latest_tag"
    fi
}

# Main script
# Get current branch name
branch_name=$(git log --merges --first-parent -n 1 --pretty=%s | cut -d'/' -f2)

# Get current version
current_version=$(get_current_version)
parse_version "$current_version"

# Determine version update based on branch name
if [[ $branch_name =~ ^(release|feature)-.* ]]; then
    # Minor update for release and feature branches
    new_version="$major.$((minor + 1)).0"
elif [[ $branch_name =~ ^hotfix-.* ]]; then
    # Patch update for hotfix branches
    new_version="$major.$minor.$((patch + 1))"
else
    echo "Error: Branch name '$branch_name' does not match release-*, feature-*, or hotfix-* patterns"
    exit 1
fi

# Add 'v' prefix to new version
new_version="v$new_version"

echo "Current version: $current_version"
echo "New version: $new_version"

echo "version=$new_version" > version.txt

exit 0