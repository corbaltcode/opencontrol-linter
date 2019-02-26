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
                            Specify component files should be checked. Defaults
                            to true. Searches ./**/component.yaml or the search
                            you optionally specify.
      -n, --certifications
                            Specify certification (eg FISMA high)files should be
                            checked. Defaults to true. Searches
                            ./certifications/*.yaml or the search you optionally
                            specify.
      -s, --standards
                            Specify standard files (eg NIST 800.53) should be
                            checked. Defaults to true. Searches
                            ./standards/*.yaml or the search you optionally
                            specify.
      -o, --opencontrols, --opencontrol
                            Specify opencontrol file or files should be
                            checked. Defaults to true. Searches
                            ./opencontrol.yaml or the search you optionally
                            specify.
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

    CONFIG_FILENAME = './opencontrol.yaml'.freeze

    PRESET = {
      action: :run,
      targets: {
        components: [
          './components/**/component.yaml'
        ],
        standards: [
          './standards/*.yaml'
        ],
        certifications: [
          './certifications/*.yaml'
        ],
        opencontrols: [
          './opencontrol.yaml'
        ]
      }
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

    def self.add_target(type, opts, specification)
      if use_default_pattern?(opts, type)
        specification[:targets][type] = default_spec[:targets][type]
      elsif opts[type].is_a?(String)
        specification[:targets][type] = [opts[type]]
      end
    end

    def self.use_default_pattern?(opts, type)
      # this is set when the user uses a flag on the command line but doesnt
      # add a specific file pattern - this way the user can restrict to just
      # one type
      opts[type] == true
    end

    def self.opencontrol_yaml_present?
      File.exist?(CONFIG_FILENAME)
    end

    def self.construct_defaults(config)
      spec = {
        action: :run,
        targets: {}.merge(PRESET[:targets]).merge(config[:targets])
      }

      expand_components_filenames(spec)
    end

    def self.load_config_from_yaml
      yaml_config = YAML.load_file(CONFIG_FILENAME)
      yaml_config = Hash[yaml_config.map { |(k, v)| [k.to_sym, v] }]
      {
        action: :run,
        targets: yaml_config.select do |k, _v|
                   %i[components standards certifications].include?(k)
                 end
      }
    end

    def self.expand_components_filenames(spec)
      # the config file usually omits the component files full filename
      spec[:targets][:components] = spec[:targets][:components].collect do |f|
        f += '/component.yaml' if File.directory?(f)
        f
      end
      spec
    end

    def self.default_spec
      if opencontrol_yaml_present?
        construct_defaults(load_config_from_yaml)
      else
        PRESET
      end
    end

    def self.should_lint?(opts)
      !(opts[:version] || opts[:help])
    end

    def self.all_targets_empty?(specification)
      specification[:targets][:components].empty? &&
        specification[:targets][:standards].empty? &&
        specification[:targets][:certifications].empty? &&
        specification[:targets][:opencontrols].empty?
    end

    def self.all_selected?(opts, specification)
      opts[:all] || all_targets_empty?(specification)
    end

    def self.use_default?(opts, specification)
      all_selected?(opts, specification) && should_lint?(opts)
    end

    def self.parse_args(arguments)
      opts = Rationalist.parse(arguments, alias: ALIASES)
      specification = {
        action: :run,
        targets: Opencontrol::Linter.empty_targets
      }
      specification[:action] = :version                     if opts[:version]
      specification[:action] = :help                        if opts[:help]
      add_target(:components, opts, specification)     if opts[:components]
      add_target(:standards, opts, specification)      if opts[:standards]
      add_target(:certifications, opts, specification) if opts[:certifications]
      add_target(:opencontrols, opts, specification)   if opts[:opencontrols]
      specification = default_spec if use_default?(opts, specification)
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
