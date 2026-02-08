#!/bin/bash
#
# Configure project with app and common Fastfile lanes.
#
# Create a Fastfile wich imports the flutter_heyteacher_fastlane Fastfile lanes
# for app and copy ruby environment files
set -x
set -e 
# configure standard flutter package
../flutter_heyteacher_fastlane/scripts/configure_flutter_package.sh
# configure fastlane Pluginfile
cp ../flutter_heyteacher_fastlane/fastlane/Pluginfile fastlane/
echo "" >> Gemfile
echo "eval_gemfile(\"fastlane/Pluginfile\")" >> Gemfile
# configure fastlane importing lanes from flutter_heyteacher_fastlane
cp -p ../flutter_heyteacher_fastlane/fastlane/AppFastfile.template fastlane/Fastfile
