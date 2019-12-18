require 'yard/doctest/rake'

YARD::Doctest::RakeTask.new do |task|
  task.doctest_opts = %w[-v]
  # task.pattern = 'lib/**/*.rb'
  task.pattern = '*.rb'
end

task :default => ['yard:doctest']
