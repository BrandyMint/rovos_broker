# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

# frozen_string_literal: true

ENV['RACK_ENV'] ||= 'development'

require File.expand_path('application', __dir__)

Dir[File.join(__dir__, 'initializers', '*.rb')].each { |file| require file }

require 'rubygems'
require 'bundler/setup'

require 'json'
require 'semver'
AppVersion = SemVer.find

require_relative '../app/message'
require_relative '../app/machine_connection'
require_relative '../app/machine_server'
require_relative '../app/machines'

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
