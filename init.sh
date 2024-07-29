#!/bin/sh

# Define the pipeline repository path
PIPELINE_REPO_PATH="/root/wazuh_pipeline"

# Check if TOKEN is provided
if [ -n "$TOKEN" ]; then
  REPO_URL_WITH_TOKEN="https://${TOKEN}@${REPO_URL#https://}"
  echo "Cloning repository with token"
  git clone "$REPO_URL_WITH_TOKEN" "$PIPELINE_REPO_PATH"
else
  echo "Cloning repository without token"
  git clone "$REPO_URL" "$PIPELINE_REPO_PATH"
fi

# Navigate to the cloned repository directory
cd "$PIPELINE_REPO_PATH" || exit 1

# Ensure all shell scripts are executable
chmod +x ./*.sh

# Run the main script with the provided flag
if [ "$1" = "-i" ]; then
  ./main.sh -i
else
  ./main.sh
fi
