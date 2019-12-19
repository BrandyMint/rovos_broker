#!/usr/bin/env ruby
# This file is used by Rack-based servers to start the application.

require File.expand_path('config/environment', __dir__)

require 'rack'

Thread.new do
  MachineServer.new.perform ENV.fetch('ROVOS_PORT', 3000)
end

handler = Rack::Handler::Thin

class RackApp
  def call(env)
    # req = Rack::Request.new(env)
    [200, {"Content-Type" => "text/plain"}, "Hello from Rack"]
  end
end

handler.run RackApp.new, Port: 8080
