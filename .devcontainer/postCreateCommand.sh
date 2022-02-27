#!/usr/bin/env bash

set -e

exit 0

yes n | bundle gem . -b -t minitest --mit --no-coc --no-ext --ci=none

sed -i -E 's#(spec.homepage = ).*#\1"http://example.com"#' $APP_NAME.gemspec
sed -i -E 's#(spec.metadata\["source_code_uri"\] = ).*#\1"http://example.com"#' $APP_NAME.gemspec
sed -i -E 's#(spec.metadata\["changelog_uri"\] = ).*#\1"http://example.com"#' $APP_NAME.gemspec
sed -i 's/TODO: //' $APP_NAME.gemspec

# cat <<EOF >> Gemfile
# group :development, :test do
#   gem "standard"
#   gem "solargraph"
#   gem "debug"
# end
# EOF
# bundle install
bundle add standard solargraph debug --group "development, test"
bundle lock --add-platform ruby
bundle lock --add-platform x86_64-linux

cat <<EOF >> .standard.yml
ruby_version: $RUBY_MAJOR
ignore:
  - 'vendor/**/*'
EOF

cat <<EOF >> .gitignore
/vendor/bundle
.env
*.log
.DS_Store
EOF
