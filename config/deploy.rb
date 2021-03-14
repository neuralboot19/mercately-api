# config valid only for current version of Capistrano
# lock '3.6.0'
set :application, 'mercately'
set :repo_url, 'git@github.com:ThoughtCode/mercately.git' # Edit this to match your repository
set :deploy_via, :remote_cache
set :deploy_to, '/home/mercately/public_html'
set :pty, true
set :linked_files, %w{config/database.yml config/secrets.yml config/puma.rb config/mongoid.yml}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/uploads}
set :keep_releases, 5
set :rvm_type, :user
set :rvm_ruby_version, 'ruby-2.5.3' # Edit this if you are using MRI Ruby
set :rvm_custom_path, '~/.rvm'
set :systemd_unit, -> { "#{fetch :application}.target" }
set :systemd_use_sudo, true
set :systemd_roles, %w(app)
#Systemd integration
namespace :deploy do
 desc "Restart Mercately"
 task :restart_mercately do
   on roles(:app), in: :sequence, wait: 5 do
     execute :sudo, :systemctl, :restart, :mercately
   end
 end
 desc "Restart sidekiq"
 task :restart_sidekiq do
   on roles(:app), in: :sequence, wait: 5 do
     execute :sudo, :systemctl, :restart, :sidekiq
   end
 end
 desc "Restart nginx"
 task :restart_nginx do
   on roles(:app), in: :sequence, wait: 5 do
     execute :sudo, :systemctl, :restart, :nginx
   end
 end
 after :finishing,   :restart_mercately
 after :finishing,   :restart_sidekiq
 after :finishing,   :restart_nginx
end
