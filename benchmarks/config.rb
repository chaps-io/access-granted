class Ability
  include CanCan::Ability

  def initialize(user)
    if user.is_admin == true
      can :destroy, String
    end

    if user.is_moderator == true
      can :update, String
    end

    can :read, String
  end
end

class AccessPolicy
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

class User < Struct.new(:is_admin, :is_moderator)
end
