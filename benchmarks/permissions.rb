require 'benchmark/ips'
require 'access-granted'
require 'cancan'
require_relative './config'

admin        = User.new(true, false)
mod          = User.new(false, true)
user         = User.new(false, false)

user_policy  = AccessPolicy.new(user)
admin_policy = AccessPolicy.new(admin)
mod_policy   = AccessPolicy.new(mod)

user_ability  = Ability.new(user)
admin_ability = Ability.new(admin)
mod_ability   = Ability.new(mod)

Benchmark.ips do |x|
  x.config(time: 20, warmup: 2)

  x.report("ag-admin") do
    admin_policy.can?(:read, String)
  end

  x.report("ag-moderator") do
    mod_policy.can?(:read, String)
  end

  x.report("ag-user") do
    user_policy.can?(:read, String)
  end

  x.report("cancan-admin") do
    admin_ability.can?(:read, String)
  end

  x.report("cancan-moderator") do
    mod_ability.can?(:read, String)
  end

  x.report("cancan-user") do
    user_ability.can?(:read, String)
  end

end
