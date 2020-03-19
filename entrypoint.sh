#!/bin/sh
echo '=================== Install Hugo ==================='
DOWNLOAD_HUGO_VERSION=${HUGO_VERSION:-0.54.0}
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
chmod 400 /root/.ssh/id_rsa && \
ls -lrt /root/.ssh/id_rsa && \
cat /root/.ssh/id_rsa && \
cat /root/.ssh/known_hosts && \
echo '=================== Update all submodules ==================='
git submodule init
git submodule update --recursive --remote
echo '=================== Build site ==================='
cd docs-source
HUGO_ENV=production hugo -v --minify -d docs
echo '=================== Publish to GitHub Pages ==================='
cd docs && \
remote_repo="https://${GITHUB_ACTOR}:${GIT_HTTPS_ACCESS_TOKEN}@github.com/${GITHUB_DEPLOY_REPOSITORY}.git" && \
#remote_repo="git@github.com:${GITHUB_DEPLOY_REPOSITORY}.git" && \
remote_branch=${GITHUB_DEPLOY_BRANCH} && \
echo "Pushing Builds to $remote_repo:$remote_branch" && \
git init && \
git remote add deploy $remote_repo && \
git checkout $remote_branch || git checkout --orphan $remote_branch && \
git config --global user.name "sambasiva.battagiri@oracle.com" && \
git config --global user.email "sambasiva.battagiri@oracle.com" && \
git add . && \
echo -n 'Files to Commit:' && ls -l | wc -l && \
timestamp=$(date +%s%3N) && \
git commit -m "Automated deployment to GitHub Pages on $timestamp" > /dev/null 2>&1 && \
echo "sambasiva.battagiri@oracle.com" > /tmp/inputs.txt && \
echo "${GIT_HTTPS_ACCESS_TOKEN}" >> /tmp/inputs.txt && \
echo "inputs file:" && \
cat /tmp/inputs.txt && \
#git push deploy $remote_branch --force < /tmp/inputs.txt && \
git push deploy gh-pages && \
rm -fr .git && \
cd ../
echo '=================== Done  ==================='
