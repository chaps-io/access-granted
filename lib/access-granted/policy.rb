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
      name = name.to_sym
      if roles.select {|r| r.name == name }.any?
        raise DuplicateRole, "Role '#{name}' already defined"
      end
      @last_priority += 1
      r = if conditions_or_klass.is_a?(Class) && conditions_or_klass <= AccessGranted::Role
        conditions_or_klass.new(name, @last_priority, conditions, @user, block)
      else
        Role.new(name, @last_priority, conditions_or_klass, @user, block)
      end
      roles << r
      roles.sort_by! {|r|  r.priority }
      r
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

    def match_roles(user = nil)
      user ||= @user
      roles.select { |role| role.applies_to?(user) }
    end

    def authorize!(action, subject)
      if cannot?(action, subject)
        raise AccessDenied
      end
      subject
    end
  end
end
