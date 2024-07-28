#!/bin/sh
PIPELINE_REPO_PATH="/root/wazuh_pipeline"

# Setup pipeline repo
if [ -n "$GITHUB_TOKEN" ]; then
  REPO_URL_WITH_TOKEN="https://${GITHUB_TOKEN}@${REPO_URL#https://}"
  git clone "$REPO_URL_WITH_TOKEN" "$PIPELINE_REPO_PATH"
else
  git clone "$REPO_URL" "$PIPELINE_REPO_PATH"
fi

cd "$PIPELINE_REPO_PATH" || exit 1
chmod +x ./*.sh

# Check for the -i flag
if [ "$1" = "-i" ]; then
  ./main.sh -i
else
  ./main.sh
fi
