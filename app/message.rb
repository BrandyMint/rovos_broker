# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

require 'lib/utils'

# ValueObject message
#
class Message
  HEADER = 0x4377 # Income as 0xDBEF

  # Store as decimal
  attr_accessor :header
  attr_accessor :msg1
  attr_accessor :msg2
  attr_accessor :machine_id

  def initialize(header: HEADER, msg1:, msg2: 0, machine_id:)
    @header = header
    raise "Unknown header #{Utils.decimal_to_hex header} (#{Utils.decimal_to_hex HEADER})" unless header == HEADER

    @msg1 = msg1
    @msg2 = msg2
    @machine_id = machine_id
  end

  def inspect
    to_s + ' (' + Utils.bin_to_hex(bin) + ')'
  end

  def to_s
    [
      '0x' + Utils.decimal_to_hex(header),
      '0x' + Utils.decimal_to_hex(msg1),
      '0x' + Utils.decimal_to_hex(msg2),
      'i' + machine_id.to_s
    ].join(' ')
  end

  # @example
  #   Message.new(msg1: 0x0204, msg2: 0, machine_id: 100020003).bin.length # => 10
  def bin
    [
      decimal_to_bin(header),
      decimal_to_bin(msg1),
      decimal_to_bin(msg2),
      decimal_to_bin(machine_id, 8)
    ].join
  end

  private

  def decimal_to_bin(decimal, size = 4)
    Utils.hex_to_bin(
      Utils.convert_hex_endian(
        Utils.decimal_to_hex(decimal, size)
      )
    )
  end
end
