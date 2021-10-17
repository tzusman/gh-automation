#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

out () {
  echo -e "$1${NC}"
}

slug () {
  echo $1 | sed -e "s/[^a-zA-Z0-9]\{1,\}/-/g" | sed -e "s/-\{1,\}$//g" | sed -e "s/^-\{1,\}//g" | tr A-Z a-z
}

export PAGER=""

if [[ $# != 1 ]]; then
  out "${BLUE}Usage: ./create-issue-branch.sh [issue number]"
  exit 1
fi

ISSUE_NUMBER=$1
if [[ $ISSUE_NUMBER =~ [^0-9] ]]; then
  out "${BLUE}Usage: ./create-issue-branch.sh [issue number]"
  exit 1
fi

CHANGES_PENDING=`git diff-index --quiet HEAD --; echo $?`
if [[ $CHANGES_PENDING -ne 0 ]]; then
  out "${BLUE}You must commit any changes before checking out an issue branch"
  exit 1
fi

out "• Issue number: ${GREEN}$ISSUE_NUMBER"

TITLE=$(gh issue view $ISSUE_NUMBER --json "title" --jq '.title')
out "• Title: ${GREEN}$TITLE"
TITLE_SLUG=$(slug "$TITLE")

PREFIX="feature"
BUG_TAG=$(gh issue view $ISSUE_NUMBER --json "labels" --jq '.labels.[].name | select( . == "bug" )')
if [[ $BUG_TAG == "bug" ]]; then
  PREFIX="bug"
fi

ISSUE_BRANCH="$PREFIX/${ISSUE_NUMBER}-${TITLE_SLUG}"
out "• Issue branch: ${GREEN}$ISSUE_BRANCH"

git checkout develop
git pull origin develop
git checkout -b $ISSUE_BRANCH
git branch --set-upstream-to origin/$ISSUE_BRANCH &> /dev/null

echo

out "• ${GREEN}Success"
