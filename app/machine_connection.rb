# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

require 'eventmachine'
require 'socket'

# Connection to specific ROVOS machine by TCP
#
class MachineConnection < EventMachine::Connection
  Error = Class.new StandardError

  HEADER = 0x4377 # Income as 0xDBEF
  attr_accessor :server

  attr_reader :machine_id
  attr_reader :channel
  attr_reader :last_activity

  def initialize
    @channel = EventMachine::Channel.new
  end

  def post_init
    log "Connected"
  end

  def receive_data(data)
    @last_activity = Time.now
    message = load_message decode data
    log "Received 0x#{Utils.bin_to_hex data} as #{message}"
    save_machine_id message
    channel.push message
  rescue Error => err
    log "Wrong message header #{err}"
  end

  def unbind
    log 'Close connecition'
    server.connections.delete(machine_id) unless machine_id.nil?
  end

  def send_message(message)
    message.machine_id = machine_id
    log "Send #{Utils.bin_to_hex message.bin} as #{message}"
    send_data decode message.bin
    message
  end

  def build_message(state:, work_time: 0, time_left: 0)
    Message.new(
      header:     HEADER,
      state:      state,
      work_time:  work_time,
      time_left:  time_left,
      machine_id: machine_id
    )
  end

  private

  attr_reader :conn, :addr

  def load_message(bin)
    header = Utils.bin_to_decimal(bin[0, 2])
    raise Error, "Unknown header #{Utils.decimal_to_hex header} (#{Utils.decimal_to_hex HEADER})" unless header == HEADER
    msg1 = Utils.bin_to_decimal(bin[2, 2])
    Message.new(
      header:     header,
      state:      Utils.bytes_from_word(msg1).first,
      work_time:  Utils.bytes_from_word(msg1).last,
      time_left:  Utils.bin_to_decimal(bin[4, 2]),
      machine_id: Utils.bin_to_decimal(bin[6, 4])
    )
  end

  def client
    @client ||= begin
                  port, ip = Socket.unpack_sockaddr_in(get_peername)
                  "TCP[rovos]://#{ip}:#{port}"
                end
  end

  def log(message)
    puts "#{Time.now}: #{client} #{message}"
  end

  def save_machine_id(message)
    if machine_id.nil?
      @machine_id = message.machine_id
      log "Add machine with #{machine_id} to online list"
      server.connections.put_if_absent machine_id, self
    elsif machine_id != message.machine_id
      raise "Oops! Machine ID is changed #{machine_id} <> #{message.machine_id}."
    end
  end

  KEY = 152
  def decode(bin)
    bin.bytes.map { |b| b ^ KEY }.pack('c*')
  end
end
