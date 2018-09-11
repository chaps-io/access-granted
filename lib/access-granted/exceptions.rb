module AccessGranted
  class Error < StandardError; end

  class DuplicatePermission < Error; end;
  class DuplicateRole < Error; end;
  class AccessDenied < Error
    attr_reader :action, :subject, :message
    def initialize(action = nil, subject = nil, message = nil)
      @action = action
      @subject = subject
      @message = message
    end
  end
end
