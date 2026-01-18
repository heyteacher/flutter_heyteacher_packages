#!/bin/bash
#
# Configure projecte with common Fastfile lanes.
#
# Create a Fastfile wich imports the flutter_heyteacher_fastlane Fastfile lanes
# and configure ruby 
#
set -e
# configure ruby
cp ../flutter_heyteacher_fastlane/Gemfile .
cp ../flutter_heyteacher_fastlane/.ruby-version .
# configure fastlane importing lanes from flutter_heyteacher_fastlane
mkdir fastlane
touch fastlane/Pluginfile
echo "import(\"../../flutter_heyteacher_fastlane/fastlane/Fastfile\")" > fastlane/Fastfile