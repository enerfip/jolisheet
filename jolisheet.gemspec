$:.push File.expand_path('lib', __dir__)

require 'jolisheet/version'

Gem::Specification.new do |spec|
  spec.name          = 'jolisheet'
  spec.version       = Jolisheet::VERSION
  spec.authors       = ['Arnaud Sellenet']
  spec.email         = ['arnodmental@gmail.com']

  spec.summary       = 'Small DSL on top of Spreadsheet Gem'

  spec.required_ruby_version = '>= 1.9'

  spec.files = Dir['{lib}/**/*'] + ['Rakefile', 'README.md']

  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport/core_ext'
  spec.add_dependency 'caxlsx'
  spec.add_dependency 'rake'
end
