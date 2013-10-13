module AccessGranted
  class Role
    attr_reader :name, :priority, :conditions, :permissions

    def initialize(name, priority, conditions = nil, block = nil)
      @name         = name
      @priority     = priority
      @conditions   = conditions
      @block        = block
      @permissions  = []
      @permissions_by_action = {}
      instance_eval(&@block) if @block
    end

    def can(action, subject, conditions = {}, &block)
      actions = [action].flatten
      actions.each do |a|
        raise DuplicateRole if relevant_permissions(a, subject).any?
        @permissions << Permission.new(a, subject, conditions, block)
        @permissions_by_action[a] ||= []
        @permissions_by_action[a]  << @permissions.size - 1
      end
    end

    def can?(action, subject)
      match = relevant_permissions(action, subject).detect do |permission|
        permission.matches_conditions?(subject)
      end
      match ? true : false
    end

    def applies_to?(user)
      case @conditions
      when Hash
        matches_hash(user, @conditions)
      when Proc
        @conditions.call(user)
      else
        true
      end
    end


    def relevant_permissions(action, subject)
      results = []

      (@permissions_by_action[action] || []).each do |index|
        perm = @permissions[index]
        if perm.matches_subject?(subject)
          results << perm
        end
      end

      results
    end

    def matches_hash(user, conditions = {})
      conditions.each_pair do |name, value|
        attribute = user.send(name)
        return false if attribute != value
      end
      true
    end
  end
end
