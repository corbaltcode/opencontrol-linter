# frozen_string_literal: true

require 'kwalify'

module Opencontrol
  # This module holds the Opencontrol Linter detailed issue messages.
  module Messages
    def self.detail(issue)
      case issue.error_symbol
      when :enum_notexist
        <<-MESSAGE
        At:           YAML path #{issue.path}.
        Message:      #{issue.message}
        Expected:     one of #{issue.rule.enum}.
        Actual:       The value '#{issue.value}' was found.
        To fix this:  Use one of #{issue.rule.enum}
                      instead of the value '#{issue.value}'
        MESSAGE
      when :key_undefined
        <<-MESSAGE
        At:           YAML path #{issue.path}.
        Expected:     A key allowed by the schema.
        Actual:       A key was found that is not defined in the schema (#{issue.path}).
        To fix this:  Its possible the key found is a typo,
                      Remove #{issue.path} or correct the key.
        MESSAGE
      else
        <<-MESSAGE
        At:           YAML path #{issue.path}.
        Message:      #{issue.message}
        MESSAGE
      end
    end

    def self.verbose(issue)
      <<-MESSAGE
        At:           YAML path #{issue.path}.
        Message:      #{issue.message}
        Rule:         #{issue.rule.to_yaml}
        Value:        #{issue.value}
        Symbol:       #{issue.error_symbol}
      MESSAGE
    end
  end
end
