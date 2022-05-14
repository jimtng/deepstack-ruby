# frozen_string_literal: true

require_relative 'lib/deep_stack/version'

Gem::Specification.new do |spec|
  spec.name          = 'deepstack'
  spec.version       = DeepStack::VERSION
  spec.authors       = ['Jimmy Tanagra']
  spec.email         = ['jcode@tanagra.id.au']

  spec.summary       = 'A Ruby wrapper for DeepStack API'
  spec.homepage      = 'https://github.com/jimtng/deepstack-ruby'
  spec.license       = 'EPL-2.0'

  spec.test_files    = Dir.glob('spec/*_spec.rb')

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = %w[README.md] + Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").select { |f| f.match(%r{^(lib)/}) }
  end
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri']      = spec.homepage
  spec.metadata['source_code_uri']   = spec.homepage
  spec.metadata['documentation_uri'] = 'https://rubydoc.info/gems/deepstack'
  spec.metadata['changelog_uri']     = 'https://github.com/jimtng/deepstack-ruby/blob/main/CHANGELOG.md'

  spec.add_development_dependency 'rake',          '~> 13.0'
  spec.add_development_dependency 'rspec',         '~> 3.0'
  spec.add_development_dependency 'rubocop',       '~> 1.21'
  spec.add_development_dependency 'rubocop-rake',  '~> 0.6'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'yard'
end
