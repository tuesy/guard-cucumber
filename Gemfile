source "https://rubygems.org"

gemspec development_group: :gem_build_tools

group :gem_build_tools do
  gem "rake"
end

# The development group will no be
# installed on Travis CI.
#
group :development do
  gem "guard-rspec", require: false
  gem "guard-bundler", "~> 2.0.0", require: false
  gem "yard", require: false
  gem "redcarpet", require: false
  gem "guard-rubocop", require: false
  gem "rubocop", "~> 0.39.0"
  gem "guard-compat", require: false
end

group :test do
  gem "rspec", "~> 3.1"
end

platforms :rbx do
  gem "racc"
  gem "rubysl", "~> 2.0"
  gem "psych"
end
