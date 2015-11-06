#!/usr/bin/env bash

set -e

if [[ "false" != "$TRAVIS_PULL_REQUEST" ]]; then
	echo "Not deploying pull requests."
	exit
fi

if [[ ! $WP_PULUGIN_DEPLOY ]]; then
	echo "Not deploying."
	exit
fi

echo "Starting deploy..."

mkdir build

cd build
svn co -q $SVN_REPO
git clone -q $GH_REF $(basename $SVN_REPO)/git

cd $(basename $SVN_REPO)
SVN_ROOT_DIR=$(pwd)

rsync -av --exclude=".svn" --checksum --delete $SVN_ROOT_DIR/git/ $SVN_ROOT_DIR/trunk/
rm -fr $SVN_ROOT_DIR/git

cd $SVN_ROOT_DIR/trunk

if [ -e "bin/build.sh" ]; then
	echo "Startng bin/build.sh."
	bash bin/build.sh
fi

if [ -e ".svnignore" ]; then
	svn propset -q -R svn:ignore -F .svnignore .
fi

cd $SVN_ROOT_DIR

svn st | grep '^!' | sed -e 's/\![ ]*/svn del -q /g' | sh
svn st | grep '^?' | sed -e 's/\?[ ]*/svn add -q /g' | sh

echo "Check statuses before commit."
svn st

if [[ $TRAVIS_TAG && $SVN_USER && $SVN_PASS ]]; then
	echo "Commit to $SVN_REPO."
	svn cp -q trunk tags/$TRAVIS_TAG
	svn commit -m "commit version $TRAVIS_TAG" --username $SVN_USER --password $SVN_PASS --non-interactive 2>/dev/null
else
	echo "Nothing to commit."
fi
