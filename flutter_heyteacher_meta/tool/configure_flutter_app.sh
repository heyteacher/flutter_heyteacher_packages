#!/bin/bash
#
# Configure project with app and common Fastfile lanes.
#
# Create a Fastfile wich imports the flutter_heyteacher_meta Fastfile lanes
# for app and copy ruby environment files
set -x
set -e 

latest_meta_version=`ls $HOME/.pub-cache/hosted/pub.dev | grep flutter_heyteacher_meta |  tail -n 1`
project_meta_root="$HOME/.pub-cache/hosted/pub.dev/$latest_meta_version"

# configure standard flutter package
$project_meta_root/tool/configure_flutter_package.sh
# add fastlane Pluginfile
cp  $project_meta_root/fastlane/Pluginfile.template fastlane/Pluginfile
# configure fastlane Pluginfile in Gembile
echo "" >> Gemfile
echo "eval_gemfile(\"fastlane/Pluginfile\")" >> Gemfile
# configure fastlane importing lanes from flutter_heyteacher_meta
cp $project_meta_root/fastlane/AppFastfile.template fastlane/Fastfile
# copy fastlane/metadata directory adding missing file without replace existing
cp -R --update=none $project_meta_root/fastlane/metadata  fastlane/
