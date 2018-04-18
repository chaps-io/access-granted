module AccessGranted
  class Error < StandardError; end

  class DuplicatePermission < Error; end;
  class DuplicateRole < Error; end;
  class AccessDenied < Error
    attr_reader :action, :subject
    def initialize(action = nil, subject = nil)
      @action = action
      @subject = subject
    end
  end
end
