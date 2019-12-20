#!/usr/bin/env ruby
# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

# This file is used by Rack-based servers to start the application.

require File.expand_path('config/environment', __dir__)

require 'rack'

TCP_PORT = ENV.fetch('ROVOS_PORT', 3000)
HTTP_PORT = ENV.fetch('HTTP_PORT', 8080)

$tcp_server = MachineServer.new

Thin::Logging.logger = $logger
$logger.info "Rovos-broker #{AppVersion} (c) 2019 Danil Pismenny"
$logger.debug "RACK_ENV=#{ENV['RACK_ENV']}"

app = Hanami::Router.new do
  # List of connected machines
  get '/machines', to: 'machines#index'

  # Set status of machine
  post '/machines/:id', to: 'machines#change_status'

  # Get status of machine
  get '/machines/:id', to: 'machines#get_status'
end

EventMachine.run do
  $tcp_server.start TCP_PORT
  use Rack::CommonLogger, $logger
  Rack::Handler::Thin.run app, Host: '0.0.0.0', Port: HTTP_PORT, signals: false
end
