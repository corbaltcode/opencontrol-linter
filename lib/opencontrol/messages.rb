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
        Actual:       A key was found that is not defined in the schema
                      (#{issue.path}).
        To fix this:  Its possible the key found is a typo,
                      Remove #{issue.path} or correct the key.
        MESSAGE
      when :schema_files_not_found_issue
        <<-MESSAGE
        At:           File path #{issue.path}.
        Expected:     A valid schema version that is currently supported.
        Actual:       No valid schema file found
                      (#{issue.value}).
        To fix this:  Either provide a valid schema file or adjust the schema
                      version to a known schema. See
                      https://github.com/adriankierman/opencontrol-linter
                      or
                      https://github.com/opencontrol/schemas/tree/master/kwalify
                      for schemas.
                      Typically you will want to correct the schema
                      version number indicated in your file at
                      #{issue.path}.
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
