# frozen_string_literal: true

# Copyright (c) 2019 Danil Pismenny <danil@brandymint.ru>

require 'yard/doctest/rake'

require_relative 'config/application'

task :environment do
  require File.expand_path('config/environment', __dir__)
end

YARD::Doctest::RakeTask.new do |task|
  task.doctest_opts = %w[-v]
  task.pattern = '**/*.rb'
end

require 'rubocop/rake_task'

RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ['--display-cop-names']
  t.fail_on_error = true
end

task default: %i[rubocop yard:doctest]
