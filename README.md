# AccessGranted [![Build Status](https://travis-ci.org/chaps-io/access-granted.svg?branch=master)](https://travis-ci.org/chaps-io/access-granted) [![Code Climate](https://codeclimate.com/github/pokonski/access-granted.png)](https://codeclimate.com/github/pokonski/access-granted)

by [Chaps](https://chaps.io)


Multi-role and whitelist based authorization gem for Rails. And it's lightweight (~300 lines of code)!

### Supported Ruby versions

Guaranteed to work on MRI 1.9.3/2.0/2.1, Rubinius >= 2.1.1 and JRuby >= 1.7.6.

# Summary

AccessGranted is meant as a replacement for CanCan to solve three major problems:

1. **built-in support for roles**

  Easy to read access policy code where permissions are cleanly grouped into roles.
  Additionally, permissions are forced to be unique in the scope of a role. This greatly simplifies the resolving
  permissions while substantially reducing the code-base.

2. **white-list based**

  This means that you define what a role **can** do, which results in clean, readable policies regardless of complexity.
  You don't have to worry about juggling `can`s and `cannot`s in a very convoluted way!

  _Note_: `cannot` is still available, but has a very specifc use. See [Usage](#usage) below.

3. **framework agnostic**

  Permissions can work on basically any object and AccessGranted is framework-agnostic,
  But we offer extensions for your favourite frameworks as gems:
  - Rails: [access-granted-rails](https://github.com/pokonski/access-granted-rails)
  - ... more to come!

See [Usage](#usage) for an example of a complete AccessPolicy file.

## Compatibility with CanCan

This gem was created as a replacement for CanCan and therefore it requires minimum work to switch.

### Main differences

1. AccessGranted does not extend ActiveRecord in any way, so it does not have the `accessible_by?`
   method which could be used for querying objects available to current user.
   This was very complex and only worked with permissions defined using hash conditions, so
   I decided to not implement this functionality as it was mostly ignored by CanCan users.

2. Both `can?`/`cannot?` and `authorize!` methods work in Rails controllers and views, just like in CanCan.
   The only change you have to make is to replace all `can? :manage, Class` with the exact action to check against.
   `can :manage` is still available for **defining** methods and serves as a shortcut for defining `:read`, `:create`, `:update`, `:destroy` all in one line.

3. Syntax for defining permissions in AccessPolicy file (Ability in CanCan) is exactly the same,
   with added roles on top. See [Usage](#usage) below.


## Installation

### Rails

This includes Rails-specific integration (`can?`, `cannot?`, `current_policy` helpers and more):

    gem 'access-granted-rails'

### Others

    gem 'access-granted'

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

## Common examples

### Extracting roles to separate files

Let's say your app is getting bigger and more complex. This means your policy file is also getting longer.

Below you can see an extracted `:member` role:

```ruby
class AccessPolicy
  include AccessGranted::Policy

  def configure(user)
    role :administrator, is_admin: true do
      can :manage, User
    end

    role :member, MemberRole, lambda { |user| !u.guest? }
  end
end

```

And roles should look like this

```ruby
# app/roles/member_role.rb

class MemberRole < AccessGranted::Role
  def configure(user)
    can :create, Post
    can :destroy, Post do |post|
      post.author == user
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
