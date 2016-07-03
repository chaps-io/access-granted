require 'benchmark/ips'
require 'access-granted'
require 'cancan'
require_relative './config'

admin        = User.new(1, true, false)
mod          = User.new(2, false, true)
user         = User.new(3, false, false)

user_policy  = AccessPolicy.new(user)
admin_policy = AccessPolicy.new(admin)
mod_policy   = AccessPolicy.new(mod)

user_ability  = Ability.new(user)
admin_ability = Ability.new(admin)
mod_ability   = Ability.new(mod)

Benchmark.ips do |x|
  x.config(time: 5, warmup: 1)

  x.report("ag-admin") do
    admin_policy.can?(:read, String)
  end

  x.report("ag-moderator") do
    mod_policy.can?(:bar, String)
  end

  x.report("ag-user") do
    user_policy.can?(:zoom, Integer)
  end

  x.report("cancan-admin") do
    admin_ability.can?(:read, String)
  end

  x.report("cancan-moderator") do
    mod_ability.can?(:bar, String)
  end

  x.report("cancan-user") do
    user_ability.can?(:zoom, Integer)
  end
end
