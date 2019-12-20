# frozen_string_literal: true

set :application, 'rovos-broker'
set :stage, :production
set :rails_env, :production
fetch(:default_env)[:rails_env] = :production

server '95.217.36.54',
       user: fetch(:user),
       port: '22',
       roles: %w[broker].freeze,
       ssh_options: { forward_agent: true }
