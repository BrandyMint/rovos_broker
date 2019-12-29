# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

require 'eventmachine'
require 'socket'

# Connection to specific ROVOS machine by TCP
#
class MachineConnection < EventMachine::Connection
  Error = Class.new StandardError

  HEADER = 0x4377 # Income as 0xDBEF
  attr_accessor :connections

  attr_reader :machine_id
  attr_reader :channel
  attr_reader :last_activity
  attr_reader :connected_at
  attr_reader :client

  def initialize
    @channel = EventMachine::Channel.new
  end

  def post_init
    @connected_at = Time.now
    port, ip = Socket.unpack_sockaddr_in(get_peername)
    @client = "TCP[rovos]://#{ip}:#{port}"

    log 'Connected'
  end

  def receive_data(data)
    @last_activity = Time.now
    message = load_message decode data
    log "Received 0x#{Utils.bin_to_hex data} as #{message}"
    notify_influx
    save_machine_id message
    channel&.push message
  rescue Error => e
    log "Wrong message header #{e}"
  end

  def unbind
    log 'Close connecition'
    return if machine_id.nil?

    log "Delete machine #{machine_id} from connections list"
    connections.delete_pair machine_id, self
  end

  def send_message(message)
    message.machine_id = machine_id
    log "Send #{Utils.bin_to_hex message.bin} as #{message}"
    send_data decode message.bin
    message
  end

  def build_message(state:, work_time: 0, time_left: 0)
    Message.new(
      header: HEADER,
      state: state,
      work_time: work_time,
      time_left: time_left,
      machine_id: machine_id
    )
  end

  private

  attr_reader :conn, :addr

  def validate_header!(header)
    return if header == HEADER

    raise Error, "Unknown header #{Utils.decimal_to_hex header} (#{Utils.decimal_to_hex HEADER})"
  end

  def load_message(bin)
    validate_header! header = Utils.bin_to_decimal(bin[0, 2])

    msg1 = Utils.bin_to_decimal(bin[2, 2])
    Message.new(
      header: header,
      state: Utils.bytes_from_word(msg1).first,
      work_time: Utils.bytes_from_word(msg1).last,
      time_left: Utils.bin_to_decimal(bin[4, 2]),
      machine_id: Utils.bin_to_decimal(bin[6, 4])
    )
  end

  def notify_influx
    now = Time.now
    unless @last_influx_at.nil?
      data = {
        tags: { client: client, machine_id: machine_id },
        values: { period: now - @last_influx_at }
      }
      $influx.write_point 'ping', data
    end
    @last_influx_at = Time.now
  end

  def log(message)
    $logger.debug "#{client}: #{message}"
  end

  def save_machine_id(message)
    if machine_id
      return if machine_id == message.machine_id

      raise "Oops! Machine ID is changed #{machine_id} <> #{message.machine_id}."
    end

    @machine_id = message.machine_id
    log "Add machine with #{machine_id} to online list"

    close_parallel_connection
  end

  def close_parallel_connection
    old_connection = connections.get_and_set machine_id, self
    return if old_connection.nil?

    log "Replace old_connection #{old_connection.client} #{old_connection.machine_id}"
    old_connection.close_connection
  end

  KEY = 152
  def decode(bin)
    bin.bytes.map { |b| b ^ KEY }.pack('c*')
  end
end
