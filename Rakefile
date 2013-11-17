require 'access-granted'
require "bundler/gem_tasks"
load "tasks/table.rake"

task :default => [:spec]
desc 'run Rspec specs'
task :spec do
  sh 'rspec spec'
end
