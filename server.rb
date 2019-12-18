#!/usr/bin/env ruby
# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

require File.expand_path('config/environment', __dir__)

PORT = 3000
MESSAGE_LENGTH = 10
MACHINE_ID = 100_020_003

puts "Start vanpay.ru server. Listening port #{PORT}"

KEY = 152

def decode(bin)
  bin.bytes.map { |b| b ^ KEY }.pack('c*')
end

outcome_message = Message.new(msg1: 0x0204, msg2: 0, machine_id: MACHINE_ID)

def send_message(client, conn, message)
  puts "#{client} #{Time.now} : send #{Utils.bin_to_hex message.out} as #{message}"
  conn.print(s)
end

Socket.tcp_server_loop(PORT) do |conn, addr|
  # conn <Socket>
  Thread.new do
    client = "#{addr.ip_address}:#{addr.ip_port}"
    puts "Client #{client} is connected"

    loop do
      bin = conn.recv(MESSAGE_LENGTH)
      message = Message.new(
        header: Utils.bin_to_decimal(bin[0, 2]),
        msg1: Utils.bin_to_decimal(bin[2, 2]),
        msg2: Utils.bin_to_decimal(bin[4, 2]),
        machine_id: Utils.bin_to_decimal(bin[6, 4])
      )
      puts "#{client} #{Time.now} : receiver #{Utils.bin_to_hex bin} as #{message}"

      sent_message client, conn, outcome_message
    end
  rescue EOFError
    conn.close
    puts "Client #{client} has disconnected"
  end
end
