require 'kwalify'
require 'yaml'
require 'opencontrol'
require 'rationalist'
require 'colorize'
require 'pp'

# frozen_string_literal: true

module Opencontrol
  # This module holds the Opencontrol Linter Command Line Interface.
  module CLI
    USAGE_TEXT = <<USAGE_TEXT.freeze
      usage: opencontrol-linter

      optional arguments:
        -h, --help            show this help message and exit
        -c, --components
                              Specify component files should be checked. Defaults to
                              true. Searches ./**/component.yaml or the search you
                              optionally specify.
        -n, --certifications
                              Specify certification (eg FISMA high)files should be
                              checked. Defaults to true. Searches
                              ./certifications/*.yaml or the search you optionally
                              specify.
        -s, --standards
                              Specify standard files (eg NIST 800.53) should be
                              checked. Defaults to true. Searches ./standards/*.yaml
                              or the search you optionally specify.
        -o, --opencontrols, --opencontrol
                              Specify opencontrol file or files should be
                              checked. Defaults to true. Searches ./opencontrol.yaml
                              or the search you optionally specify.
        -a, --all             Run all types of validations (this is the default).
        -v, --version         Show the version of this utility.

      Usage examples:

          # lint all components, standards and certifications in the current directory
           opencontrol-linter

          # lint all components subdir components
           opencontrol-linter --components './components/**/component.yaml'

          # lint all standards files found
           opencontrol-linter --standards

          # lint one component
           opencontrol-linter --components './components/AU_policy/component.yaml'
USAGE_TEXT

    DEFAULT_SPECIFICATION = {
      action: :run,
      targets: [
        {
          type: :components,
          pattern: './components/**/component.yaml'
        },
        {
          type: :standards,
          pattern: './standards/*.yaml'
        },
        {
          type: :certifications,
          pattern: './certifications/*.yaml'
        },
        {
            type: :opencontrols,
            pattern: './opencontrol.yaml'
        }
      ]
    }.freeze

    def self.show_help
      puts USAGE_TEXT
      0 # exit with no error
    end

    def self.show_version
      puts 'Opencontrol linter version: v' + Opencontrol::Version.version
      puts 'CMS 2019 Adrian Kierman '
      0 # exit with no error
    end

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

    def self.add_target(type, opts, specification)
      # pick a reasonable default
      use_defaults = false
      use_defaults = default_pattern_for_type(type) if opts[type] == true
      specification[:targets].push(
        type: type,
        pattern: use_defaults || opts[type]
      )
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

    def self.should_lint?(opts)
      !(opts[:version] || opts[:help])
    end

    def self.all_targets_selected?(opts, specification)
      opts[:all] || specification[:targets].empty?
    end

    def self.use_default?(opts, specification)
      all_targets_selected?(opts, specification) && should_lint?(opts)
    end

    ALIASES = {
      components: %w[component c],
      standards: %w[standard s],
      certifications: %w[certification n],
      opencontrols: %w[opencontrol o],
      all: 'a',
      help: 'h',
      version: 'v'
    }.freeze

    def self.parse_args(arguments)
      opts = Rationalist.parse(arguments, alias: ALIASES)
      specification = {
        action: :run,
        targets: []
      }
      specification[:action] = :version                     if opts[:version]
      specification[:action] = :help                        if opts[:help]
      add_target(:components, opts, specification)     if opts[:components]
      add_target(:standards, opts, specification)      if opts[:standards]
      add_target(:certifications, opts, specification) if opts[:certifications]
      add_target(:opencontrols, opts, specification)   if opts[:opencontrols]
      specification = DEFAULT_SPECIFICATION if use_default?(opts, specification)
      specification
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

    def self.run_with_args(args)
      specification = parse_args(args)
      exit(run(specification)) if specification[:action] == :run
      show_version             if specification[:action] == :version
      show_help                if specification[:action] == :help
    end
  end
end
