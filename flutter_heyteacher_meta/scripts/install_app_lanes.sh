#!/bin/bash
#
# Configure project with app and common Fastfile lanes.
#
# Create a Fastfile wich imports the flutter_heyteacher_fastlane Fastfile lanes
# for app and copy ruby environment files
set -e 
# configure ruby
cp ../flutter_heyteacher_fastlane/Gemfile .
cp ../flutter_heyteacher_fastlane/.ruby-version .
# configure fastlane importing lanes from flutter_heyteacher_fastlane
mkdir fastlane
cp ../flutter_heyteacher_fastlane/fastlane/Pluginfile fastlane/
echo "" >> Gemfile
echo "eval_gemfile(\"fastlane/Pluginfile\")" >> Gemfile
echo "import(\"../../flutter_heyteacher_fastlane/fastlane/Fastfile\")" > fastlane/Fastfile
echo "" >> fastlane/Fastfile
echo "# set the Google Cloud Storage bucket name" >> fastlane/Fastfile
echo "#ENV[\"google_storage_backup_bucket\"] = \"gs://...\"" >> fastlane/Fastfile
echo "" >> fastlane/Fastfile
echo "# set the Firebase App Distribution service credentials file name" >> fastlane/Fastfile
echo "#ENV[\"firebase_app_distribution_service_credentials_file\"] = \"#{ENV[\"HOME\"]}/.flutter/...\"" >> fastlane/Fastfile
echo "" >> fastlane/Fastfile
echo "import(\"../../flutter_heyteacher_fastlane/fastlane/AppFastfile\")" >> fastlane/Fastfile