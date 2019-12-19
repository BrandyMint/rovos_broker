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
    port, ip = Socket.unpack_sockaddr_in(get_peername)
    puts "#{Time.now}: #{port}:#{ip} #{message}"
  end

  def send_message(message)
    log "Send #{Utils.bin_to_hex message.bin} as #{message}"
    send_data decode message.bin
    # send_data ">>>you sent: #{data}"
    # close_connection if data =~ /quit/i
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
