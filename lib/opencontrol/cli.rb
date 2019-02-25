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

    ALIASES = {
      components: %w[component c],
      standards: %w[standard s],
      certifications: %w[certification n],
      opencontrols: %w[opencontrol o],
      all: 'a',
      help: 'h',
      version: 'v'
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

    def self.targets_for_type(type, specification)
      specification[:targets].select { |t| t[:type] == type }
    end

    def self.default_targets_for_type(type)
      targets_for_type(type, DEFAULT_SPECIFICATION)
    end

    def self.default_pattern_for_type(type)
      targets_for_type(type, DEFAULT_SPECIFICATION).first[:pattern]
    end

    def self.add_target(type, opts, specification)
      if opts[type] == true
        # use the defaults supplied
        puts "Adding target for #{type} via constructed defaults"
        targets_for_type(type, construct_default_spec).each do |target|
          specification[:targets].push target
        end
      else
        puts "Adding target for #{type} via preconfigured defaults"
        if opts[type].is_a?(String)
          specification[:targets].push(
              type: type,
              pattern: opts[type]
          )
        end
      end
    end

    def self.construct_default_spec
      targets = []
      if File.exists?('./opencontrol.yaml')
        puts "Using search paths from './opencontrol.yaml"
        opencontrol_yaml_hash = YAML.load_file('./opencontrol.yaml')
        puts(opencontrol_yaml_hash)
        [:components, :standards, :certifications].each do |type|
          puts "Opencontrol.yaml contained #{opencontrol_yaml_hash[type.to_s].pretty_inspect} for type #{type}"

          if opencontrol_yaml_hash[type.to_s]
            puts "Using search paths defined in opencontrol.yaml for #{type}"
            opencontrol_yaml_hash[type.to_s].each do |pattern|
              if type==:components and File.directory?(pattern)
                pattern = pattern + '/component.yaml'
              end
              targets.push(
                  type: type,
                  pattern: pattern
              )
            end
          else
            puts "Using default preconfigured paths defined for #{type}"
            default_targets_for_type(type).each do |target|
              targets.push(target)
            end
          end
        end
      else
        puts "Using default search paths"
        targets = DEFAULT_SPECIFICATION[:targets]
      end
      {
          action: :run,
          targets: targets
      }
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
      if use_default?(opts, specification)
        specification = construct_default_spec
      end

      specification
    end

    def self.run_with_args(args)
      specification = parse_args(args)
      result = 0
      case specification[:action]
      when :run
        result = Opencontrol::Linter.run(specification)
      when :version
        result = show_version
      when :help
        result = show_help
      end
      exit(result)
    end
  end
end
