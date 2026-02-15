#!/bin/bash
#
# Configure project with app and common Fastfile lanes.
#
# Create a Fastfile wich imports the flutter_heyteacher_meta Fastfile lanes
# for app and copy ruby environment files
set -x
set -e 
# configure standard flutter package
../flutter_heyteacher_meta/scripts/configure_flutter_package.sh
# add fastlane Pluginfile
cp ../flutter_heyteacher_meta/fastlane/Pluginfile.template fastlane/Pluginfile
# configure fastlane Pluginfile in Gembile
echo "" >> Gemfile
echo "eval_gemfile(\"fastlane/Pluginfile\")" >> Gemfile
# configure fastlane importing lanes from flutter_heyteacher_meta
cp -p ../flutter_heyteacher_meta/fastlane/AppFastfile.template fastlane/Fastfile
