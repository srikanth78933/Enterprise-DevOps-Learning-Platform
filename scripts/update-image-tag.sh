#!/usr/bin/env bash
# Bumps a service's image tag in its GitOps values file and pushes the
# commit - this is what actually replaces `helm upgrade` in this project.
# Called by both backend/Jenkinsfile and frontend/Jenkinsfile (never
# hand-run against files it doesn't own).
#
# Usage: ./scripts/update-image-tag.sh <backend|frontend> <new-tag>
set -euo pipefail

SERVICE="${1:?Usage: update-image-tag.sh <backend|frontend> <new-tag>}"
TAG="${2:?Usage: update-image-tag.sh <backend|frontend> <new-tag>}"

if [ "${SERVICE}" != "backend" ] && [ "${SERVICE}" != "frontend" ]; then
  echo "ERROR: service must be 'backend' or 'frontend', got '${SERVICE}'" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VALUES_FILE="${ROOT_DIR}/helm/enterprise-app/values-images/${SERVICE}.yaml"

git config user.name "${GIT_COMMIT_USER:-jenkins-gitops-bot}"
git config user.email "${GIT_COMMIT_EMAIL:-jenkins-gitops-bot@enterprise-devops.local}"

# Jenkins' `checkout scm` step frequently leaves the workspace in detached
# HEAD state (it checks out a specific commit, not a branch ref) - pushing
# from there has nothing to push *to*. Require an explicit branch name
# rather than guessing, so this fails loudly instead of silently no-op'ing.
BRANCH="${GIT_BRANCH_NAME:?Set GIT_BRANCH_NAME to the branch to commit/push to (e.g. project-04-gitops-argocd)}"
CURRENT_REF="$(git rev-parse --abbrev-ref HEAD)"
if [ "${CURRENT_REF}" = "HEAD" ]; then
  git checkout -B "${BRANCH}" "origin/${BRANCH}"
fi

# Precise single-line replace - values-images/*.yaml is intentionally kept
# to exactly this two-key shape so a plain sed substitution is reliable
# without needing a YAML-aware tool (yq) on every Jenkins agent.
sed -i "s/tag: .*/tag: \"${TAG}\"/" "${VALUES_FILE}"

git add "${VALUES_FILE}"

if git diff --cached --quiet; then
  echo "No change to commit (tag already ${TAG})."
  exit 0
fi

# [skip ci] convention, and the Jenkins webhook trigger for this branch
# should be path-filtered to backend/** and frontend/** only (see
# jenkins/README.md) - this commit touches neither, so it won't re-trigger
# either pipeline even without [skip ci], but the marker documents intent
# for any other tooling watching this repo.
git commit -m "chore(gitops): bump ${SERVICE} image tag to ${TAG} [skip ci]"

# Retry on push rejection (another commit landed on the branch meanwhile)
# rather than fail outright - rebase and retry a few times before giving up.
for attempt in 1 2 3; do
  if git push origin "HEAD:${BRANCH}"; then
    echo "Pushed ${SERVICE} tag ${TAG}."
    exit 0
  fi
  echo "Push rejected (attempt ${attempt}/3), rebasing and retrying..."
  git pull --rebase origin "${BRANCH}"
done

echo "ERROR: failed to push after 3 attempts." >&2
exit 1
