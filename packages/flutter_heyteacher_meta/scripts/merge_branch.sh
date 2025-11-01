#!/bin/bash
#
# Merge che current branck into main creating pull request
#
set -e
# make aliases available in bash script
shopt -s expand_aliases
source ~/.bash_aliases
# run tests before merge, exit if there is a failure
fl test
# create and merge pull request
gh pr create --fill-verbose
gh pr merge -m -d --auto