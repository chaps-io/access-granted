require 'spec_helper'

describe AccessGranted::Role do
  subject { AccessGranted::Role }

  it "requires a role name" do
    expect { subject.new }.to raise_error(ArgumentError)
  end

  it "creates a default role without conditions" do
    expect(subject.new(:member).conditions).to be_nil
  end

  describe "#applies_to?" do
    it "matches user when no conditions given" do
      role = subject.new(:member)
      user = double("User")
      expect(role.applies_to?(user)).to eq(true)
    end

    it "matches user by hash conditions" do
      role = subject.new(:moderator,  { is_moderator: true })
      user = double("User", is_moderator: true)
      expect(role.applies_to?(user)).to eq(true)
    end

    it "doesn't match user if any of hash conditions is not met" do
      role = subject.new(:moderator, { is_moderator: true, is_admin: true })
      user = double("User", is_moderator: true, is_admin: false)
      expect(role.applies_to?(user)).to eq(false)
    end

    it "matches user by Proc conditions" do
      role = subject.new(:moderator, proc {|user| user.is_moderator? })
      user = double("User", is_moderator?: true)
      expect(role.applies_to?(user)).to eq(true)
    end
  end

  describe "#can" do
    before :each do
      @role = AccessGranted::Role.new(:member)
    end

    it "allows adding permission without subject" do
      @role.can :vague_action
      expect(@role.find_permission(:vague_action, nil)).to_not be_nil
    end

    it "forbids creating actions with the same name" do
      @role.can :read, String
      expect { @role.can :read, String }.to raise_error AccessGranted::DuplicatePermission
    end

    it "accepts :manage shortcut for CRUD actions" do
      @role.can :manage, String
      expect(@role.permissions.map(&:action)).to include(:read, :create, :update, :destroy)
    end

    describe "when action is an Array" do
      it "creates multiple permissions" do
        @role.can [:read, :create], String
        expect(@role.permissions.size).to eq(2)
      end
    end

    describe "when no conditions given" do
      it "should be able to read a class" do
        @role.can :read, String
        expect(@role.find_permission(:read, String)).to_not be_nil
      end

      it "should be able to read instance of class" do
        @role.can :read, String
        expect(@role.find_permission(:read, "text")).to_not be_nil
      end
    end

    describe "when conditions given" do
      it "should be able to read when conditions match" do
        sub = double("Element", published: true)
        @role.can :read, sub.class, { published: true }
        expect(@role.find_permission(:read, sub)).to_not be_nil
      end
    end
  end
end
