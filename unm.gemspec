# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'unm/version'

Gem::Specification.new do |spec|
  spec.name          = "unm"
  spec.version       = Unm::VERSION
  spec.authors       = ["Ricardo Piro-Rael"]
  spec.email         = ["fdisk@fdisk.co"]
  spec.summary       = %q{Utilities to interact with UNM Interfaces.}
  spec.description   = %q{Curently only works with the calendar.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "httparty"
  spec.add_development_dependency "nokogiri"
end
