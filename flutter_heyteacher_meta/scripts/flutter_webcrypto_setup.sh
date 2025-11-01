#!/bin/bash
#
# Rebuild webcrypto package compiling artifacts.
#
# This script must be call after a "flutter clean" which erase all package 
#artifacts.
flutter pub run webcrypto:setup
