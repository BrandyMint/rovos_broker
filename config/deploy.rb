# frozen_string_literal: true

lock '3.11.2'

set :user, 'wwwuser'
set :repo_url, 'git@github.com:BrandyMint/iot_tcp_http_broker.git' if ENV['USE_LOCAL_REPO'].nil?
set :keep_releases, 10
set :linked_dirs, %w[log tmp/pids tmp/cache tmp/sockets]
# set :linked_files, %w[config/master.key]
# set :config_files, fetch(:linked_files)
set :deploy_to, -> { "/home/#{fetch(:user)}/#{fetch(:application)}" }
ask :branch, ENV['BRANCH'] || proc { `git rev-parse --abbrev-ref HEAD`.chomp } if ENV['BRANCH']
set :rbenv_type, :user
set :rbenv_ruby, File.read('.ruby-version').strip
