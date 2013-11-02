require 'spec_helper'

describe AccessGranted::Policy do
  before :each do
    @policy = Class.new do
      include AccessGranted::Policy
    end.new(nil)
  end

  describe "#configure" do
    before :each do
      @member = double("member",        is_moderator: false, is_admin: false, is_banned: false)
      @mod    = double("moderator",     is_moderator: true,  is_admin: false, is_banned: false)
      @admin  = double("administrator", is_moderator: false, is_admin: true,  is_banned: false)
      @banned = double("banned",        is_moderator: false, is_admin: true,  is_banned: true)
    end

    it "selects permission based on role priority" do
      klass = Class.new do
        include AccessGranted::Policy

        def configure(user)
          role :member do
            can :read, String
          end

          role :moderator, { is_moderator: true } do
            can :edit, String
          end

          role :administrator, { is_admin: true } do
            can :destroy, String
          end
        end
      end
      klass.new(@member).cannot?(:destroy, String).should be_true
      klass.new(@admin).can?(:destroy, String).should     be_true
      klass.new(@admin).can?(:read, String).should        be_true
      klass.new(@mod).cannot?(:destroy, String).should    be_true
    end

    describe "#cannot" do
      it "forbids action when used in higher role" do
        klass = Class.new do
          include AccessGranted::Policy

          def configure(user)
            role :banned, { is_banned: true } do
              cannot :create, String
            end

            role :member do
              can :create, String
            end
          end
        end
        klass.new(@member).can?(:create, String).should be_true
        klass.new(@banned).can?(:create, String).should be_false
      end
    end
  end

  describe "#role" do
    it "allows passing role class" do
      klass_role = Class.new AccessGranted::Role do
        def configure(user)
          can :read, String
        end
      end
      @policy.role(:member, klass_role)
      @policy.roles.first.class.should == klass_role
    end

    it "allows defining a default role" do
      @policy.role(:member)
      @policy.roles.map(&:name).should include(:member)
    end

    it "does not allow duplicate role names" do
      @policy.role(:member)
      expect { @policy.role(:member) }.to raise_error AccessGranted::DuplicateRole
    end

    it "allows nesting `can` calls inside a block" do
      role = @policy.role(:member) do
        can :read, String
      end

      role.can?(:read, String).should be_true
    end
  end

  describe "#match_roles" do
    it "returns all matching roles in the order of priority" do
      user = double("User", is_moderator: true, is_admin: true)

      @policy.role(:administrator, { is_admin:     true })
      @policy.role(:moderator,     { is_moderator: true })
      @policy.role(:member)

      @policy.match_roles(user).map(&:name).should == [:administrator, :moderator, :member]
    end
  end

end
