module AccessGranted
  class Role
    attr_reader :name, :priority, :conditions, :permissions

    def initialize(name, priority = nil, conditions = nil, block = nil)
      raise(Error, "Name is required") if name.nil?
      raise(Error, "Priority argument is required") if priority.nil?

      @name       = name
      @priority   = priority
      @conditions = conditions
      @block      = block
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

    def matches_hash(user, conditions = {})
      conditions.each_pair do |name, value|
        attribute = user.send(name)
        return false if attribute != value
      end
      true
    end
  end
end
