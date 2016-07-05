class Ability
  include CanCan::Ability

  def initialize(user)
    if user.is_admin
      can :destroy, String
      can :foo, Integer
    end

    if user.is_moderator
      can :update, String
      can :bar, String
    end

    can :read, String
    can :zoom, Integer
    can :boom, Hash
    can :rub, Fixnum
  end
end

class AccessPolicy
  include AccessGranted::Policy

  def configure
    role :administrator, { is_admin: true } do
      can :destroy, String
      can :foo, Integer
    end

    role :moderator, { is_moderator: true } do
      can :update, String
      can :bar, String
    end

    role :member do
      can :read, String
      can :zoom, Integer
      can :boom, Hash
      can :rub, Fixnum
    end
  end
end

class User < Struct.new(:id, :is_admin, :is_moderator)
end
