#!/bin/bash

git fetch -a

echo "Loading current tag"
CURRENT_TAG=`git describe --exact-match --tags HEAD 2> /dev/null`

echo "Loading last tag"
LAST_TAG=`git tag --sort=version:refname --list "v*.*.*" | tail -1`
TAG=$LAST_TAG

echo "Current Tag: [$CURRENT_TAG]"
echo "Last Tag: [$LAST_TAG]"

if [[ -z "$CURRENT_TAG" ]]; then
  CURRENT_RELEASE=`git log --merges -n 1 | grep -o "release-.*"`
  MERGED_RELEASE=`git log --merges -n 1 | grep -o "release-.*" | cut -f2 -d"-"`

  if [[ "$MERGED_RELEASE" =~ ^[0-9]+\.[0-9]+\.0$ ]]; then
    echo "New release found"
    TAG="v$MERGED_RELEASE"
  elif [[ "$CURRENT_RELEASE" =~ ^release.* ]]; then
    echo "New release without number found"
    TAG=`echo $LAST_TAG | cut -d. -f1,2 | awk -F. -v OFS=. '{$NF += 1 ; print $1"."$2".0"}'`
  else
    echo "Bumping patch version: $LAST_TAG"
    TAG=`echo $LAST_TAG | awk -F. -v OFS=. '{$NF += 1 ; print}'`
  fi;

  if [[ "$TAG" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "New generated tag: $TAG"
    git tag $TAG
    git push --tags
  fi;
else
  TAG=$CURRENT_TAG
fi;

echo "version=$TAG" >> $GITHUB_OUTPUT