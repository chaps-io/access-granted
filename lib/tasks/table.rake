require 'access-granted'

namespace :access_granted do
  desc "Print table with all roles and their abilities"
  task :roles do
    klass = Class.new do
      include AccessGranted::Policy

      def configure(user)
        role :member do
          can :read, String
        end

        role :moderator, { is_moderator: true } do
          can :edit, String, published: true
        end

        role :administrator, { is_admin: true } do
          can :destroy, String
          can :moderate, Integer
        end
      end
    end
    policy = klass.new(nil)
    policy.print_table
  end
end