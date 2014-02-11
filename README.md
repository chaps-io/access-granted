# AccessGranted [![Build Status](https://travis-ci.org/pokonski/access-granted.png?branch=master)](https://travis-ci.org/pokonski/access-granted) [![Code Climate](https://codeclimate.com/github/pokonski/access-granted.png)](https://codeclimate.com/github/pokonski/access-granted)

Multi-role and whitelist based authorization gem for Rails. And it's lightweight (~300 lines of code)!

### Supported Ruby versions

Guaranteed to work on MRI 1.9.3/2.0/2.1, Rubinius >= 2.1.1 and JRuby >= 1.7.6.

# Summary

AccessGranted is meant as replacement for CanCan to solve three major problems:

1. built-in support for roles

  Easy to read access policy code where permissions are cleanly grouped into roles which may or may not apply to a user.
  Additionally permissions are forced to be unique in the scope a role. Thus greatly simplifying the
  permission resolving and extremely reducing the code-base.

2. white-list based

  This means that you define what a role **can** do,
  not overidding permissions with `cannot` in a specific order which results in an ugly and unmaintainable code.

  **Note**: `cannot` is still possible, but has a specifc use. See [Usage](#usage) below.

3. Permissions can work on basically any object and AccessGranted is framework-agnostic,
   (the Rails-specific methods are `can?`/`cannot?`/`authorize!` helpers injected
   into the framework only when it's present).

See [Usage](#usage) for an example of a complete AccessPolicy file.

## Compatibility with CanCan

This gem was created as a replacement for CanCan and therefore it requires minimum work to switch.

### Main differences

1. AccessGranted does not extend ActiveRecord in any way, so it does not have the `accessible_by?`
   method which could be used for querying objects available to current user.
   This was very complex and only worked with permissions defined using hash conditions, so
   I decided to not implement this functionality as it was mostly ignored by CanCan users.

2. Both `can?`/`cannot?` and `authorize!` methods work in Rails controllers and views, just like in CanCan.
   The only change you have to make is replace all `can? :manage, Class` with precise action.
   `can :manage` is stil available for **defining** methods and serves as a shortcut for defining `:read`, `:create`, `:update`, `:destroy`
   in one line.

   Due to introduction of Roles checking for generic `:manage` permission is very complicated and also confusing for developers.

3. Syntax for defining permissions in AccessPolicy file (Ability in CanCan) is exactly the same,
   with added roles on top. See [Usage](#usage) below.


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
    # The most important role prohibiting banned
    # users from doing anything.
    # (even if they are moderators or admins)
    role :banned, { is_banned: true } do
      cannot [:create, :update, :destroy], Post

      # same as above, :manage is just a shortcut for
      # `[:read, :create, :update, :destroy]`
      cannot :manage, Comment
    end

    # Takes precedences over roles placed lower
    # and explicitly lets admin manage everything.
    role :admin, { is_admin: true } do
      can :manage, Post
      can :manage, Comment
    end

    # You can also use Procs to determine
    # if the role should apply to a given user.
    role :moderator, proc {|u| u.moderator? } do
      # takes precedence over :update/:destroy
      # permissions defined in member role below
      # and lets moderators edit and delete all posts
      can [:update, :destroy], Post

      # and a new permission which lets moderators
      # modify user accounts
      can :update, User
    end

    # The basic role.
    # Applies to everyone logged in.
    role :member do
      can :create, Post

      # For more advanced permissions
      # you must use blocks. Hash
      # conditions should be used for
      # simple checks only.
      can [:update, :destroy], Post do |post|
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
