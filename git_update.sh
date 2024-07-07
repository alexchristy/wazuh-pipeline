#!/bin/sh

# ====( IMPORTS )==== #
# shellcheck disable=SC1091
. "$PIPELINE_REPO_PATH/utils.sh"

# =====( MAIN )===== #

# Check that the PIPELINE_REPO_PATH exists
if [ ! -d "$PIPELINE_REPO_PATH" ]; then
    log_message "$ERR_LVL" "The pipeline repo path does not exist! Path: $PIPELINE_REPO_PATH"
    exit "$EXIT_ERR"
fi

run_command "cd $PIPELINE_REPO_PATH" "Failed to change to directory: $PIPELINE_REPO_PATH"

# Check if the directory is a git repository
if [ ! -d ".git" ]; then
    log_message "$ERR_LVL" "The pipeline repo path is not a git repository. Searched at: $PIPELINE_REPO_PATH/.git"
    exit "$EXIT_ERR"
fi

# Get the remote repository URL
REMOTE_REPO_URL=$(git config --get remote.origin.url)
pwd
cat ".git/config"
echo "$REMOTE_REPO_URL"
if [ -z "$REMOTE_URL" ]; then
    log_message "$ERR_LVL" "Failed to get the remote repository URL."
    exit "$EXIT_ERR"
fi

# Git pull
OUTPUT=$(git pull 2>&1)
STATUS=$?

# Check if git pull failed
if [ $STATUS -ne 0 ]; then
    log_message "$ERR_LVL" "Git pull failed for remote: $REMOTE_REPO_URL"
    exit "$EXIT_ERR"
fi

if echo "$OUTPUT" | grep -q "Already up to date."; then
    log_message "$INFO_LVL" "No updates were made."
else
    log_message "$INFO_LVL" "Pipeline repo was updated."
fi

exit "$EXIT_SUCCESS"