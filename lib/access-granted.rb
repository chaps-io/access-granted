require "access-granted/exceptions"
require "access-granted/policy"
require "access-granted/permission"
require "access-granted/role"
require 'access-granted/rails/controller_methods'

module AccessGranted

end

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
