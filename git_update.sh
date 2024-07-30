#!/bin/sh

# ====( IMPORTS )==== #
# shellcheck disable=SC1091
. "$PIPELINE_REPO_PATH/utils.sh"

# =====( MAIN )===== #
cd "$PIPELINE_REPO_PATH" ||  1

# Check that we received the branch name
if [ -n "$BRANCH_NAME" ]; then
    log_message "$INFO_LVL" "Updating branch: $BRANCH_NAME"
else
    log_message "$ERR_LVL" "No branch set. Exiting..."
    exit "$EXIT_ERR"
fi

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
if [ -z "$REMOTE_REPO_URL" ]; then
    log_message "$ERR_LVL" "Failed to get the remote repository URL."
    exit "$EXIT_ERR"
fi

# Update the remote repository URL to include the TOKEN if present
if [ -n "$TOKEN" ]; then
    REPO_URL_WITH_TOKEN="https://${TOKEN}@${REMOTE_REPO_URL#https://}"
    git remote set-url origin "$REPO_URL_WITH_TOKEN"
    log_message "$INFO_LVL" "Updated remote URL to use the provided token."
fi

# Fetch the latest changes
run_command "git pull" "Failed to pull updates from remote: $REMOTE_REPO_URL"

# Checkout the branch
run_command "git checkout $BRANCH_NAME" "Failed to checkout branch: $BRANCH_NAME"

# Pull the latest changes for the branch
OUTPUT=$(git pull origin "$BRANCH_NAME" 2>&1)
STATUS=$?

# Check if git pull failed
if [ $STATUS -ne 0 ]; then
    log_message "$ERR_LVL" "Git pull failed for branch: $BRANCH_NAME, remote: $REMOTE_REPO_URL"
    exit "$EXIT_ERR"
fi

if echo "$OUTPUT" | grep -q "Already up to date."; then
    log_message "$INFO_LVL" "No updates were made to branch: $BRANCH_NAME."
else
    log_message "$INFO_LVL" "Branch $BRANCH_NAME was updated."
fi

exit "$EXIT_SUCCESS"
