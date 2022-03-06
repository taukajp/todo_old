#!/usr/bin/env bash

echo "Enter version"
read version
rm -rf build/
rm -rf lib/public/scss/bulma/
mkdir -p lib/public/scss/bulma/
git clone -b "$version" https://github.com/jgthms/bulma build/
mv build/bulma.sass build/sass/ lib/public/scss/bulma/
rm -rf build/
