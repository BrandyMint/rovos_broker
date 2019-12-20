# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

require 'lib/utils'

# ValueObject message
#
class Message
  include ShallowAttributes

  attribute :header,     Numeric  # word
  attribute :state,      Numeric  # byte
  attribute :work_time,  Numeric  # byte
  attribute :time_left,  Numeric  # word
  attribute :machine_id, Numeric  # long

  def inspect
    to_s + ' (' + Utils.bin_to_hex(bin) + ')'
  end

  def to_s
    [
      '0x' + Utils.decimal_to_hex(header),
      '0x' + Utils.decimal_to_hex(msg1),
      '0x' + Utils.decimal_to_hex(time_left),
      'i' + machine_id.to_s
    ].join(' ')
  end

  # @example
  #   Message.new(msg1: 0x0204, time_left: 0, machine_id: 100020003).bin.length # => 10
  def bin
    [
      decimal_to_bin(header),
      decimal_to_bin(msg1),
      decimal_to_bin(time_left),
      decimal_to_bin(machine_id, 8)
    ].join
  end

  private

  def msg1
    Utils.word_from_bytes(state, work_time)
  end

  def decimal_to_bin(decimal, size = 4)
    Utils.hex_to_bin(
      Utils.convert_hex_endian(
        Utils.decimal_to_hex(decimal, size)
      )
    )
  end
end
