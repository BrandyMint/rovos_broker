# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

require 'eventmachine'
require 'socket'

# Connection to specific machine
#
class MachineConnection < EventMachine::Connection
  Error = Class.new StandardError

  HEADER = 0x4377 # Income as 0xDBEF
  attr_accessor :server
  attr_reader :machine_id
  attr_accessor :query

  def initialize
  end

  def post_init
    log "Connection"
  end

  def receive_data(data)
    message = load_message decode data
    log "Received 0x#{Utils.bin_to_hex data} as #{message}"
    query.push message unless query.nil? # message.msg1 == 0x0400
    save_machine_id message
  rescue Message::Error => err
    log "Wrong message header #{err}"
  end

  def unbind
    log 'Close connecition'
    server.connections.delete(machine_id)
  end

  # Устаналивает нужный режим работы машины
  #
  # @param state [Decimal] Requested to change machine's state to `state`
  # @param time [Decimal] Time to work in minutes (for state #2)
  def push(state, time)
    return if machine_id.nil?
    log "Push state `#{state}` with argument `#{time}`"
    send_message Message.new(msg1: Utils.word_from_bytes(state.to_i, time.to_i), machine_id: machine_id)
  end

  def send_message(message)
    message.machine_id = machine_id
    log "Send #{Utils.bin_to_hex message.bin} as #{message}"
    send_data decode message.bin
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

  def log(message)
    port, ip = Socket.unpack_sockaddr_in(get_peername)
    puts "#{Time.now}: #{port}:#{ip} #{message}"
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
