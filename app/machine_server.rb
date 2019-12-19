# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

require 'socket'

# ROVOS machine broker server
#
class MachineServer
  def perform(port)
    puts "Start ROVOS machine server. Listening port #{port}"

    Socket.tcp_server_loop(port) do |conn, addr|
      machine = MachineConnection.new(conn, addr).perform
    end
  end
end
