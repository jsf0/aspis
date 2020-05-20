# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aspis/version'

Gem::Specification.new do |spec|
  spec.name          = 'aspis'
  spec.version       = Aspis::VERSION
  spec.authors       = ['Joseph Fierro']
  spec.email         = ['joseph.fierro@logosnetworks.com']
  spec.cert_chain = ['certs/jsfierro.pem']
  if $PROGRAM_NAME =~ /gem\z/
    spec.signing_key = File.expand_path('~/.ssh/gem-private_key.pem')
  end

  spec.summary       = 'command line encryption tool using rbnacl'
  spec.homepage      = 'https://github.com/jsfierro/aspis'
  spec.license       = 'ISC'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'rbnacl', '>= 7.0.0'
  spec.add_development_dependency 'bundler', '>= 1.17'
  spec.add_development_dependency 'rake', '>= 13.0.1'
end
