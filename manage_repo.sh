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

git config --global --add safe.directory $BASEDIR

git config --global user.name "$GITHUB_ACTOR"
git config --global user.email "$GITHUB_ACTOR@users.noreply.github.com"

echo ">> Sync repo with upstream repo"
git remote set-url origin "https://$GITHUB_ACTOR:$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY"
git remote add upstream "$SRC_REPO"
git fetch upstream
git remote -v
git push origin "refs/remotes/upstream/$SRC_BRANCH:refs/heads/$DEST_BRANCH" -f
git push origin "refs/tags/*" -f
git remote rm upstream
git remote -v
echo "<< Sync done"

echo ">> Rebase workflow branch to master"
git checkout -b $DEST_BRANCH origin/$DEST_BRANCH
git checkout $WORKFLOW_BRANCH
git rebase $DEST_BRANCH
git push -f origin $WORKFLOW_BRANCH
echo "<< Rebase done"
