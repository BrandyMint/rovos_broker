# Утилиты для работы с данными
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
    bin.unpack("H*").first.upcase
  end

  # @example
  #   convert_hex_endian('05F62F23') # => '232FF605'.force_encoding('ASCII-8BIT')
  #   convert_hex_endian('05F6') # => 'F605'.force_encoding('ASCII-8BIT')
  def self.convert_hex_endian(hex)
    case hex.length
    when 8
      [hex].pack('H*').unpack('N*').pack('V*').unpack('H*').first.upcase
    when 4
      [hex].pack('H*').unpack('n*').pack('v*').unpack('H*').first.upcase
    else
      raise "Unsupported hex string length (#{hex}) #{hex.length}"
    end
  end

  # @example
  #   decimal_to_hex(100020003, 8) # => '05F62F23'
  #   decimal_to_hex(0x4377)       # => '4377'
  def self.decimal_to_hex(int, size = 4)
    ("%0#{size}X" % int).upcase
  end

  def self.bin_to_decimal(bin)
    bin_to_hex(bin).to_i(16)
  end
end

 #Берет номер машины в int и возвращает декодированный
 #litte-ending слово в hex

 #100020003 (в инете говорят это 05F62F23)
 #=> bbb7 6e9d
 #Осталось выяснить как из 100020003 получить 05F62F23 в ruby
#KEY = 152
#def self.test(decimal)
  #hex = decimal_to_hex decimal
  #hex = convert_hex_endian hex
  #bin = hex_to_bin hex
  #bin = bin.bytes.map { |b| b ^ 152 }.pack('c*')
  #bin_to_hex bin
#end

