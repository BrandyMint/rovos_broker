# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

require 'socket'

# ROVOS machine broker server
#
class MachineServer
  def perform(port:, connections_map:)
    puts "Start ROVOS machine server. Listening port #{port}"

    Socket.tcp_server_loop(port) do |conn, addr|
      machine = MachineConnection.new(conn, addr)
      add_machine = ->(id) { connections_map.put_if_absent id, machine }
      remove_machine = ->(id) { connections_map.delete id }
      machine.perform(add_machine: add_machine, remove_machine: remove_machine)
      connections_map
    end
  end
end
