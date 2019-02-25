require 'kwalify'
require 'yaml'
require 'opencontrol'
require 'colorize'
require 'pp'

# frozen_string_literal: true

module Opencontrol
  # This module holds the Opencontrol Linter Command Line Interface.
  module Linter

    # @param [String] version
    def self.find_schema(type, version)
      dir = __dir__
      case type
      when :components
        "#{dir}/../../vendor/schemas/kwalify/component/v#{version}.yaml"
      when :standards
        "#{dir}/../../vendor/schemas/kwalify/standard/v#{version}.yaml"
      when :certifications
        "#{dir}/../../vendor/schemas/kwalify/certification/v#{version}.yaml"
      when :opencontrols
        "#{dir}/../../vendor/schemas/kwalify/opencontrol/v#{version}.yaml"
      else
        throw "Unknown type of schema specified #{type} " \
    "tried to get schema version #{version}"
      end
    end

    def self.load_schema(schema_file)
      ## load schema data
      # Kwalify::Yaml.load_file(schema_file)
      ## or
      YAML.load_file(schema_file)
    end

    def self.show_issues(issues, filename)
      if issues && !issues.empty?
        puts "✗ #{filename}".red
        issues.each do |issue|
          puts Opencontrol::Messages.detail(issue).yellow
        end
      else
        puts "✓ #{filename}".green
      end
    end

    def self.schema_for_document(type, document)
      version = document['schema_version'] || '1.0.0'
      schema_file = find_schema(type, version)
      load_schema(schema_file)
    end

    def self.targets_for_type(type, specification)
      specification[:targets].select { |t| t[:type] == type }
    end

    def self.default_pattern_for_type(type)
      targets_for_type(type, DEFAULT_SPECIFICATION).first[:pattern]
    end

    def self.validate(type, filename)
      ## load document
      # document = Kwalify::Yaml.load_file(filename)
      ## or
      document = YAML.load_file(filename)
      schema = schema_for_document(type, document)

      validator = Kwalify::Validator.new(schema)
      validator.validate(document)
    end

    def self.files_not_found_issue
      Kwalify::BaseError.new(
          'No validation files found for the pattern supplied. \
         Adding an issue to avoid failing silently.',
          nil,
          nil,
          nil,
          :linter_files_not_found_issue
      )
    end

    def self.validate_target(target)
      filenames = Dir[target[:pattern]]
      if filenames.empty?
        issues = [files_not_found_issue]
        show_issues(issues, target[:pattern])
        return issues
      end
      filenames.collect do |filename|
        issues = validate(target[:type], filename)
        show_issues(issues, filename)
        issues
      end
    end

    def self.validate_all(specification)
      specification[:targets].collect do |target|
        validate_target(target)
      end.flatten
    end

    def self.run(specification)
      issues = validate_all(specification)
      if !issues.empty?
        puts "Complete. #{issues.length} issues found.".red
      else
        puts 'Complete. No problems found.'.green
      end
      issues.length
    end
  end
end
