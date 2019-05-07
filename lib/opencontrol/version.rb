# frozen_string_literal: true

module Opencontrol
  # This module holds the Opencontrol Linter version information.
  module Version
    STRING = '0.1.6'.freeze

    MSG = '%<version>s (using Parser %<parser_version>s, running on ' \
          '%<ruby_engine>s %<ruby_version>s %<ruby_platform>s)'.freeze

    def self.version(debug = false)
      if debug
        require 'kwalify'
        format(MSG, version: STRING, parser_version: Kwalify::VERSION,
                    ruby_engine: RUBY_ENGINE, ruby_version: RUBY_VERSION,
                    ruby_platform: RUBY_PLATFORM)
      else
        STRING
      end
    end
  end
end
