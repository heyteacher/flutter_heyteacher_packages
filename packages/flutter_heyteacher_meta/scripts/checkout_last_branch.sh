#!/bin/bash
#
# Fetch, checkout and pull the last branch created into repository
#  
set -e
# fetch repository getting output in gitFetch
gitFetch=$(git fetch 2>&1)
# extract last line of gitFetch into gitFetchLastLine
gitFetchLastLine=$(echo "$gitFetch" | tail -n -1) 
# get the branch name from gitFetchLastLine with awk
branch="$(echo "$gitFetchLastLine"  | awk -F' ' '{print $4}' <${1:-/dev/stdin} )"
# checkout branch then pull
git checkout $branch
git pull