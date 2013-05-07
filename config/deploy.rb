require 'capistrano'
require 'capistrano/maintenance'

#############################################################
#	Application
#############################################################

set :application, "katibean"
set :deploy_to, "/var/www/#{application}/"

#############################################################
#	Settings
#############################################################

default_run_options[:pty] = true
set :use_sudo, true

#############################################################
#	Servers
#############################################################

set :user, "root"
set :domain, "198.199.68.202"
server domain, :app, :web
role :db, domain, :primary => true

#############################################################
#	Subversion
#############################################################

set :repository,  "git://github.com/stariqmi/katibeen.git"
set :svn_username, "fm2munsh"
set :svn_password, ENV['GIT_PASS']
set :checkout, "fixed"

#############################################################
#	Passenger
#############################################################

after "deploy", "deploy:restart"
namespace :deploy do
	task :bundle_gems do
		run "cd #{deploy_to}/current && bundle install vendor/gems"
	end
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

end