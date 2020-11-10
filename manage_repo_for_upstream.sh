#!/bin/sh

set -e

SRC_REPO=$1
SRC_BRANCH=$2
DEST_BRANCH=$3
WORKFLOW_BRANCH=$4
BASEDIR=$(pwd)

if ! echo $SRC_REPO | grep '\.git'
then
  SRC_REPO="https://github.com/$SRC_REPO.git"
fi

echo "SRC_REPO=$SRC_REPO"
echo "SRC_BRANCH=$SRC_BRANCH"
echo "DEST_BRANCH=$DEST_BRANCH"
echo "WORKFLOW_BRANCH=$WORKFLOW_BRANCH"
echo "GITHUB_ACTOR=$GITHUB_ACTOR"
echo "BASEDIR=$BASEDIR"

git config user.name "$GITHUB_ACTOR"
git config user.email "$GITHUB_ACTOR@users.noreply.github.com"

echo ">> Set local master branch"
git checkout -b master origin/master

echo ">> Set current branch to workflow"
git checkout workflow

echo ">> Add upstream repo"
git remote set-url origin "https://$GITHUB_ACTOR:$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY"
git remote add upstream "$SRC_REPO"
git fetch upstream
git remote -v

echo ">> Get branch reference"
upstream_master_sha=$(git show-ref -s upstream/master)
origin_master_sha=$(git show-ref -s origin/master)
echo "upstream/master: $upstream_master_sha"
echo "origin/master: $origin_master_sha"

echo ">> Sync the repo upstream/for-upstream -> origin/for-upstream"
git push origin "refs/remotes/upstream/for-upstream:refs/heads/for-upstream" -f

echo ">> Sync the repo upstream/master -> origin/master"
git push origin "refs/remotes/upstream/master:refs/heads/master" -f

echo ">> Sync tags"
git push origin "refs/tags/*" -f

echo ">> Update origin"
git fetch origin

echo ">> Set new workflow branch from origin/master"
git checkout -b new_workflow origin/master

echo ">> Commit lists from master to workflow"
git rev-list --reverse master..workflow

echo ">> cherry-pick commits to new_workflow branch"
git rev-list --reverse master..workflow | while read rev
do
  git cherry-pick $rev || break
done

echo ">> Sync new_workflow -> origin/workflow"
git push origin "new_workflow:workflow" -f

echo ">> Rebase workflow done"

