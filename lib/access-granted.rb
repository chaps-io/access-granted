require "access-granted/version"
require "access-granted/exceptions"
require "access-granted/policy"
require "access-granted/permission"
require "access-granted/controller_methods"
require "access-granted/role"
require "terminal-table"
require "colorize"

module AccessGranted

end

if defined? ActionController::Base
  ActionController::Base.class_eval do
    include AccessGranted::ControllerMethods
  end
end
