module AccessGranted
  class Error < StandardError; end

  class DuplicatePermission < Error; end;
  class DuplicateRole < Error; end;
  class AccessDenied < Error; end;
end
