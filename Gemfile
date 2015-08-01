source 'https://rubygems.org'

# Specify your gem's dependencies in access-granted.gemspec
gemspec

group :test, :development do
  gem 'rb-readline'
  gem 'simplecov', require: false
  gem 'rake'
  gem 'pry'
  gem 'cancan'
  gem 'benchmark-ips'
end

platforms :rbx do
  gem 'rubysl', '~> 2.1'
end
