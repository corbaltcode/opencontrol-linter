# frozen_string_literal: true

$LOAD_PATH << File.expand_path('exe', __dir__)

require 'simplecov'
SimpleCov.start

require 'powerpack/string/strip_margin'
require 'powerpack/string/strip_indent'
require 'pry'
# Disable colors in specs
require 'rainbow'
Rainbow.enabled = false

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.register_ordering(:global, &:reverse)
end
