source "https://rubygems.org"

gemspec

gem "rake"
gem "rspec", "~> 3.1"

# The development group will no be
# installed on Travis CI.
#
group :development do
  gem "guard-rspec", require: false
  gem "guard-bundler", github: 'guard/guard-bundler', branch: 'master', require: false
  gem "yard", require: false
  gem "redcarpet", require: false
  gem "guard-rubocop", require: false
  gem "rubocop", github: "bbatsov/rubocop", branch: "master"
  gem "guard-compat", require: false
end

platforms :rbx do
  gem "racc"
  gem "rubysl", "~> 2.0"
  gem "psych"
end
