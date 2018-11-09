require 'mina/deploy'
require 'mina/git'

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :application_name, 'dml'
set :domain, 'dml-api.dev.kyokan.io'
set :deploy_to, '/home/deploy/app'
set :repository, 'git@github.com:DecentralizedML/dml-backend.git'
set :branch, 'master'
set :user, 'deploy'
set :forward_agent, true

# Optional settings:
#   set :user, 'foobar'          # Username in the server to SSH to.
#   set :port, '30000'           # SSH port number.
#   set :forward_agent, true     # SSH forward_agent.

# Shared dirs and files will be symlinked into the app-folder by the 'deploy:link_shared_paths' step.
# Some plugins already add folders to shared_dirs like `mina/rails` add `public/assets`, `vendor/bundle` and many more
# run `mina -d` to see all folders and files already included in `shared_dirs` and `shared_files`
set :shared_dirs, fetch(:shared_dirs, []).push('deps', 'rel', '_build')
# set :shared_files, fetch(:shared_files, []).push('config/database.yml', 'config/secrets.yml')

# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.
task :remote_environment do
  command %[source ~/.profile]
  command %[source ~/.asdf/asdf.sh]
  command %[export MIX_ENV=prod]
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  command %[ if ! asdf plugin-list | grep erlang; then asdf plugin-add erlang https://github.com/HashNuke/asdf-erlang.git; fi]
  command %[ if ! asdf plugin-list | grep elixir; then asdf plugin-add elixir https://github.com/HashNuke/asdf-elixir.git; fi]
  command %[ erlang_version=$(awk '/erlang/ { print $2 }' .tool-versions) && asdf install erlang ${erlang_version} ]
  command %[ elixir_version=$(awk '/elixir/ { print $2 }' .tool-versions) && asdf install elixir ${elixir_version} ]
end

desc "Deploys the current version to the server."
task :deploy do
  # uncomment this line to make sure you pushed your local branch to the remote origin
  # invoke :'git:ensure_pushed'
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    command %[mix deps.get]
    command %[mix compile]
    command %[mix release]
    command %[mix ecto.migrate]
    invoke :'deploy:cleanup'

    on :launch do
      invoke :'dml:stop'
      invoke :'dml:start'
    end

    on :clean do
      command 'echo "Failed deployment"'
    end
  end

  # you can use `run :local` to run tasks on local machine before of after the deploy scripts
  # run(:local){ say 'done' }
end

namespace :dml do
  %i(start stop restart ping).each do |name|
    task(name) do
      in_path(fetch(:current_path)) do
        command "_build/prod/rel/#{fetch(:application_name)}/bin/#{fetch(:application_name)} #{name}"
      end
    end
  end
end

# For help in making your deploy script, see the Mina documentation:
#
#  - https://github.com/mina-deploy/mina/tree/master/docs
