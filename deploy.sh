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

GH_REF=https://github.com/${TRAVIS_REPO_SLUG}.git

echo "Starting deploy..."

mkdir build

cd build
BASE_DIR=$(pwd)

echo "Checking out from $SVN_REPO ..."
svn co -q $SVN_REPO

echo "Getting clone from $GH_REF to $SVN_REPO ..."
git clone -q $GH_REF $(basename $SVN_REPO)/git

cd $(basename $SVN_REPO)/git

if [ -e "bin/build.sh" ]; then
	echo "Starting bin/build.sh."
	bash bin/build.sh
fi

cd $BASE_DIR/$(basename $SVN_REPO)
SVN_ROOT_DIR=$(pwd)

echo "Syncing git repository to svn"
rsync -av --exclude=".svn" --checksum --delete $SVN_ROOT_DIR/git/ $SVN_ROOT_DIR/trunk/
rm -fr $SVN_ROOT_DIR/git

cd $SVN_ROOT_DIR/trunk

if [ -e ".distignore" ]; then
	echo "svn propset form .distignore"
	svn propset -q -R svn:ignore -F .distignore .

else
	if [ -e ".svnignore" ]; then
		echo "svn propset"
		svn propset -q -R svn:ignore -F .svnignore .
	fi
fi

cd $SVN_ROOT_DIR

echo "Run svn add"
svn st | grep '^!' | sed -e 's/\![ ]*/svn del -q /g' | sh
echo "Run svn del"
svn st | grep '^?' | sed -e 's/\?[ ]*/svn add -q /g' | sh

if [[ $TRAVIS_TAG && $SVN_USER && $SVN_PASS ]]; then
	if [[ ! -d tags/$TRAVIS_TAG ]]; then
		echo "Commit to $SVN_REPO."
		svn cp -q trunk tags/$TRAVIS_TAG
		svn commit -m "commit version $TRAVIS_TAG" --username $SVN_USER --password $SVN_PASS --non-interactive 2>/dev/null
	else
		echo "tags/$TRAVIS_TAG already exists."
	fi
else
	echo "Nothing to commit and check \`svn st\`."
	svn st
fi
