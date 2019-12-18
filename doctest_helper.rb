# frozen_string_literal: true
# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

require_relative 'config/environment'
require 'minitest/reporters'
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(:color => true)]
