#!/bin/bash
#This shell script contains merge_repositories function that helps to consolidate repo(s) into a single repository. 
#To utilize: 
# 1. chmod +x repomerger_function.sh 
# 2. source repomerger_function
# 3. merge_repositories link1 link2 ...

merge_repositories() {
  # Loop through repository URLs and create feature branches 
  for REPO_URL in "$@"; do
    REPO_NAME=$(basename "$REPO_URL" .git)
    TARGET_FOLDER="${REPO_NAME}"
    FEATURE_BRANCH="merge-${REPO_NAME}-feature"

    git remote add "$REPO_NAME" "$REPO_URL"
    git fetch "$REPO_NAME" --tags

    git branch -d "$FEATURE_BRANCH" 2>/dev/null || true

    git checkout -b "$FEATURE_BRANCH" # Merge the remote repository's main branch into the target folder
    git read-tree --prefix="$TARGET_FOLDER/" -u "$REPO_NAME"/main
    git commit -m "Feature branch for $REPO_NAME/main into $TARGET_FOLDER folder"
    git checkout main
  done

  git checkout main

  # Merge all feature branches created with message 
  for REPO_URL in "$@"; do
    REPO_NAME=$(basename "$REPO_URL" .git)
    BRANCH_NAME="merge-$REPO_NAME-feature"
    git merge --no-ff "$BRANCH_NAME" -m "Merging feature branch for $REPO_NAME"
  done

  # Push the changes to the main branch on the remote repository
  git push -u origin main
}