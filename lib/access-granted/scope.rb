module AccessGranted
  class Scope
    attr_reader :action, :subject, :conditions

    def initialize(action, subject, user = nil, conditions = {}, block = nil)
      @action     = action
      @user       = user
      @subject    = subject
      @conditions = conditions
      @block      = block
    end

    def matches_action?(action)
      @action == action
    end

    def matches_subject?(subject)
      subject == @subject || subject.klass <= @subject
    end

    def apply_conditions(subject)
      criteria = subject
      criteria = criteria.where(conditions)
      criteria = @block.call(@user, criteria) if @block
      criteria
    end

    def eql?(other)
      other.class == self.class &&
        @action == other.action && \
        @subject == other.subject
    end

    alias == eql?
  end
end
