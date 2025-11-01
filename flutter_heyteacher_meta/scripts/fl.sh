if [[ -z ${@} ]] 
then
    bundle exec fastlane lanes
else
    bundle exec fastlane $@
fi