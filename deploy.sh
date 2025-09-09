#!/bin/bash
# ==============================================================================
#  Deploy Script for Quarto Course Website
#
#  This script syncs files from a manifest to a deployment directory,
#  cleans up extraneous files, and then renders the Quarto site.
# ==============================================================================

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
DEPLOY_DIR="./deploy-stage"
SRC_DIR="../book"
FILE_LIST="published-files.txt"


# 1. Verify that the file list exists before we start.
if [ ! -f "$FILE_LIST" ]; then
    echo "Error: The file list '$FILE_LIST' was not found."
    exit 1
fi

# 2. Ensure the deployment directory exists.
mkdir -p "$DEPLOY_DIR"

# 3. Sync files using rsync.
echo "Syncing published files to '$DEPLOY_DIR'..."
rsync -av --delete --files-from="$FILE_LIST" "$SRC_DIR" "$DEPLOY_DIR"

# 4. Render the Quarto site in the deployment directory.
echo "Rendering the Quarto site..."
cp ./_quarto.yml "$DEPLOY_DIR"
cd "$DEPLOY_DIR"
quarto render
cd .. # Return to the project root directory

SOURCE="$DEPLOY_DIR/_site"
TARGET="./docs"

echo "Syncing from $SOURCE to $TARGET ..."
rsync -av --delete "$SOURCE/" "$TARGET/"

minify -v -r -a -i "$TARGET"

# 2. Add changes to git
echo "Staging changes..."
git add "$TARGET"

# 3. Commit with timestamp
COMMIT_MSG="Deploy site on $(date '+%Y-%m-%d %H:%M:%S')"
echo "Committing with message: $COMMIT_MSG"
git commit -m "$COMMIT_MSG" || echo "No changes to commit."

# 4. Push to current branch
echo "Pushing to remote..."
git push origin master

echo "Deployment completed!"
