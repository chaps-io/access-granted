require 'rails/railtie'

module AccessGranted
  class Railtie < ::Rails::Railtie
    initializer :access_granted do
      if ::Rails::VERSION::MAJOR >= 6
        ActiveSupport.on_load(:action_controller_base) do |base|
          base.include AccessGranted::Rails::ControllerMethods
        end

        ActiveSupport.on_load(:action_controller_api) do |base|
          base.include AccessGranted::Rails::ControllerMethods
        end
      else
        if defined? ActionController::Base
          ActionController::Base.class_eval do
            include AccessGranted::Rails::ControllerMethods
          end
        end

        if defined? ActionController::API
          ActionController::API.class_eval do
            include AccessGranted::Rails::ControllerMethods
          end
        end
      end
    end
  end
end
