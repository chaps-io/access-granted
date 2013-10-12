require 'spec_helper'

describe AccessGranted::Policy do
  before :each do
    @policy = Object.new
    @policy.extend(AccessGranted::Policy)
  end

  describe "#initialize" do
    before :each do
      @member = double("member",        is_moderator: false, is_admin: false)
      @mod    = double("moderator",     is_moderator: true,  is_admin: false)
      @admin  = double("administrator", is_moderator: false, is_admin: true)
    end

    it "selects permission based on role priority" do
      klass = Class.new do
        include AccessGranted::Policy

        def configure(user)
          role :member, 1 do
            can :read, String
          end

          role :moderator, 2, { is_moderator: true } do
            can :edit, String
          end

          role :administrator, 3, { is_admin: true } do
            can :destroy, String
          end
        end
      end
      klass.new(@member).cannot?(:destroy, String).should be_true
      klass.new(@admin).can?(:destroy, String).should     be_true
      klass.new(@admin).can?(:read, String).should        be_true
      klass.new(@mod).cannot?(:destroy, String).should    be_true
    end
  end

  describe "#role" do
    it "allows defining a default role" do
      @policy.role(:member, 1)
      @policy.roles.map(&:name).should include(:member)
    end

    it "does not allow duplicate role names" do
      @policy.role(:member, 1)
      expect { @policy.role(:member, 1) }.to raise_error
    end

    it "allows nesting `can` calls inside a block" do
      role = @policy.role(:member, 1) do
        can :read, String
      end

      role.can?(:read, String).should be_true
    end
  end

  describe "#match_roles" do
    it "returns all matching roles in the order of priority" do
      user = double("User", is_moderator: true, is_admin: true)

      @policy.role(:administrator, 3, { is_admin:     true })
      @policy.role(:moderator,     2, { is_moderator: true })
      @policy.role(:member,        1)

      @policy.match_roles(user).map(&:name).should == [:administrator, :moderator, :member]
    end
  end

end
