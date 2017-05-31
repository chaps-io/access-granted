module AccessGranted
  class Permission
    attr_reader :action, :subject, :granted, :conditions, :actions, :block

    def initialize(granted, action, subject, user = nil, conditions = {}, actions = [], block = nil)
      @action     = action
      @user       = user
      @granted    = granted
      @subject    = subject
      @conditions = conditions
      @actions    = actions
      @block      = block
    end

    def matches_action?(action)
      @action == action
    end

    def matches_subject?(subject)
      subject == @subject || subject.class <= @subject
    end

    def matches_conditions?(subject)
      if @block
        @block.call(subject, @user)
      elsif !@conditions.empty?
        matches_hash_conditions?(subject)
      else
        true
      end
    end

    def matches_hash_conditions?(subject)
      @conditions.each_pair do |name, value|
        return false if subject.send(name) != value
      end
      true
    end

    def eql?(other)
      other.class == self.class &&
        @action == other.action &&
          @subject == other.subject &&
            @granted == other.granted
    end

    def ==(other)
      eql?(other)
    end
  end
end
