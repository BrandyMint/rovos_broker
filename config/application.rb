# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

require_relative 'boot'

Bundler.require :default, ENV['RACK_ENV'] || 'development'
