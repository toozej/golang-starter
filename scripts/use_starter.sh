#!/usr/bin/env bash
set -Eeuo pipefail

OLD_PROJECT_NAME="golang-starter"
NEW_PROJECT_NAME="${1}"
GITHUB_USERNAME="${2:-toozej}"

GIT_REPO_ROOT=$(git rev-parse --show-toplevel)
cd "${GIT_REPO_ROOT}"

# update go module name
# shellcheck disable=SC2086
go mod edit -module=github.com/${GITHUB_USERNAME}/${NEW_PROJECT_NAME}

# move directories
mv "cmd/${OLD_PROJECT_NAME}" "cmd/${NEW_PROJECT_NAME}"

# rename from $OLD_PROJECT_NAME to $NEW_PROJECT_NAME
grep -rl --exclude-dir=.git/ ${OLD_PROJECT_NAME} . | xargs sed -i "" -e "s/${OLD_PROJECT_NAME}/${NEW_PROJECT_NAME}/g"

# show diff output so user can verify their changes
git diff
