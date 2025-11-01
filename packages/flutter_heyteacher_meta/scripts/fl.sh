#!/bin/bash
#
# Run FastLane Lanes.
#
# Executed without paramenter show lanes available and documentation 
if [[ -z ${@} ]] 
then
    # show lanes avalilable and documentation
    bundle exec fastlane lanes
else
    # run lane 
    bundle exec fastlane $@
fi