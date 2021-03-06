#!/bin/sh

echo "[INFO] - Entrypoint has started";

# Should we go up a dir before exiting?
die(){
	if [ -n "$JEKYLL_ROOT" ]; then
		cd ../
	fi
}

# Where should we try to do all of this?
if [ -z "$JEKYLL_ROOT" ]; then
  echo "[INFO] - JEKYLL_ROOT is not set. Going to try and build the root dir."
else
	if [ ! -d "${JEKYLL_ROOT}" ]; then
		echo "[ERROR] - ${JEKYLL_ROOT} not found, exiting!"
		exit 1;
	fi

  	cd "${JEKYLL_ROOT}";

fi

# Whats the gemfile called?
if [ -z "$GEMFILE" ]; then
	echo "[INFO] - Gemfile not defined; defaulting to GemFile";
	GEMFILE="Gemfile";
fi
if [ ! -f "$GEMFILE" ]; then
	echo "[ERROR] - ${GEMFILE} not found - exiting";
	die
	exit 1
fi


# Should we delete the gemlock when building?
if [ -n "$REMOVE_GEMLOCK" ] && [ "$REMOVE_GEMLOCK" = true ]; then
	echo "[INFO] - Removing Gemlock."
	rm Gemfile.lock > /dev/null 2>&1
fi

# Should we deploy the site?
if [ -z "$DEPLOY_SITE" ]; then	
	echo "[INFO] - DEPLOY_SITE is not set.  Defaulting to 'true'";
	DEPLOY_SITE=true
fi

# Set options if we're going to try and deploy the site.

if [ "$DEPLOY_SITE" = true ]; then

	# Where is the site going to get built into?
	if [ -z "$BUILD_DIR" ]; then
	  echo "[INFO] - BUILD_DIR is not set. Assuming the site is building to _site/"
	  BUILD_DIR="_site/";
	fi

	# What branch do we want to push the build dir to?
	if [ -z "$REMOTE_BRANCH" ]; then
	  echo "[INFO] - REMOTE_BRANCH is not set. Assuming we want to push the built site into gh-pages"
	  REMOTE_BRANCH="gh-pages";
	fi
fi

echo '[INFO] - Installing Gem Bundle'
gem install bundler -v 2.0.2
bundle update --bundler
bundle install

echo -n '[INFO] - Jekyll Version: '
bundle list | grep "jekyll ("

if [ -n "$DELETE_BEFORE_BUILD" ]; then
	echo -n "[INFO] - Deleting ${DELETE_BEFORE_BUILD}"
	rm -rf ${DELETE_BEFORE_BUILD};
fi


echo '[INFO] - Installing npm modules'
npm install


echo '[INFO] - Building with Gulp.js'
#bundle exec jekyll build
gulp

if [ "$DEPLOY_SITE" = true ]; then	
	
	echo "[INFO] - Pushing the contents of ${BUILD_DIR} to ${REMOTE_BRANCH}"
	
	if [ ! -d "${BUILD_DIR}" ]; then
		echo "[ERROR] - ${BUILD_DIR} Not Found, Exiting"
		die
		exit 1
	fi
	
	cd "${BUILD_DIR}"
	
	touch .nojekyll
	
	remote_repo="https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git" && \
	remote_branch="${REMOTE_BRANCH}" && \
	
	git init && \
	git config user.name "${GITHUB_ACTOR}" && \
	git config user.email "${GITHUB_ACTOR}@users.noreply.github.com" && \
	git add . && \
	
	echo -n '[INFO] - Files to Commit:' && ls -l | wc -l && \
	
	git commit -m'Automated Build' > /dev/null 2>&1 && \
	git push --force $remote_repo master:$remote_branch > /dev/null 2>&1 && \
	
	rm -rf .git && \
	
	cd -
fi

echo '[INFO] - EntryPoint has finished.'
die
exit

