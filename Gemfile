source "https://rubygems.org"

gemspec

gem "rake"
gem "rspec", "~> 3.1"

# The development group will no be
# installed on Travis CI.
#
group :development do
  gem "guard-rspec"
  gem "guard-bundler"
  gem "yard"
  gem "redcarpet"
  gem "guard-rubocop"
end

platforms :rbx do
  gem "racc"
  gem "rubysl", "~> 2.0"
  gem "psych"
end
