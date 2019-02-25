# frozen_string_literal: true

require 'timeout'
require 'opencontrol'

RSpec.describe 'Opencontrol Linter' do
  context 'when checking a correct file' do
    it 'returns 0 for valid components file' do
      specifications = [{
        action: :run,
        targets: [
          { type: :components,
            pattern:
               './spec/fixtures/no_issues/components/AU_policy/component.yaml' }
        ]
      }]
      specifications.each do |specification|
        expect(Opencontrol::Linter.run(specification)).to eq(0)
        expect do
          Opencontrol::Linter.run(specification)
        end.to output(/Complete. No problems found./).to_stdout
      end
    end

    it 'returns 0 for valid standards file' do
      specifications = [{
        action: :run,
        targets: [
          { type: :standards,
            pattern: './spec/fixtures/no_issues/standards/FRIST-800-53.yaml' }
        ]
      }]
      specifications.each do |specification|
        expect(Opencontrol::Linter.run(specification)).to eq(0)
        expect do
          Opencontrol::Linter.run(specification)
        end.to output(/Complete. No problems found./).to_stdout
      end
    end

    it 'returns 0 for valid components file' do
      specifications = [{
        action: :run,
        targets: [{ type: :certifications,
                    pattern: './spec/fixtures/no_issues/certifications/FredRAMP-low.yaml' }]
      }]
      specifications.each do |specification|
        expect(Opencontrol::Linter.run(specification)).to eq(0)
        expect do
          Opencontrol::Linter.run(specification)
        end.to output(/Complete. No problems found./).to_stdout
      end
    end

    it 'returns 0 for valid opencontrol file' do
      specifications = [{
        action: :run,
        targets: [{ type: :opencontrols,
                    pattern: './spec/fixtures/no_issues/opencontrol.yaml' }]
      }]
      specifications.each do |specification|
        expect(Opencontrol::Linter.run(specification)).to eq(0)
        expect do
          Opencontrol::Linter.run(specification)
        end.to output(/Complete. No problems found./).to_stdout
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
      expect(Opencontrol::Linter.run(specification)).to eq(1)
      expect do
        Opencontrol::Linter.run(specification)
      end.to output(/Complete. 1 issues found./).to_stdout
    end
    it 'checks a given file with faults and returns 1 for standards file' do
      specification = {
        action: :run,
        targets: [{ type: :standards,
                    pattern: './spec/fixtures/issues/standards/FRIST-800-53.yaml' }]
      }
      expect(Opencontrol::Linter.run(specification)).to eq(1)
      expect do
        Opencontrol::Linter.run(specification)
      end.to output(/Complete. 1 issues found./).to_stdout
    end
    it 'checks a given file with faults and returns 1 for certifications' do
      specification = {
        action: :run,
        targets: [{ type: :certifications,
                    pattern: './spec/fixtures/issues/certifications/FredRAMP-low.yaml' }]
      }
      expect(Opencontrol::Linter.run(specification)).to eq(1)
      expect do
        Opencontrol::Linter.run(specification)
      end.to output(/Complete. 1 issues found./).to_stdout
    end
    it 'checks a given file with faults and returns 1 for opencontrol file' do
      specification = {
        action: :run,
        targets: [{ type: :opencontrols,
                    pattern: './spec/fixtures/issues/opencontrol.yaml' }]
      }
      expect(Opencontrol::Linter.run(specification)).to eq(1)
      expect do
        Opencontrol::Linter.run(specification)
      end.to output(/Complete. 1 issues found./).to_stdout
    end
  end

  context 'file checks on input' do
    it 'should emit a warning when no file is found to validate' do
      specification = {
        action: :run,
        targets: [{ type: :components,
                    pattern: './spec/fixtures/empty/**/component.yaml' }]
      }
      expect(Opencontrol::Linter.run(specification)).to eq(1)
      expect do
        Opencontrol::Linter.run(specification)
      end.to output(/Complete. 1 issues found./).to_stdout
    end
    it 'should emit a warning when bad yaml is supplied\
         (ie before a schema check)' do
      specification = {
        action: :run,
        targets: [{ type: :components,
                    pattern: './spec/fixtures/bad_yaml/component_of_bad.yaml' }]
      }
      expect(Opencontrol::Linter.run(specification)).to eq(3)
      expect do
        Opencontrol::Linter.run(specification)
      end.to output(/Complete. 3 issues found./).to_stdout
    end
    it 'should emit a message and stop when no schema is found for the job' do
      skip
    end
    it 'should throw when an unknown type of schema is used in the spec' do
      skip
    end
  end
  context 'validating opencontrol files' do
    it 'should indicate when there are broken links in the opencontrol file' do
      skip
    end
  end
end
