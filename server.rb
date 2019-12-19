#!/usr/bin/env ruby
# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

require File.expand_path('config/environment', __dir__)
require 'socket'

PORT = ENV.fetch('ROVOS_PORT', 3000)

puts "Start vanpay.ru server. Listening port #{PORT}"

Socket.tcp_server_loop(PORT) do |conn, addr|
  machine = MachineConnection.new(conn, addr).perform
  puts machine
end
