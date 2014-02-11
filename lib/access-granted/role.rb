module AccessGranted
  class Role
    attr_reader :name, :user, :priority, :conditions, :permissions

    def initialize(name, priority, conditions = nil, user = nil, block = nil)
      @user         = user
      @name         = name
      @priority     = priority
      @conditions   = conditions
      @block        = block
      @permissions  = []
      @permissions_by_action = {}
      if @block
        instance_eval(&@block)
      else
        configure(@user)
      end
    end

    def configure(user)
    end

    def can(action, subject, conditions = {}, &block)
      add_permission(true, action, subject, conditions, block)
    end

    def cannot(action, subject, conditions = {}, &block)
      add_permission(false, action, subject, conditions, block)
    end

    def find_permission(action, subject)
      relevant_permissions(action, subject).detect do |permission|
        permission.matches_conditions?(subject)
      end
    end

    def applies_to?(user)
      case @conditions
      when Hash
        matches_hash?(user, @conditions)
      when Proc
        @conditions.call(user)
      else
        true
      end
    end


    def relevant_permissions(action, subject)
      permissions_by_action(action).select do |perm|
        perm.matches_subject?(subject)
      end
    end

    def matches_hash?(user, conditions = {})
      conditions.all? do |name, value|
        user.send(name) == value
      end
    end

    def add_permission(granted, action, subject, conditions, block)
      prepare_actions(action).each do |a|
        raise DuplicatePermission if relevant_permissions(a, subject).any?
        @permissions << Permission.new(granted, a, subject, conditions, block)
        @permissions_by_action[a] ||= []
        @permissions_by_action[a]  << @permissions.size - 1
      end
    end

    private

    def prepare_actions(action)
      if action == :manage
        actions = [:read, :create, :update, :destroy]
      else
        actions = [action].flatten
      end
    end

    def permissions_by_action(action)
      (@permissions_by_action[action] || []).map do |index|
        @permissions[index]
      end
    end
  end
end
