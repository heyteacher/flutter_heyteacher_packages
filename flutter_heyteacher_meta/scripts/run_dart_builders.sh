#!/bin/bash
#
# Run all builders of flutter project.
#
# This script must be call when classes wich use builder decorations are 
# modified or created.
dart run build_runner build
