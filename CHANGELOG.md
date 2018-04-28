# 1.3.1

- Add information about action and subject when raising AccessDenied exception ([PR #45](https://github.com/chaps-io/access-granted/pull/46)), thanks [jraqula](https://github.com/jraqula)!

# 1.3.0

- Drop support for Ruby 1.9.3, it might still work but we are no longer testing against it.
- Start testing against Rubies 2.3-2.5 in CI
- Move Rails integration into Railties, this fixes some load order issues ([PR #45](https://github.com/chaps-io/access-granted/pull/45)), thanks [jraqula](https://github.com/jraqula)!

# 1.2.0

- Cache whole blocks of identical permissions when one of them is checked.
  For example, assuming we have a given permissions set:

  ```ruby
  can [:update, :destroy, :archive], Post do |post, user|
     post.user_id == user.id
  end
  ```

  When resolving one of them like this:

  ```ruby
  can? :update, @post
  ```

  Access Granted will cache the result for each of the remaining actions, too.
  So next time when checking permissions `:destroy` or `:archive`, AG will serve the result from cache instead of running the block again.


# 1.1.2

- Expose internal `block` instance variable in Permission class

# 1.1.1

- Return detailed information about which permission is duplicate when raising DuplicatePermission exception
