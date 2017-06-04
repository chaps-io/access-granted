module AccessGranted
  module Policy
    attr_accessor :roles, :cache
    attr_reader :user

    def initialize(user, cache_enabled = true)
      @user          = user
      @roles         = []
      @cache         = {}
      configure
    end

    def configure
    end

    def role(name, conditions_or_klass = nil, conditions = nil, &block)
      name = name.to_sym
      if roles.select {|r| r.name == name }.any?
        raise DuplicateRole, "Role '#{name}' already defined"
      end
      r = if conditions_or_klass.is_a?(Class) && conditions_or_klass <= AccessGranted::Role
        conditions_or_klass.new(name, conditions, user, block)
      else
        Role.new(name, conditions_or_klass, user, block)
      end
      roles << r
      r
    end

    def can?(action, subject = nil)
      cache[action] ||= {}

      if cache[action][subject]
        cache[action][subject]
      else
        granted, actions = check_permission(action, subject)
        actions.each do |a|
          cache[a] ||= {}
          cache[a][subject] ||= granted
        end

        granted
      end
    end

    def check_permission(action, subject)
      applicable_roles.each do |role|
        permission = role.find_permission(action, subject)
        return [permission.granted, permission.actions] if permission
      end

      [false, []]
    end

    def cannot?(*args)
      !can?(*args)
    end

    def authorize!(action, subject)
      if cannot?(action, subject)
        raise AccessDenied
      end
      subject
    end

    def self.current_user(controller)
      controller.current_user
    end

    private

    def applicable_roles
      @applicable_roles ||= roles.select do |role|
        role.applies_to?(user)
      end
    end
  end
end
