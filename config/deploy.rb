# config valid for current version and patch releases of Capistrano
lock "~> 3.10.0"

set :application, "ksp-rails"
set :repo_url, "git@github.com:listrophy/ksp-rails.git"

set :rvm_ruby_version, "ruby-2.4.1@ksp-rails"

set :unicorn_config_path, '/etc/unicorn.conf'
after 'deploy:publishing', 'deploy:restart'
namespace :deploy do
  task :restart do
    on roles(:app) do |host|
      execute(:sudo, '/usr/local/bin/restart-unicorn')
    end
  end
end

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/rails/#{fetch :application}"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", "config/secrets.yml"
append :linked_files, ".unicorn.sh"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"
append :linked_dirs, "vendor/bundle", ".bundle"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
