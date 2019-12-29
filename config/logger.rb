# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

# Logger
#
require 'logger'
if ENV['RACK_ENV'] == 'development'
  $logger = Logger.new(STDERR)
else
  log_file = File.expand_path('../log/rovos.log', __dir__)
  puts "Write log to #{log_file}"
  $logger = Logger.new(log_file)
end

$logger.level = Logger::DEBUG
original_formatter = Logger::Formatter.new
$logger.formatter = proc { |severity, datetime, progname, msg|
  # Time.now.strftime("%d/%b/%Y:%H:%M:%S %z")
  original_formatter.call(severity, datetime, progname, msg.dump)
}
