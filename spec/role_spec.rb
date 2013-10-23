require 'spec_helper'

describe AccessGranted::Role do
  subject { AccessGranted::Role }

  it "requires a role name" do
    expect { subject.new }.to raise_error
  end

  it "requires priority" do
    expect { subject.new(:member) }.to raise_error
  end

  it "creates a default role without conditions" do
    subject.new(:member, 1).conditions.should be_nil
  end

  describe "#relevant_permissions?" do
    it "returns only matching permissions" do
      role = subject.new(:member, 1)
      role.can :read, String
      role.can :read, Hash
      role.relevant_permissions(:read, String).should == [AccessGranted::Permission.new(true, :read, String)]
    end
  end

  describe "#applies_to?" do
    it "matches user when no conditions given" do
      role = subject.new(:member, 1)
      user = double("User")
      role.applies_to?(user).should be_true
    end

    it "matches user by hash conditions" do
      role = subject.new(:moderator, 1,  { is_moderator: true })
      user = double("User", is_moderator: true)
      role.applies_to?(user).should be_true
    end

    it "doesn't match user if any of hash conditions is not met" do
      role = subject.new(:moderator, 1, { is_moderator: true, is_admin: true })
      user = double("User", is_moderator: true, is_admin: false)
      role.applies_to?(user).should be_false
    end

    it "matches user by Proc conditions" do
      role = subject.new(:moderator, 1, proc {|user| user.is_moderator? })
      user = double("User", is_moderator?: true)
      role.applies_to?(user).should be_true
    end
  end

  describe "#can" do
    before :each do
      @role = AccessGranted::Role.new(:member, 1)
    end

    it "forbids creating actions with the same name" do
      @role.can :read, String
      expect { @role.can :read, String }.to raise_error AccessGranted::DuplicatePermission
    end

    it "accepts :manage shortcut for CRUD actions" do
      @role.can :manage, String
      @role.permissions.map(&:action).should include(:create, :update, :destroy)
    end

    describe "when action is an Array" do
      it "creates multiple permissions" do
        @role.can [:read, :create], String
        @role.permissions.should have(2).items
      end
    end

    describe "when no conditions given" do
      it "should be able to read a class" do
        @role.can :read, String
        @role.can?(:read, String).should be_true
      end

      it "should be able to read instance of class" do
        @role.can :read, String
        @role.can?(:read, "text").should be_true
      end
    end

    describe "when conditions given" do
      it "should be able to read when conditions match" do
        sub = double("Element", published: true)
        @role.can :read, sub.class, { published: true }
        @role.can?(:read, sub).should be_true
      end
    end
  end
end
