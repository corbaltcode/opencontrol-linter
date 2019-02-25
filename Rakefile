# frozen_string_literal: true

# For code coverage measurements to work properly, `SimpleCov` should be loaded
# and started before any application code is loaded.
require 'simplecov' if ENV['COVERAGE']
require 'rake'

Dir['tasks/**/*.rake'].each { |t| load t }
