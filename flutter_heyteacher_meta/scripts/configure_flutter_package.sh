#!/bin/bash
#
# Configure project with common Fastfile lanes and git hooks
#
# Creates a Fastfile wich imports the flutter_heyteacher_fastlane Fastfile lanes
# and configure ruby. 
#
# Configure git hooks to avoid commit on main branch and conventional commit 
# sintax check.
set -x
set -e
# configure ruby
cp ../flutter_heyteacher_fastlane/Gemfile .
cp ../flutter_heyteacher_fastlane/.ruby-version .
# configure fastlane importing lanes from flutter_heyteacher_fastlane
cp -p ../flutter_heyteacher_fastlane/fastlane/Fastfile.template fastlane/Fastfile
# configure git hooks
cd .git/hooks
# avoid commit on main branch
ln -s -f -i ../../../flutter_heyteacher_fastlane/git-hooks/pre-commit
# conventional commit sintax check
ln -s -f -i ../../../flutter_heyteacher_fastlane/git-hooks/commit-msg 
cd -