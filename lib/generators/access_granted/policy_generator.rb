require 'rails/generators/base'

module Accessgranted
  module Generators
    class PolicyGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      namespace "access_granted:policy"
      desc "Creates an Access Granted policy."

      def copy_policy
        template "access_policy.rb", "app/policies/access_policy.rb"
      end
    end
  end
end
