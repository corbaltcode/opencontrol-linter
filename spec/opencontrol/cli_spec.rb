# frozen_string_literal: true

require 'timeout'
require 'opencontrol'

SPEC = {
  action: :run,
  targets: [
    {
      type: :components,
      pattern: '**/component.yaml'
    },
    {
      type: :standards,
      pattern: './standards/*.yaml'
    },
    {
      type: :certifications,
      pattern: './certifications/*.yaml'
    }
  ]
}.freeze

RSpec.describe 'Opencontrol Linter' do
  context 'when checking a correct file' do
    it 'returns 0 for valid components file' do
      specifications = [{
        action: :run,
        targets: [{ type: :components,
                    pattern: './spec/fixtures/no_issues/components/AU_policy/component.yaml' }]
      }]
      specifications.each  do |specification|
        expect(Opencontrol::CLI.run(specification)).to eq(0)
        expect { Opencontrol::CLI.run(specification) }.to output(/Complete. No problems found./).to_stdout
      end
    end

    it 'returns 0 for valid standards file' do
      specifications = [{
                          action: :run,
                          targets: [{ type: :standards,
                                      pattern: './spec/fixtures/no_issues/standards/FRIST-800-53.yaml' }]
                      }]
      specifications.each  do |specification|
        expect(Opencontrol::CLI.run(specification)).to eq(0)
        expect { Opencontrol::CLI.run(specification) }.to output(/Complete. No problems found./).to_stdout
      end
    end

    it 'returns 0 for valid components file' do
      specifications = [{
                            action: :run,
                            targets: [{ type: :certifications,
                                        pattern: './spec/fixtures/no_issues/certifications/FredRAMP-low.yaml' }]
                        }]
      specifications.each  do |specification|
        expect(Opencontrol::CLI.run(specification)).to eq(0)
        expect { Opencontrol::CLI.run(specification) }.to output(/Complete. No problems found./).to_stdout
      end
    end

    it 'returns 0 for valid opencontrol file' do
      specifications = [{
                            action: :run,
                            targets: [{ type: :opencontrols,
                                        pattern: './spec/fixtures/no_issues/opencontrol.yaml' }]
                        }]
      specifications.each  do |specification|
        expect(Opencontrol::CLI.run(specification)).to eq(0)
        expect { Opencontrol::CLI.run(specification) }.to output(/Complete. No problems found./).to_stdout
      end
    end
  end

  context 'when checking an incorrect file' do
    it 'checks a given file with faults and returns 1 for components file' do
      specification = {
        action: :run,
        targets: [{ type: :components,
                    pattern: './spec/fixtures/issues/components/AU_policy/component.yaml' }]
      }
      expect(Opencontrol::CLI.run(specification)).to eq(1)
      expect { Opencontrol::CLI.run(specification) }.to output(/Complete. 1 issues found./).to_stdout
    end
    it 'checks a given file with faults and returns 1 for standards file' do
      specification = {
          action: :run,
          targets: [{ type: :standards,
                      pattern: './spec/fixtures/issues/standards/FRIST-800-53.yaml' }]
      }
      expect(Opencontrol::CLI.run(specification)).to eq(1)
      expect { Opencontrol::CLI.run(specification) }.to output(/Complete. 1 issues found./).to_stdout
    end
    it 'checks a given file with faults and returns 1 for certifications file' do
      specification = {
          action: :run,
          targets: [{ type: :certifications,
                      pattern: './spec/fixtures/issues/certifications/FredRAMP-low.yaml' }]
      }
      expect(Opencontrol::CLI.run(specification)).to eq(1)
      expect { Opencontrol::CLI.run(specification) }.to output(/Complete. 1 issues found./).to_stdout
    end
    it 'checks a given file with faults and returns 1 for opencontrol file' do
      specification = {
          action: :run,
          targets: [{ type: :opencontrols,
                      pattern: './spec/fixtures/issues/opencontrol.yaml' }]
      }
      expect(Opencontrol::CLI.run(specification)).to eq(1)
      expect { Opencontrol::CLI.run(specification) }.to output(/Complete. 1 issues found./).to_stdout
    end
  end

  context 'when checking basic output' do
    it 'outputs a correct help string' do
      expect { Opencontrol::CLI.run_with_args(['--help']) }.to output(/usage: opencontrol-linter/).to_stdout
    end
    it 'outputs a correct version string' do
      expect { Opencontrol::CLI.run_with_args(['--version']) }.to output(/Opencontrol linter version/).to_stdout
    end
  end

  context 'when parsing command line arguments' do
    it 'specifies an action of :help when given the help flag' do
      s = Opencontrol::CLI.parse_args(['--help'])
      expect(s[:action]).to eq(:help)
      s = Opencontrol::CLI.parse_args(['-h'])
      expect(s[:action]).to eq(:help)
    end
    it 'specifies an action of :version when given the version flag' do
      s = Opencontrol::CLI.parse_args(['--version'])
      expect(s[:action]).to eq(:version)
      s = Opencontrol::CLI.parse_args(['-v'])
      expect(s[:action]).to eq(:version)
    end
    it 'specifies an action of :run when given no args or args for all' do
      [['--all'], ['-a'], ['']].each do |a|
        s = Opencontrol::CLI.parse_args(a)
        expect(s[:action]).to eq(:run)
        expect(s[:targets].length).to eq(4)
        expect(s).to eq(Opencontrol::CLI::DEFAULT_SPECIFICATION)
      end
    end
    it 'it specifies the correct target when asked to just run components' do
      [['--components'], ['--component'], ['-c']].each do |a|
        s = Opencontrol::CLI.parse_args(a)
        expect(s[:action]).to eq(:run)
        expect(s[:targets].length).to eq(1)
        expect(s[:targets][0][:type]).to eq(:components)
      end
    end
    it 'it specifies the correct target when asked to just run standards' do
      [['--standards'], ['--standard'], ['-s']].each do |a|
        s = Opencontrol::CLI.parse_args(a)
        expect(s[:action]).to eq(:run)
        expect(s[:targets].length).to eq(1)
        expect(s[:targets][0][:type]).to eq(:standards)
      end
    end
    it 'it specifies the correct target when asked to just run certifications' do
      [['--certifications'], ['--certification'], ['-n']].each do |a|
        s = Opencontrol::CLI.parse_args(a)
        expect(s[:action]).to eq(:run)
        expect(s[:targets].length).to eq(1)
        expect(s[:targets][0][:type]).to eq(:certifications)
      end
    end
    it 'it allows a custom target file for components' do
      f = './spec/fixtures/no_issues/components/AU_policy/component.yaml'
      [['--component', f]].each do |a|
        s = Opencontrol::CLI.parse_args(a)
        expect(s[:action]).to eq(:run)
        expect(s[:targets].length).to eq(1)
        expect(s[:targets][0][:type]).to eq(:components)
        expect(s[:targets][0][:pattern]).to eq(f)
      end
    end
    f = './spec/fixtures/no_issues/standards/FRIST-800-53.yaml'
    it 'it specifies the correct target when asked to just run standards' do
      [['--standards', f]].each do |a|
        s = Opencontrol::CLI.parse_args(a)
        expect(s[:action]).to eq(:run)
        expect(s[:targets].length).to eq(1)
        expect(s[:targets][0][:type]).to eq(:standards)
        expect(s[:targets][0][:pattern]).to eq(f)
      end
    end
    it 'it specifies the correct target when asked to just run certifications' do
      f = './spec/fixtures/no_issues/certifications/FredRAMP-low.yaml'
      [['--certifications', f]].each do |a|
        s = Opencontrol::CLI.parse_args(a)
        expect(s[:action]).to eq(:run)
        expect(s[:targets].length).to eq(1)
        expect(s[:targets][0][:type]).to eq(:certifications)
        expect(s[:targets][0][:pattern]).to eq(f)
      end
    end
  end
  context 'file checks on input' do
    it 'should emit a warning when no file is found to validate' do
      specification = {
        action: :run,
        targets: [{ type: :components,
                    pattern: './spec/fixtures/empty/**/component.yaml' }]
      }
      expect(Opencontrol::CLI.run(specification)).to eq(1)
      expect { Opencontrol::CLI.run(specification) }.to output(/Complete. 1 issues found./).to_stdout
    end
    it 'should emit a warning when bad yaml is supplied\
         (ie before a schema check)' do
      specification = {
        action: :run,
        targets: [{ type: :components,
                    pattern: './spec/fixtures/bad_yaml/component_of_bad.yaml' }]
      }
      expect(Opencontrol::CLI.run(specification)).to eq(3)
      expect { Opencontrol::CLI.run(specification) }.to output(/Complete. 3 issues found./).to_stdout
    end
    it 'should emit a message and stop when no schema is found for the supplied job' do
      skip
    end
    it 'should throw and stop when an unknown type of component schema is used in the spec' do
      skip
    end
  end
end
