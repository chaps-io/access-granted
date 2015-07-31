# AccessGranted [![Build Status](https://travis-ci.org/chaps-io/access-granted.svg?branch=master)](https://travis-ci.org/chaps-io/access-granted) [![Code Climate](https://codeclimate.com/github/pokonski/access-granted.png)](https://codeclimate.com/github/pokonski/access-granted)

## [![](http://i.imgur.com/ya8Wnyl.png)](https://chaps.io) proudly made by [Chaps](https://chaps.io)


Multi-role and whitelist based authorization gem for Rails. And it's lightweight (~300 lines of code)!


## Installation

    gem 'access-granted'

### Supported Ruby versions

Guaranteed to work on all major Ruby versions MRI 1.9.3-2.2, Rubinius >= 2.X and JRuby >= 1.7.

## Summary

AccessGranted is meant as a replacement for CanCan to solve three major problems:

1. built-in support for user roles

  Easy to read access policy code where permissions are cleanly grouped into roles.
  Additionally, permissions are forced to be unique in the scope of a role. This greatly simplifies resolving permissions and makes it faster.

2. white-list based

  This means that you define what the user **can** do, which results in clean, readable policies regardless of app complexity.
  You don't have to worry about juggling `can`s and `cannot`s in a very convoluted way!

  _Note_: `cannot` is still available, but has a very specifc use. See [Usage](#usage) below.

3. framework agnostic

  Permissions can work on basically any object and AccessGranted is framework-agnostic,
  but it has Rails support of out the box :)
  It **does not depend on any libraries**, pure and clean Ruby code. Guaranteed to always work,
  even when software around changes.

## Usage

Roles are defined using blocks (or by passing custom classes to keep things tidy).

Order of the roles is important, because they are being traversed in the top-to-bottom order.
Generally at the top you will have an admin or other important role giving the user top permissions, and as you go down you define less-privileged roles.

### 1. Defining access policy

Let's start with a complete example of what can be achieved:

```ruby
# app/policies/access_policy.rb

class AccessPolicy
  include AccessGranted::Policy

  def configure(user)

    # The most important role prohibiting banned
    # users from doing anything.
    # (even if they are moderators or admins)

    role :banned, { is_banned: true } do
      cannot [:create, :update, :destroy], Post

      # :manage is just a shortcut for `[:read, :create, :update, :destroy]`
      cannot :manage, Comment
    end

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

    # The basic role. Applies to every user.

    role :member do
      can :create, Post

      # For more advanced permissions
      # you can use blocks or hashes.
      # Hashconditions should be used for
      # simple checks of attributes, while
      # blocks to run additional code with custom logic.

      can [:update, :destroy], Post do |post|
        post.user_id == user.id && post.comments.empty?
      end
    end
  end
end
```
### Using in Rails

AccessGranted comes with a set of helpers available in Ruby on Rails apps:

#### Authorizing controller actions

```ruby
class PostsController
  def show
    @post = Post.find(params[:id])
    authorize! :read, @post
  end

  def create
    authorize! :create, Post
    # (...)
  end
end
```

`authorize!` throws an exception when current user doesn't have a given permission.
You can rescue from it using `rescue_from`:

```ruby
class ApplicationController < ActionController::Base
  rescue_from "AccessGranted::AccessDenied" do |exception|
    redirect_to root_path, alert: "You don't have permissions to access this page."
  end
end
```

#### Checking permissions in controllers

To check if the user has a permission to perform an action, use `can?` and `cannot?` methods.

**Example:**

```ruby
class UsersController
  def update
    # (...)

    # only admins can elevate users to moderator status

    if can? :make_moderator, @user
      @user.moderator = params[:user][:moderator]
    end

    # (...)
  end
end

#### Checking permissions in views

Usually you don't want to show "Create" buttons for people who can't create something.
You can hide any part of the page from users without permissions like this:

```html
# app/views/categories/index.html.erb

<% if can? :create, Category %>
  <%= link_to "Create new category", new_category_path %>
<% end %>
```

#### Customizing policy

By default AccessGranted adds this method to your controllers:

```ruby
  def current_policy
    @current_policy ||= ::AccessPolicy.new(current_user)
  end
```

If you have a different policy class or if your user is not stored in `current_user` variable, then you can override it in any controllers and modify the logic as you please.

You can even have different policies for different controllers!

### Using in pure Ruby

Initialize the Policy class:

```ruby

policy = AccessPolicy.new(current_user)
```

Check the ability to do something:

with `can?`:

```ruby
policy.can?(:create, Post) #=> true
policy.can?(:update, @post) #=> false
```

or with `cannot?`:

```ruby
policy.cannot?(:create, Post) #=> false
policy.cannot?(:update, @ost) #=> true
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


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
