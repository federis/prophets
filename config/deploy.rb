require "capistrano/ext/multistage"
require "bundler/capistrano"
require "rvm/capistrano"
require "capistrano-resque"

set :application, "prophets"
set :repository,  "git@github.com:bcroesch/prophets.git"
set :scm, :git
set :branch, "master"
ssh_options[:forward_agent] = true

set :rvm_ruby_string, "ruby-1.9.3-p374"
set :rvm_type, :system

set :stages, %w(staging production vm)
set :default_stage, "staging"

set :deploy_to, "/var/www/apps/#{application}"
set :deploy_via, :remote_cache

default_run_options[:pty] = true
set :user, "deploy"
set :use_sudo, false

after "deploy:restart", "deploy:cleanup"

set :workers, { "*" => 3 }
after "deploy:stop",    "resque:stop"
after "deploy:start",   "resque:start"
after "deploy:restart", "resque:restart"

namespace :deploy do
  %w[start stop restart].each do |command|
    desc "#{command} unicorn server"
    task command, roles: :app, except: {no_release: true} do
      run "/etc/init.d/unicorn #{command}"
    end
  end
end