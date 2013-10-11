module AccessGranted
  module Policy
    def role(name, priority = nil, conditions = nil, &block)
      name = name.to_sym
      if roles.select {|r| r.name == name }.any?
        raise "Role '#{name}' already defined"
      end
      roles << Role.new(name, priority, conditions, block)
      roles.sort_by! {|r| - r.priority }
    end

    def roles
      @roles ||= []
    end

    def match_roles(user)
      matching_roles = []
      roles.each do |role|
        matching_roles << role if role.applies_to?(user)
      end
      return matching_roles
    end
  end
end
