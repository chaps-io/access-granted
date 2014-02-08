require 'rubygems'
require 'bundler/setup'
require 'simplecov'
SimpleCov.start
require 'pry'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.order = 'random'
end

module ActionController
  class Base
    def self.helper_method(*args)
    end
  end
end
require 'access-granted'

class FakePost < Struct.new(:user_id)
end

class Policy
  include AccessGranted::Policy
end

