module AccessGranted
  class Error < StandardError; end

  class DuplicatePermission < Error; end;
  class DuplicateScope < Error; end;
  class DuplicateRole < Error; end;
  class AccessDenied < Error; end;
  class ScopeNotDefined < Error; end;
end
