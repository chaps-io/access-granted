module AccessGranted
  class Permission
    attr_reader :action, :subject, :granted, :conditions

    def initialize(granted, action, subject, conditions = {}, block = nil)
      @action     = action
      @granted    = granted
      @subject    = subject
      @conditions = conditions
      @block      = block
    end

    def matches_action?(action)
      @action == action
    end

    def matches_subject?(subject)
      subject == @subject || (@subject.is_a?(Class) && subject.class <= @subject)
    end

    def matches_conditions?(subject)
      if @block
        @block.call(subject)
      else
        matches_hash_conditions?(subject)
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
