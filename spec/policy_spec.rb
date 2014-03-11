require 'spec_helper'

describe AccessGranted::Policy do
  before :each do
    @policy = Class.new do
      include AccessGranted::Policy
    end.new(nil)
  end

  describe "#configure" do
    before :each do
      @member = double("member",        id: 1, is_moderator: false, is_admin: false, is_banned: false)
      @mod    = double("moderator",     id: 2, is_moderator: true,  is_admin: false, is_banned: false)
      @admin  = double("administrator", id: 3, is_moderator: false, is_admin: true,  is_banned: false)
      @banned = double("banned",        id: 4, is_moderator: false, is_admin: true,  is_banned: true)
    end

    it "selects permission based on role priority" do
      klass = Class.new do
        include AccessGranted::Policy

        def configure(user)
          role :administrator, { is_admin: true } do
            can :destroy, String
          end

          role :moderator, { is_moderator: true } do
            can :update, String
          end

          role :member do
            can :read, String
          end
        end
      end
      klass.new(@admin).can?(:destroy, String).should     be_true
      klass.new(@admin).can?(:read, String).should        be_true

      klass.new(@member).cannot?(:destroy, String).should be_true
      klass.new(@member).can?(:read, String).should       be_true

      klass.new(@mod).can?(:read, String).should          be_true
      klass.new(@mod).cannot?(:destroy, String).should    be_true
    end

    context "when multiple roles define the same permission" do
      it "checks all roles until conditions are met" do
        user_post = FakePost.new(@member.id)
        other_post = FakePost.new(66)

        klass = Class.new do
          include AccessGranted::Policy

          def configure(user)
            role :administrator, { is_admin: true } do
              can :destroy, FakePost
            end

            role :member do
              can :destroy, FakePost, user_id: user.id
            end
          end
        end

        klass.new(@admin).can?(:destroy, user_post).should be_true
        klass.new(@member).can?(:destroy, user_post).should be_true
        klass.new(@member).cannot?(:destroy, other_post).should be_true
      end
    end
    describe "#cannot" do
      it "forbids action when used in superior role" do
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
        klass.new(@member).can?(:create, String).should    be_true
        klass.new(@banned).cannot?(:create, String).should be_true
      end
    end

    describe "#authorize!" do
      let(:klass) do
        Class.new do
          include AccessGranted::Policy

          def configure(user)
            role(:member) { can :create, String }
          end
        end
      end

      it "raises AccessDenied if actions is not allowed" do
        expect { klass.new(@member).authorize!(:create, Integer) }.to raise_error AccessGranted::AccessDenied
      end

      it "returns the subject if allowed" do
        expect(klass.new(@member).authorize!(:create, String)).to equal String
      end
    end
  end

  describe "#role" do
    it "allows passing role class" do
      role = AccessGranted::Role.new(:role, 1, foo: "bar")
      @policy.role(:member, role)
      @policy.roles.first.conditions.should == role.to_conditions
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

      role.find_permission(:read, String).granted.should be_true
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
