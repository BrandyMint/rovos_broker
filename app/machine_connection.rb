# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

require 'eventmachine'
require 'socket'

# Connection to specific machine
#
class MachineConnection < EventMachine::Connection
  attr_accessor :server
  attr_reader :machine_id

  def receive_data(data)
    message = create_message decode data

    save_machine_id message
    log "Received 0x#{Utils.bin_to_hex data} as #{message}"
  end

	def unbind
		puts 'Close connecition'
		server.connections.delete(machine_id)
	end

  def message(id:, arg:)
  end

  def get
    return if machine_id.nil?
    log "Send status request"
    @response_expectation = :status
    send_message Message.new(msg1: 0x0400, machine_id: machine_id)
    'send status request'
  end

  # Устаналивает нужный режим работы машины
  #
  # @param state_id [Decimal] Requested to change machine's state to `state_id`
  # @param time [Decimal] Time to work in minutes (for state #2)
  def set(state, time)
    return if machine_id.nil?
    log "Send command `#{state}` with argument `#{time}`"
    send_message Message.new(msg1: Utils.word_from_bytes(state.to_i, time.to_i), machine_id: machine_id)
    "Started for #{time} minutes (state=#{state})"
  end

  private

  attr_reader :conn, :addr

  def create_message(bin)
    Message.new(
      header:     Utils.bin_to_decimal(bin[0, 2]),
      msg1:       Utils.bin_to_decimal(bin[2, 2]),
      msg2:       Utils.bin_to_decimal(bin[4, 2]),
      machine_id: Utils.bin_to_decimal(bin[6, 4])
    )
  end

  def log(message)
    port, ip = Socket.unpack_sockaddr_in(get_peername)
    puts "#{Time.now}: #{port}:#{ip} #{message}"
  end

  def send_message(message)
    log "Send #{Utils.bin_to_hex message.bin} as #{message}"
    send_data decode message.bin
  end

  def save_machine_id(message)
    if machine_id.nil?
      @machine_id = message.machine_id
      log "Add machine with #{machine_id} to online list"
      server.connections.put_if_absent machine_id, self
    else
      raise "Machine ID is changed #{machine_id} <> #{message.machine_id}" unless machine_id.nil? || machine_id == message.machine_id
    end
  end

  KEY = 152
  def decode(bin)
    bin.bytes.map { |b| b ^ KEY }.pack('c*')
  end
end
