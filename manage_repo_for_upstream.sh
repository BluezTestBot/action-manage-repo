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

echo ">> Update remote repo"
git remote set-url origin "https://$GITHUB_ACTOR:$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY"
git remote add upstream "$SRC_REPO"
git fetch upstream
git remote -v

echo ">> Get branch reference"
upstream_master_sha=$(git show-ref -s upstream/master)
origin_master_sha=$(git show-ref -s origin/master)
echo "upstream/master: $upstream_master_sha"
echo "origin/master: $origin_master_sha"

if [ "$upstream_master_sha" = "$origin_master_sha" ]; then
  echo ">> There is no new change in upstream repo. Complete sync and exit"
  exit 0
fi

echo ">> There is a change in upstream repo. Start to sync the repo"

#git push origin "refs/remotes/upstream/for-upstream:refs/heads/for-upstream" -f
#git push origin "refs/remotes/upstream/master:refs/heads/master" -f

echo ">> Merge for-upstream branch"
git checkout -b for-upstream origin/for-upstream
git merge upstream/for-upstream
git push --force origin for-upstream

echo ">> Merge master branch"
git checkout -b master origin/master
git branch -c master old-master
git branch -M workflow old-workflow
git merge upstream/master
git push --force origin master

git remote rm upstream
git remote -v
echo ">> Sync done"

echo ">> Rebase workflow branch to master"
echo ">> commit lists old-master..old-workflow"
git rev-list --reverse old-master..old-workflow

git checkout -b master
git checkout -b workflow

echo ">> cherry-pick commits to workflow branch"
git rev-list --reverse old-master..old-workflow | while read rev
do
  git cherry-pick $rev || break
done

git push --force origin workflow

echo ">> Rebase workflow done"

