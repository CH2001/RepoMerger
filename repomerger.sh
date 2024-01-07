#!/bin/bash
#This shell script that consolidate repo(s) into a single repository. 
#To utilize: 
# 1. chmod +x repomerger.sh  
# 2. Specify links in repositories.txt
# 3. ./repomerger.sh 

# Read repository URLs from repositories.txt
mapfile -t REPOS < repositories.txt

# Loop through repository URLs and create feature branches 
for REPO_URL in "${REPOS[@]}"; do
  REPO_NAME=$(basename "$REPO_URL" .git)
  TARGET_FOLDER="${REPO_NAME}"
  FEATURE_BRANCH="merge-${REPO_NAME}-feature"

  # Add remote
  git remote add "$REPO_NAME" "$REPO_URL"
  git fetch "$REPO_NAME" --tags

  git branch -d "$FEATURE_BRANCH" 2>/dev/null || true

  git checkout -b "$FEATURE_BRANCH"
  git read-tree --prefix="$TARGET_FOLDER/" -u "$REPO_NAME"/main
  git commit -m "Feature branch for $REPO_NAME/main into $TARGET_FOLDER folder"
  git checkout main
done

git checkout main

# Merge feature branches in a loop with messages
for REPO_URL in "${REPOS[@]}"; do
  REPO_NAME=$(basename "$REPO_URL" .git)
  BRANCH_NAME="merge-$REPO_NAME-feature"

  git merge --no-ff "$BRANCH_NAME" -m "Merging feature branch for $REPO_NAME"
done

# Push the changes to the main branch on the remote repository
git push -u origin main
