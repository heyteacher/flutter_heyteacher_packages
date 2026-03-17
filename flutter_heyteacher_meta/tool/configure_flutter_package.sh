#!/bin/bash
#
# Configure project with common Fastfile lanes and git hooks
#
# Creates a Fastfile wich imports the flutter_heyteacher_meta Fastfile lanes
# and configure ruby. 
#
# Configure git hooks to avoid commit on main branch and conventional commit 
# sintax check.
set -x
set -e

latest_meta_version=`ls $HOME/.pub-cache/hosted/pub.dev | grep flutter_heyteacher_meta |  tail -n 1`
project_meta_root="$HOME/.pub-cache/hosted/pub.dev/$latest_meta_version"

# configure git hooks
$project_meta_root/tool/configure_git_hooks.sh

# install flutter_heyteacher_meta as dev dependency
flutter pub add dev:flutter_heyteacher_meta

# configure ruby
cp $project_meta_root/Gemfile .
echo "3.4.3" > .ruby-version 
# configure fastlane importing lanes from flutter_heyteacher_meta
mkdir -p fastlane
cp -p $project_meta_root/fastlane/Fastfile.template fastlane/Fastfile
