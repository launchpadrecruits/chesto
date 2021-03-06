# frozen_string_literal: true

require_relative 'lib/chesto/version'

Gem::Specification.new do |spec|
  spec.name          = 'chesto'
  spec.version       = Chesto::VERSION
  spec.authors       = ['Santo Puppy']
  spec.email         = ['lcelestial@outmatch.com']

  spec.summary       = 'Simple deploy scripts for deploying the app'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.0.0')

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{\Abin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'http', '~> 5.0'
  spec.add_dependency 'dry-struct', '~> 1.4'
  spec.add_dependency 'dry-monads', '~> 1.3'
  spec.add_dependency 'dry-schema', '~> 1.6'
  spec.add_dependency 'dry-types', '~> 1.2'
  spec.add_dependency 'dry-validation', '~> 1.6'
  spec.add_dependency 'ruby-progressbar', '~> 1.11'
end
