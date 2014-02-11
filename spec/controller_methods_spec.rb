require "spec_helper"

describe AccessGranted::ControllerMethods do
  before(:each) do
    @current_user = double("User")
    @controller_class = Class.new
    @controller = @controller_class.new
    @controller_class.stub(:helper_method).with(:can?, :cannot?, :current_policy)
    @controller_class.send(:include, AccessGranted::ControllerMethods)
    @controller.stub(:current_user).and_return(@current_user)
  end

  it "should have current_policy method returning Policy instance" do
    @controller.current_policy.should be_kind_of(AccessGranted::Policy)
  end

  it "provides can? and cannot? method delegated to current_policy" do
    @controller.can?(:read, String).should be_false
    @controller.cannot?(:read, String).should be_true
  end

  describe "#authorize!" do
    it "raises exception when authorization fails" do
      expect { @controller.authorize!(:read, String) }.to raise_error(AccessGranted::AccessDenied)
    end

    it "returns subject if authorization succeeds" do
      klass = Class.new do
        include AccessGranted::Policy

        def configure(user)
          role :member, 1 do
            can :read, String
          end
        end
      end
      policy = klass.new(@current_user)
      @controller.stub(:current_policy).and_return(policy)
      @controller.authorize!(:read, String).should == String
    end
  end
end
