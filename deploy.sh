#!/bin/bash
set -e

SOURCE="/Users/yunchih/Documents/GitHub/teaching/os-course-book/_site"
TARGET="./docs"

# 1. Sync content
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
