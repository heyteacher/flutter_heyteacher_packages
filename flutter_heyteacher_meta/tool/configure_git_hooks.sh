#!/bin/bash
#
# Configure git hooks to avoid commit on main branch and conventional commit 
# sintax check.
set -x
set -e

latest_meta_version=`ls $HOME/.pub-cache/hosted/pub.dev | grep flutter_heyteacher_meta |  tail -n 1`
project_meta_root="$HOME/.pub-cache/hosted/pub.dev/$latest_meta_version"

# configure git hooks
mkdir -p .git/hooks
cd .git/hooks
# avoid commit on main branch
ln -s -f -i $project_meta_root/git-hooks/pre-commit
# conventional commit sintax check
ln -s -f -i $project_meta_root/git-hooks/commit-msg 
cd -