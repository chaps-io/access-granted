require "spec_helper"

describe AccessGranted::ControllerMethods do
  before(:all) do
    @policy = Class.new do
        include AccessGranted::Policy

        def configure(user)
          role :member, 1 do
            can :read, String
          end
        end
      end
    @controller_class = Class.new
  end

  before(:each) do
    @controller_class.stub(:helper_method).with(:can?, :cannot?, :current_ability)
    @controller_class.send(:include, AccessGranted::ControllerMethods)
    @controller = @controller_class.new
    @controller.stub(:current_user).and_return(double('User'))
  end

  context "when current_policy is not defined" do
    it "raises exception" do
      expect { @controller.can?(:read, String).should be_true }.to raise_error(NotImplementedError)
    end
  end

  context "when current_policy is defined" do
    before(:each) do
      @controller.stub(:current_policy).and_return(@policy.new(@current_user))
    end

    it "should have current_policy method returning Policy instance" do
      @controller.current_policy.should be_kind_of(AccessGranted::Policy)
    end

    it "provides can? and cannot? method delegated to current_policy" do
      @controller.cannot?(:read, String).should be_false
      @controller.can?(:read, String).should be_true
    end

    describe "#authorize!" do
      it "raises exception when authorization fails" do
        expect { @controller.authorize!(:update, String) }.to raise_error(AccessGranted::AccessDenied)
      end

      it "returns subject if authorization succeeds" do
        @controller.authorize!(:read, String).should == String
      end
    end
  end
end
