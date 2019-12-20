# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

# Utils to work with data (hex, bin)
# * `hex` - Человекочитаемая строка с HEX-значениями. Например:  "12FA"
# * `bin` - Строка в которой каждый симлов - байт. Например: "\x98\x98"
#
class Utils
  # @example
  #   hex_to_bin("AB98") # => "\xAB\x98".force_encoding('ASCII-8BIT')
  def self.hex_to_bin(hex)
    [hex].pack('H*').unpack('C*').pack('c*')
  end

  # @example
  #   bin_to_hex("\xAB\x98") # => "AB98"
  def self.bin_to_hex(bin)
    return if bin.nil?

    bin.unpack1('H*').upcase
  end

  # @example
  #   convert_hex_endian('05F62F23') # => '232FF605'.force_encoding('ASCII-8BIT')
  #   convert_hex_endian('05F6') # => 'F605'.force_encoding('ASCII-8BIT')
  def self.convert_hex_endian(hex)
    return if hex.nil?

    case hex.length
    when 8
      [hex].pack('H*').unpack('N*').pack('V*').unpack1('H*').upcase
    when 4
      [hex].pack('H*').unpack('n*').pack('v*').unpack1('H*').upcase
    else
      raise "Unsupported hex string length (#{hex}) #{hex.length}"
    end
  end

  # @example
  #   decimal_to_hex(100020003, 8) # => '05F62F23'
  #   decimal_to_hex(0x4377)       # => '4377'
  def self.decimal_to_hex(int, size = 4)
    return if int.nil?

    format("%0#{size}X", int).upcase
  end

  def self.bin_to_decimal(bin)
    return if bin.nil?

    bin_to_hex(bin).to_i(16)
  end

  # @param byte1 [Decimal] ID of command
  #   2 - включить кресло на указанное время.
  #   4 - получить статус кресла.
  # @param byte2 [Decimal] Второй аргумент (время в минутах если команда на включение)
  # @return [Binary]
  #
  # @example binary data
  #   Utils.word_from_bytes(2, 10) # => 0x020A
  def self.word_from_bytes(byte1, byte2 = 0)
    [byte1, byte2].pack('c*').unpack1('n')
  end

  # @example
  #   Utils.bytes_from_word(0x020A) # => [2,10]
  def self.bytes_from_word(word)
    [word].pack('S>').unpack('C*')
  end
end
