#!/usr/bin/env bash

# sh clean.sh

echo "Updating All dependencies"

carthage update --platform ios --no-use-binaries --cache-builds --new-resolver

echo "Updated all dependencies"
