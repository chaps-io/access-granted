require 'spec_helper'

describe AccessGranted::Role do
  subject { AccessGranted::Role }

  it "creates a default role without conditions" do
    subject.new(:member, 1).conditions.should be_nil
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
end
