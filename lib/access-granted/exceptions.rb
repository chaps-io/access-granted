module AccessGranted
  class Error < StandardError; end

  class DuplicateRole < Error; end;
  class AccessDenied < Error; end;
end
