module AccessGranted
  module Policy
    attr_accessor :roles

    def initialize(user)
      @user          = user
      @roles         = []
      @last_priority = 0
      configure(@user)
    end

    def configure(user)
    end

    def role(name, conditions_or_klass = nil, conditions = nil, &block)
      name = name.to_sym
      if roles.select {|r| r.name == name }.any?
        raise DuplicateRole, "Role '#{name}' already defined"
      end
      @last_priority += 1
      r = if conditions_or_klass.is_a?(Class) && conditions_or_klass <= AccessGranted::Role
        conditions_or_klass.new(name, @last_priority, conditions, @user, block)
      else
        Role.new(name, @last_priority, conditions_or_klass, @user, block)
      end
      roles << r
      roles.sort_by! {|r|  r.priority }
      r
    end

    def can?(action, subject)
      match_roles(@user).each do |role|
        permission = role.find_permission(action, subject)
        return permission.granted if permission
      end
      false
    end

    def cannot?(*args)
      !can?(*args)
    end

    def match_roles(user)
      roles.select do |role|
        role.applies_to?(user)
      end
    end

    def authorize!(action, subject)
      if cannot?(action, subject)
        raise AccessDenied
      end
      subject
    end

    def print_table
      headings = [{value: "Roles", alignment: :center}] + roles.sort_by {|r|  r.priority }.map(&:name)
      permissions = []
      rows = []
      roles.each do |role|
        permissions += role.permissions.map{|p| {action: p.action, subject: p.subject}}
      end
      permissions.uniq{|p| "#{p[:action]} #{p[:subject]}"}.sort_by {|p| p[:action].to_s}.each do |perm|
        row = ["#{perm[:action]} " + "#{perm[:subject]}".light_blue]
        roles.each do |role|
          per = role.permissions.detect { |p| p.action == perm[:action] && p.subject == perm[:subject] }
          value = (per.nil? ? "n/s".blue : (per.granted ? "can".green : "cannot".red))
          value += " *" if per && (per.conditions.any? || per.block)
          row << {value: value, alignment: :center}
        end
        rows << row
      end
      table = Terminal::Table.new headings: headings, rows: rows
      puts table
      puts "can".green  + "    - action allowed"
      puts "cannot".red + " - action explicitly forbidden"
      puts "n/s".blue   + "    - permission not specified for given role"
      puts "*"   + "      - additional conditions apply"
    end
  end
end
