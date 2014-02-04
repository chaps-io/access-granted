module AccessGranted
  module ControllerMethods
    def current_policy
      raise NotImplementedError, "You must implement #current_policy in ActionController."
    end

    def self.included(base)
      base.helper_method :can?, :cannot?, :current_ability
    end

    def can?(*args)
      current_policy.can?(*args)
    end

    def cannot?(*args)
      current_policy.cannot?(*args)
    end

    def authorize!(*args)
      current_policy.authorize!(*args)
    end
  end
end

