# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'pronto/eslint/version'
require 'English'

Gem::Specification.new do |s|
  s.name = 'pronto-eslint'
  s.version = Pronto::ESLintVersion::VERSION
  s.platform = Gem::Platform::RUBY
  s.author = 'Mindaugas Mozūras'
  s.email = 'mindaugas.mozuras@gmail.com'
  s.homepage = 'https://github.com/prontolabs/pronto-eslint'
  s.summary = 'Pronto runner for ESLint, pluggable linting utility for JavaScript and JSX'

  s.licenses = ['MIT']
  s.required_ruby_version = '>= 2.4'

  s.files = Dir.glob('lib/**/*.rb') + ['README.md', 'LICENSE', 'CHANGELOG.md']

  s.extra_rdoc_files = ['LICENSE', 'README.md']
  s.require_paths = ['lib']

  s.add_dependency('pronto', '>= 0.11.2')
end
