# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

# ROVOS TCP Server
class MachineServer
  WAIT_TO_STOP = ENV['RACK_ENV'] == 'development' ? 0 : 3

  attr_reader :connections, :signature

  def initialize
    @connections = Concurrent::Map.new
  end

  def start(port)
    $logger.info "Start Rovos tcp-server #{AppVersion} listening on #{port}"
    # p Socket.unpack_sockaddr_in( EM.get_sockname( server.signature ))
    @signature = EventMachine.start_server('0.0.0.0', port, MachineConnection) do |con|
      con.connections = connections
    end
  end

  def stop
    EventMachine.stop_server(@signature)

    return if wait_for_connections_and_stop

    # Still some connections running, schedule a check later
    EventMachine.add_periodic_timer(WAIT_TO_STOP) { wait_for_connections_and_stop }
  end

  def wait_for_connections_and_stop
    if @connections.empty?
      EventMachine.stop
      true
    else
      $logger.warn "Waiting for #{@connections.size} connection(s) to finish ..."
      false
    end
  end
end
