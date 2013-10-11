require 'spec_helper'

describe AccessGranted::Policy do
  before :each do
    @policy = Object.new
    @policy.extend(AccessGranted::Policy)
  end

  it "allows defining a default role" do
    @policy.role(:member, 1)
    @policy.roles.map(&:name).should include(:member)
  end

  it "does not allow duplicate role names" do
    @policy.role(:member, 1)
    expect { @policy.role(:member, 1) }.to raise_error
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
