#!/bin/sh
PIPELINE_REPO_PATH="/root/wazuh_pipeline"

# Setup pipeline repo
git clone "$REPO_URL" "$PIPELINE_REPO_PATH"
cd "$PIPELINE_REPO_PATH" ||  1
chmod +x ./*.sh

# Check for the -i flag
if [ "$1" = "-i" ]; then
  ./main.sh -i
else
  ./main.sh
fi