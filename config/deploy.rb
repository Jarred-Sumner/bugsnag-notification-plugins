# Setup
set :application, "bugsnag-notification-plugins"
set :repository, "git@github.com:bugsnag/bugsnag-notification-plugins.git"
set :user, "deploy"
set :scm, :git
set :deploy_to, "/var/www/bugsnag/notification-plugins"
set :deploy_via, :remote_cache
set :copy_exclude, ".git"
default_run_options[:pty] = true

# Roles
role :app, "bugsnag.com"

set :trigger_servers, [
  "bugsnag-trigger-worker"
]

# Node magic
namespace :deploy do
  task :start, :roles => :app, :except => { :no_release => true } do
    trigger_servers.each do |s|
      sudo "start #{s}"
    end
  end

  task :stop, :roles => :app, :except => { :no_release => true } do
    trigger_servers.each do |s|
      sudo "stop #{s}"
    end
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    trigger_servers.each do |s|
      sudo "restart #{s} || sudo start #{s}"
    end
  end

  desc "Check required packages and install if packages are not installed"
  task :check_packages, roles => :app do
    run "for dir in #{release_path}/*; do if [ -d $dir ]; then (cd $dir && npm install); fi done"
  end
end

after "deploy:finalize_update", "deploy:check_packages"
after "deploy:symlink", "deploy:restart"