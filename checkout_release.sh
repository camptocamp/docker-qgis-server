#!/bin/bash

if [ "$#" -ne 1 ]
then
  echo "Usage: checkout_release.sh {BRANCH}"
  echo
  echo "Checkout the last tag matching final-* of the given branch"
  exit 1
fi

BRANCH=$1

cd src
git fetch --tags
git checkout --detach origin/$BRANCH
LAST_RELEASE=`git log --format=%H --tags=final-* --no-walk | head -1`
git checkout --detach $LAST_RELEASE

echo
echo "Will build: -----------------------------------------"
git log -n 1 --decorate
echo "-----------------------------------------------------"
echo
