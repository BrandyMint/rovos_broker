#!/usr/bin/env ruby
# This file is used by Rack-based servers to start the application.

require File.expand_path('config/environment', __dir__)

require 'rack'

MACHINE_CONNECTIONS = Concurrent::Map.new

Thread.new do
  MachineServer.new.
    perform(connections_map: MACHINE_CONNECTIONS, port: ENV.fetch('ROVOS_PORT', 3000))
end

app = Hanami::Router.new do
  # List of connected machines
  get '/machines',  to:  'machines#index'

  # Get status of machine
  get '/machines/:id', to: 'machines#status'

  # Start machine
  post '/machines/:id', to: 'mashines#start'
end

Rack::Handler::Thin.run app, Port: 8080
