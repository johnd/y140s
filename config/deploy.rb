set :application, "y140s"
set :repository,  "/Users/john/Code/y140s/.git"
set :deploy_to, "/home/deploy/live"
set :deploy_via, :copy

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

set :scm, :git
set :user, "deploy"
set :app_server, :passenger
set :use_sudo, false
set :domain, 'y140s.com'


# Allow ssh to use ssh keys
set :ssh_options, { :forward_agent => true }

role :app, domain
role :web, domain

deploy.task :symlinks do
  run "ln -nfs #{shared_path}/config/config.yml #{release_path}/telapp/config/config.yml"
end

deploy.task :restart do
  # Restart Passenger
  run "touch #{current_path}/webapp/tmp/restart.txt"
  # Restart Adhearsion
  run "ahnctl restart #{current_path}/telapp"
end


after :deploy, 'deploy:cleanup'
after 'deploy:update_code', 'deploy:symlinks'