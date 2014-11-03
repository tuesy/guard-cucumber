source "https://rubygems.org"

gemspec

gem 'rake'
gem 'rspec', '~> 2.14'

# The development group will no be
# installed on Travis CI.
#
group :development do
  gem 'guard-rspec'
  gem 'guard-bundler'
  gem 'yard'
  gem 'redcarpet'
  gem 'transpec', require: false
end

platforms :rbx do
  gem 'racc'
  gem 'rubysl', '~> 2.0'
  gem 'psych'
end
