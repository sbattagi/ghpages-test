#!/bin/sh
echo '=================== Install Hugo ==================='
DOWNLOAD_HUGO_VERSION=${HUGO_VERSION:-0.65.3}
GITHUB_DEPLOY_REPOSITORY=${GITHUB_REMOTE_REPOSITORY:-$GITHUB_REPOSITORY}
GITHUB_DEPLOY_BRANCH=${GITHUB_BRANCH:-"gh-pages"}
echo "Installing Hugo $DOWNLOAD_HUGO_VERSION"
wget -O /tmp/hugo.tar.gz https://github.com/gohugoio/hugo/releases/download/v${DOWNLOAD_HUGO_VERSION}/hugo_extended_${DOWNLOAD_HUGO_VERSION}_Linux-64bit.tar.gz &&\
tar -zxf /tmp/hugo.tar.gz -C /tmp &&\
mv /tmp/hugo /usr/local/bin/hugo &&\
rm /tmp/*
echo '=================== Create deploy key to push ==================='
mkdir /root/.ssh
ssh-keyscan -t rsa github.com > /root/.ssh/known_hosts && \
echo "${GIT_DEPLOY_KEY}" > /root/.ssh/id_rsa && \
chmod 400 /root/.ssh/id_rsa
echo '=================== Update all submodules ==================='
cd docs-source
git submodule init
git submodule update --recursive --remote
echo '=================== Build site ==================='
HUGO_ENV=production hugo -v --minify -d docs
echo '=================== Publish to GitHub Pages ==================='
cd docs
remote_repo="https://github.com/${GITHUB_DEPLOY_REPOSITORY}.git" && \
remote_branch=${GITHUB_DEPLOY_BRANCH} && \
echo "samba:GITHUB_REPOSITORY =$GITHUB_REPOSITORY" && \
echo "GITHUB_DEPLOY_REPOSITORY=$GITHUB_DEPLOY_REPOSITORY" && \
echo "Pushing Builds to $remote_repo:$remote_branch" && \
git init && \
git remote add deploy $remote_repo && \
echo "remote_repo=$remote_repo" && \
echo "GITHUB_DEPLOY_BRANCH=$GITHUB_DEPLOY_BRANCH" && \
echo "GITHUB_BRANCH=$GITHUB_BRANCH" && \
git status && \
git checkout $remote_branch || git checkout --orphan $remote_branch && \
git config user.name "${GITHUB_ACTOR}" && \
git config user.email "${GITHUB_ACTOR}@users.noreply.github.com" && \
echo "GITHUB_ACTOR=$GITHUB_ACTOR" && \
git add . && \
echo -n 'Files to Commit:' && ls -l | wc -l && \
timestamp=$(date +%s%3N) && \

git commit -m "Automated deployment to GitHub Pages on $timestamp" > /dev/null 2>&1 && \
git push deploy $remote_branch --force && \

rm -fr .git && \
cd ../
echo '=================== Done  ==================='

