# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

# Connection to specific machine
#
class MachineConnection
  MESSAGE_LENGTH = 10

  attr_reader :machine_id

  # @param conn [Socket]
  # @param addr
  # @param connections_map [Concurrent::Map]
  def initialize(conn, addr)
    @conn = conn
    @addr = addr
  end

  def perform(add_machine:, remove_machine:)
    log 'Connected'
    Thread.new do
      loop do
        bin = conn.recv(MESSAGE_LENGTH)
        message = create_message decode bin
        if machine_id.nil?
          @machine_id = message.machine_id
          log "Add machine to the list #{machine_id}"
          add_machine.call machine_id
        end
        log "Received 0x#{Utils.bin_to_hex bin} as #{message}"
        # send_message OUTCOME_MESSAGE if count == 2
      end
    rescue EOFError
      conn.close
      log 'Disconnected with EOFError'
    rescue StandardError => e
      log "Disconnected with #{e}"
    ensure
      remove_machine.call machine_id unless machine_id.nil?
      log 'Close connection'
    end
  end

  def status
    return if machine_id.nil?
    log "Send status request"
    send_message Message.new(msg1: 0x0400, machine_id: machine_id)
    'send status request'
  end

  def start(minutes = 10)
    return if machine_id.nil?
    # TODO minutes
    log "Start machine for #{minutes}"
    send_message Message.new(msg1: 0x020A, machine_id: machine_id)
    "started for #{minutes} minutes"
  end

  private

  attr_reader :conn, :addr

  def create_message(bin)
    Message.new(
      header: Utils.bin_to_decimal(bin[0, 2]),
      msg1: Utils.bin_to_decimal(bin[2, 2]),
      msg2: Utils.bin_to_decimal(bin[4, 2]),
      machine_id: Utils.bin_to_decimal(bin[6, 4])
    )
  end

  def log(message)
    client = "#{addr.ip_address}:#{addr.ip_port}"
    puts "#{Time.now}: #{client} #{message}"
  end

  def send_message(message)
    log "Send #{Utils.bin_to_hex message.bin} as #{message}"
    conn.print(decode(message.bin))
  end

  KEY = 152
  def decode(bin)
    bin.bytes.map { |b| b ^ KEY }.pack('c*')
  end
end
