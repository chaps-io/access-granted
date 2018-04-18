require 'rails/railtie'

module AccessGranted
  class Railtie < ::Rails::Railtie
    initializer :access_granted do
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
