module AccessGranted
  class Permission
    attr_reader :action, :subject

    def initialize(action, subject, conditions = {}, block = nil)
      @action     = action
      @subject    = subject
      @conditions = conditions
      @block      = block
    end


    def relevant?(action, subject)
      matches_action?(action) && matches_subject?(subject)
    end

    def matches_action?(action)
      @action == action
    end

    def matches_subject?(subject)
      @subject == subject || matches_subject_class?(subject)
    end

    def matches_subject_class?(subject)
      (subject.class.to_s == @subject.to_s ||
        (
          subject.kind_of?(Module) &&
          subject.ancestors.include?(@subject)
        )
      )
    end

    def matches_conditions?(subject)
      if @block
        @block.call(subject)
      else
        matches_hash_conditions?(subject)
      end
    end

    def matches_hash_conditions?(subject)
      if @conditions.empty?
        return true
      end
      @conditions.each_pair do |name, value|
        attribute = subject.send(name)
        return false if attribute != value
      end
      true
    end

    def eql?(other)
      other.class == self.class &&
        @action == other.action &&
        @subject == other.subject
    end

    def ==(other)
      eql?(other)
    end
  end
end
