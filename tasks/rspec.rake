begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)

  task :default => :spec
rescue LoadError
   warn e.message
   warn 'Run `bundle install` to install missing gems'
   exit e.status_code
end
