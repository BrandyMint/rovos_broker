class MachineServer
  attr_reader :connections, :signature

  def initialize
    @connections = Concurrent::Map.new
  end

  def start(port)
    puts "Start TCP (Rovos) server listening on #{port}"
    # p Socket.unpack_sockaddr_in( EM.get_sockname( server.signature ))
    @signature = EventMachine.start_server('0.0.0.0', port, MachineConnection) do |con|
      con.server = self
    end
  end

  def stop
    EventMachine.stop_server(@signature)

    unless wait_for_connections_and_stop
      # Still some connections running, schedule a check later
      EventMachine.add_periodic_timer(1) { wait_for_connections_and_stop }
    end
  end

  def wait_for_connections_and_stop
    if @connections.empty?
      EventMachine.stop
      true
    else
      puts "Waiting for #{@connections.size} connection(s) to finish ..."
      false
    end
  end
end


