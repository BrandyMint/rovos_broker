#!/usr/bin/env ruby
# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

# This file is used by Rack-based servers to start the application.

require File.expand_path('config/environment', __dir__)

require 'rack'

TCP_PORT = ENV.fetch('ROVOS_PORT', 3000)

SERVER = MachineServer.new
MACHINE_CONNECTIONS = SERVER.connections

app = Hanami::Router.new do
  # List of connected machines
  get '/machines', to: 'machines#index'

  # Get status of machine
  get '/machines/:id', to: 'machines#status'

  # Start machine
  post '/machines/:id', to: 'machines#start'
end

EventMachine::run do
  SERVER.start TCP_PORT
  Rack::Handler::Thin.run app, Port: 8080, signals: false
  #trap "SIGINT" do
    #EventMachine.stop
  #end
end
