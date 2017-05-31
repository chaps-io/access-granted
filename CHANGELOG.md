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
