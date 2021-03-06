# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'poor_man_search/version'

Gem::Specification.new do |spec|
  spec.name          = "poor_man_search"
  spec.version       = PoorManSearch::VERSION
  spec.authors       = ["Yasuhiko Maeda"]
  spec.email         = ["y.maeda@dongoon.jp"]
  spec.description   = %q{Poor man's search engine module for Rails3 (Arel)}
  spec.summary       = %q{Poor man's search engine module for Rails3 (Arel)}
  spec.homepage      = "https://github.com/dongoon/poor_man_search"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]


  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "sqlite3-ruby"
  spec.add_development_dependency "database_cleaner"
  spec.add_development_dependency "coveralls"

  spec.add_runtime_dependency "activerecord", "~> 3.2", ">= 3.0.0"
  spec.add_runtime_dependency "arel", ">= 3.0.0"
end
