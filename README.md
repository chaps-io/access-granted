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

Example Policy class:

```ruby
class Policy
  include AccessGranted::Policy

  def configure(user)
    # applies to everyone logged in
    # second argument is priority
    # the higher the number the more important the role
    role :member, 1 do
      can :create, Post
      can :delete, Post, user_id: user.id
      can :edit, Post, user_id: user.id do |post|
        post.comments.empty?
      end
    end

    # more complex logic to determine user's role
    role :moderator, 2, proc {|u| u.moderator? } do
      # overwrites permission that only allows removing own content in :member
      # and lets moderators edit and delete all posts
      can [:edit, :delete], Post

      # and a new permission which lets moderators
      # modify user accounts
      can :edit, User
    end

    role :admin, 3, { is_admin: true } do
      # overwrites every other permission of :moderators
      # and lets admin mamange everything
      can [:create, :edit, :destroy], Post
      can [:create, :edit, :destroy], Comment
    end

    # the most important role prohibiting banned
    # users from doing anything
    # (even if they are moderators or admins)
    role :banned, 10 { is_banned: true } do
      cannot [:create, :edit, :destroy], Post
      cannot [:create, :edit, :destroy], Comment
    end
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
