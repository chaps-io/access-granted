module AccessGranted
  module Policy
    attr_accessor :roles

    def initialize(user)
      @user          = user
      @roles         = []
      @last_priority = 0
      configure(@user)
    end

    def configure(user)
    end

    def role(name, conditions_or_klass = nil, conditions = nil, &block)
      if role_exists?(name)
        raise DuplicateRole, "Role '#{name}' already defined"
      end

      conditions = conditions_or_klass
      if conditions_or_klass.respond_to?(:to_conditions)
        conditions = conditions_or_klass.to_conditions
      end

      @last_priority += 1
      roles << Role.new(name, @last_priority, conditions, @user, block)
      roles.last
    end

    def role_exists?(name)
      roles.any? { |role| role.name == name.to_sym }
    end

    def can?(action, subject)
      match_roles(@user).each do |role|
        permission = role.find_permission(action, subject)
        return permission.granted if permission
      end
      false
    end

    def cannot?(*args)
      !can?(*args)
    end

    def match_roles(user)
      roles.select do |role|
        role.applies_to?(user)
      end
    end

    def authorize!(action, subject)
      if cannot?(action, subject)
        raise AccessDenied
      end
      subject
    end
  end
end
