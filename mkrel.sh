#!/bin/bash

REPO_REMOTE=`git config --get remote.origin.url`
if [ -z $REPO_REMOTE ]; then
	echo "Not a git repository"
	exit 1
fi
REPO_NAME=$(basename -s .git $REPO_REMOTE)
REPO_OWNER="terual"

# Check if xmlstarlet is available
if ! command -v xmlstarlet &> /dev/null
then
    echo "xmlstarlet could not be found"
    exit 1
fi

# Get args
while getopts v:m: option
do
	case "${option}"
		in
		v) VERSION="$OPTARG";;
		m) MESSAGE="$OPTARG";;
	esac
done

if [ -z "$VERSION" ]
  then
	echo "Usage: mkrel.sh -v <version> [-m <message>]"
	exit 1
fi

# Set default message
if [ "$MESSAGE" == "" ]; then
	MESSAGE=$(printf "Release of version %s" $VERSION)
fi

# Name and URL of zipball
ZIPBALL="$REPO_NAME-$VERSION.zip"
URL="https://github.com/$REPO_OWNER/$REPO_NAME/releases/download/$VERSION/$ZIPBALL"

# First update version in install.xml
xmlstarlet ed --inplace --update "//extension/version" --value "$VERSION" install.xml

# Then zip plugin and update repo.xml
zip -r "$ZIPBALL" . -x ".git/*" ".github/*" ".gitignore" "repo.xml" "*.zip" "*.sh" &> /dev/null
SHA=`sha1sum "$ZIPBALL" | awk '{ print $1 }'`
xmlstarlet ed --inplace --update "//extensions/plugins/plugin/sha" --value "$SHA" repo.xml
xmlstarlet ed --inplace --update "//extensions/plugins/plugin/url" --value "$URL" repo.xml
xmlstarlet ed --inplace --update "//extensions/plugins/plugin/@version" --value "$VERSION" repo.xml

# Commit
git commit -a -m "$MESSAGE"
git push

echo "Now bump release to version $VERSION and upload $ZIPBALL"
