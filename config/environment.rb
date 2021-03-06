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

require_relative './logger'
require_relative './influx'

require_relative '../app/message'
require_relative '../app/machine_connection'
require_relative '../app/machine_server'
require_relative '../app/machines'
