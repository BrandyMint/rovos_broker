# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

# frozen_string_literal: true

lock '3.11.2'

set :application, 'rovos-broker'

set :rbenv_type, :user
set :rbenv_ruby, File.read('.ruby-version').strip

set :user, 'wwwuser'
set :repo_url, 'git@github.com:BrandyMint/iot_tcp_http_broker.git' if ENV['USE_LOCAL_REPO'].nil?
set :keep_releases, 10
set :linked_dirs, %w[log tmp/pids tmp/cache tmp/sockets]
# set :linked_files, %w[config/master.key]
# set :config_files, fetch(:linked_files)
set :deploy_to, -> { "/home/#{fetch(:user)}/#{fetch(:application)}" }
ask :branch, ENV['BRANCH'] || proc { `git rev-parse --abbrev-ref HEAD`.chomp } if ENV['BRANCH']

set :foreman_use_sudo, false # Set to :rbenv for rbenv sudo, :rvm for rvmsudo or true for normal sudo
set :foreman_roles, :all
set :foreman_init_system, 'upstart'
set :foreman_export_path, -> { File.join(Dir.home, '.init') }
set :foreman_app, -> { fetch(:application) }
set :foreman_app_name_systemd, -> { "#{fetch(:foreman_app)}.target" }
set :foreman_options, lambda {
  {
    # app: application,
    log: File.join(shared_path, 'log')
  }
}
