# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shortwave/version'

Gem::Specification.new do |spec|
  spec.name          = "shortwave"
  spec.version       = Shortwave::VERSION
  spec.authors       = ["Bradford Folkens"]
  spec.email         = ["bfolkens@gmail.com"]

  spec.summary       = %q{Like CarrierWave, but based on streams, pipeliens, and a lightweight toolbox.}
  spec.description   = %q{Shortwave is another attempt at the upload "problem," and approaches is from the perspective of streams, pipelines, and a framework based on lightweight tools instead of one monolithic class.}
  spec.homepage      = "https://github.com/bfolkens/ruby-shortwave"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.0'

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "rspec-mocks", "~> 3.5"

	spec.add_runtime_dependency 'iobuffer', '~> 1.1.2'
  spec.add_runtime_dependency 'aws-sdk', '~> 2'
end
