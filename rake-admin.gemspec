# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rake/admin/version'

Gem::Specification.new do |spec|
  spec.name          = "rake-admin"
  spec.version       = Rake::Admin::VERSION
  spec.authors       = ["Alejandro Souto"]
  spec.email         = ["sorinaso@gmail.com"]
  spec.description   = %q{My administration gems}
  spec.summary       = %q{My administration gems}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rspec"

  spec.add_dependency "rake"
  spec.add_dependency "log4r", "~> 1.1.10"
  #spec.add_dependency "net-ssh", "~> 2.6.6"
  spec.add_dependency "net-ssh"
  spec.add_dependency "highline"
end
