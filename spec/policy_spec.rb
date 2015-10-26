require 'spec_helper'

describe AccessGranted::Policy do
  let(:klass)      { Class.new { include AccessGranted::Policy } }
  subject(:policy) { klass.new(nil) }

  describe "#configure" do
    before :each do
      @member = double("member",        id: 1, is_moderator: false, is_admin: false, is_banned: false)
      @mod    = double("moderator",     id: 2, is_moderator: true,  is_admin: false, is_banned: false)
      @admin  = double("administrator", id: 3, is_moderator: false, is_admin: true,  is_banned: false)
      @banned = double("banned",        id: 4, is_moderator: false, is_admin: true,  is_banned: true)
    end

    it "passes user object to permission block" do
      post_owner = double(id: 123)
      other_user = double(id: 5)
      post = FakePost.new(post_owner.id)

      klass = Class.new do
        include AccessGranted::Policy

        def configure
          role :member do
            can :destroy, FakePost do |post, user|
              post.user_id == user.id
            end
          end
        end
      end

      expect(klass.new(post_owner).can?(:destroy, post)).to     eq(true)
      expect(klass.new(other_user).can?(:destroy, post)).to     eq(false)
    end

    it "selects permission based on role priority" do
      klass = Class.new do
        include AccessGranted::Policy

        def configure
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
      expect(klass.new(@admin).can?(:destroy, String)).to     eq(true)
      expect(klass.new(@admin).can?(:read, String)).to        eq(true)

      expect(klass.new(@member).cannot?(:destroy, String)).to eq(true)
      expect(klass.new(@member).can?(:read, String)).to       eq(true)

      expect(klass.new(@mod).can?(:read, String)).to         eq(true)
      expect(klass.new(@mod).cannot?(:destroy, String)).to   eq(true)
    end

    context "when multiple roles define the same permission" do
      it "checks all roles until conditions are met" do
        user_post = FakePost.new(@member.id)
        other_post = FakePost.new(66)

        klass = Class.new do
          include AccessGranted::Policy

          def configure
            role :administrator, { is_admin: true } do
              can :destroy, FakePost
            end

            role :member do
              can :destroy, FakePost do |post, user|
                post.user_id == user.id
              end
            end
          end
        end

       expect(klass.new(@admin).can?(:destroy, user_post)).to       eq(true)
       expect(klass.new(@admin).can?(:destroy, other_post)).to      eq(true)

       expect(klass.new(@member).can?(:destroy, user_post)).to      eq(true)
       expect(klass.new(@member).cannot?(:destroy, other_post)).to  eq(true)
      end
    end

    it "resolves permissions without subject" do
      klass = Class.new do
        include AccessGranted::Policy

        def configure
          role :member do
            can :vague_action
          end
        end
      end

      expect(klass.new(@member).can?(:vague_action)).to eq(true)
    end

    describe "#cannot" do
      it "forbids action when used in superior role" do
        klass = Class.new do
          include AccessGranted::Policy

          def configure
            role :banned, { is_banned: true } do
              cannot :create, String
            end

            role :member do
              can :create, String
            end
          end
        end
        expect(klass.new(@member).can?(:create, String)).to    eq(true)
        expect(klass.new(@banned).cannot?(:create, String)).to eq(true)
      end
    end

    describe "#authorize!" do
      let(:klass) do
        Class.new do
          include AccessGranted::Policy

          def configure
            role(:member) { can :create, String }
          end
        end
      end

      it "raises AccessDenied if action is not allowed" do
        expect { klass.new(@member).authorize!(:create, Integer) }.to raise_error AccessGranted::AccessDenied
      end

      it "returns the subject if allowed" do
        expect(klass.new(@member).authorize!(:create, String)).to equal String
      end
    end
  end

  describe "#role" do
    it "allows passing role class" do
      klass_role = Class.new AccessGranted::Role do
        def configure
          can :read, String
        end
      end
      subject.role(:member, klass_role)
      expect(policy.roles.first.class).to eq(klass_role)
    end

    it "returns roles in the order of priority" do
      policy.role(:admin)
      policy.role(:moderator)
      policy.role(:user)
      policy.role(:guest)

      expect(policy.roles.map(&:name)).to eq([:admin, :moderator, :user, :guest])
    end

    it "allows defining a default role" do
      policy.role(:member)
      expect(policy.roles.map(&:name)).to include(:member)
    end

    it "does not allow duplicate role names" do
      policy.role(:member)
      expect { policy.role(:member) }.to raise_error AccessGranted::DuplicateRole
    end

    it "allows nesting `can` calls inside a block" do
      role = policy.role(:member) do
        can :read, String
      end

      expect(role.find_permission(:read, String).granted).to eq(true)
    end
  end

  describe "#matching_roles" do
    let(:user) { double("User", is_moderator: true, is_admin: true) }

    before do
      policy.role(:administrator, { is_admin:     true })
      policy.role(:moderator,     { is_moderator: true })
      policy.role(:member)
    end

    shared_examples 'role matcher' do
      it "returns all matching roles in the order of priority" do
        expect(subject.map(&:name)).to eq([:administrator, :moderator, :member])
      end
    end
  end
end
