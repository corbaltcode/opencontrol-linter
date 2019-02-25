# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('lib', __dir__)
require 'opencontrol/version'
require 'English'

# opencontrol:disable Metrics/BlockLength
Gem::Specification.new do |s|
  s.name = 'opencontrol-linter'
  s.version = Opencontrol::Version::STRING
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.2.2'
  s.authors = ['Adrian Kierman', 'James Connor']
  s.description = <<-DESCRIPTION
    Automatic Open Control schema checking tool.
    Aims to provide quick tests that ensure open control controls work together reliably.
  DESCRIPTION

  # If you need to check in files that aren't .rb files, add them here
  s.files = Dir['{lib}/**/*.rb', 'bin/*', 'LICENSE', '*.md', 'vendor/**/*']
  s.bindir = 'exe'
  s.executables = ['opencontrol-linter']
  s.extra_rdoc_files = ['LICENSE.txt', 'README.md']
  s.homepage = 'https://github.com/adriankierman/opencontrol'
  s.licenses = ['MIT']
  s.summary = 'Automatic open control linting tool.'

  s.metadata = {
    'homepage_uri' => 'https://github.com/adriankierman/opencontrol/',
    'changelog_uri' => 'https://github.com/adriankierman/opencontrol/blob/master/CHANGELOG.md',
    'source_code_uri' => 'https://github.com/adriankierman/opencontrol',
    'documentation_uri' => 'https://github.com/adriankierman/opencontrol',
    'bug_tracker_uri' => 'https://github.com/adriankierman/opencontrol/issues'
  }

  s.add_runtime_dependency('colorize', '~> 0.8.1')
  s.add_runtime_dependency('kwalify', '~> 0.7.2')
  s.add_runtime_dependency('parallel', '~> 1.10')
  s.add_runtime_dependency('powerpack', '~> 0.1.2')
  s.add_runtime_dependency('psych', '>= 3.1.0')
  s.add_runtime_dependency('rainbow', '>= 2.2.2', '< 4.0')
  s.add_runtime_dependency('rationalist', '~> 2.0.0')
  s.add_runtime_dependency('ruby-progressbar', '~> 1.7')

  s.add_development_dependency('bundler', '>= 1.3.0', '< 3.0')
  s.add_development_dependency('pry', '~> 0.12.2')
  s.add_development_dependency('rack', '>= 2.0')
  s.add_development_dependency('rake', '~> 12.3.2')
  s.add_development_dependency('rspec', '~> 3.8.0')
  s.add_development_dependency('rubocop-rspec', '~> 1.29.0')
  s.add_development_dependency('simplecov', '~> 0.16.1')
end
# opencontrol:enable Metrics/BlockLength
