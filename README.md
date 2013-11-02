# AccessGranted

Multi-role based authorization gem for Rails.

## Installation

Add this line to your application's Gemfile:

    gem 'access-granted'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install access-granted

## Usage

Roles are defined using blocks (or by passing custom classes to keep things tidy).
Order of the roles is important, because they are being traversed in the top-to-bottom order. Generally at the top you will have
an admin or other important role giving the user top permissions, and as you go down you define less-privileged roles.

See full example:

```ruby
class Policy
  include AccessGranted::Policy

  def configure(user)
    # the most important role prohibiting banned
    # users from doing anything
    # (even if they are moderators or admins)
    role :banned { is_banned: true } do
      cannot [:create, :update, :destroy], Post

      # same as above, :manage is just a shortcut for
      # `[:create, :update, :destroy]`
      cannot :manage, Comment
    end

    role :admin, { is_admin: true } do
      # overwrites every other permission of :moderators
      # and lets admin mamange everything
      can :manage, Post
      can :manage, Comment
    end

    # more complex logic to determine user's role
    role :moderator, proc {|u| u.moderator? } do
      # overwrites permission that only allows removing own content in :member
      # and lets moderators edit and delete all posts
      can [:update, :destroy], Post

      # and a new permission which lets moderators
      # modify user accounts
      can :update, User
    end

    # applies to everyone logged in
    # second argument is priority
    # the higher the number the more important the role
    role :member do
      can :create, Post

      # For more advanced permissions
      # you must use blocks. Hash
      # conditions should be used for
      # simple checks only.
      can [:edit, :destroy], Post do |post|
        post.user_id == user.id && post.comments.empty?
      end
    end
  end
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
