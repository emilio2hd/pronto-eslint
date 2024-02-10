# -*- encoding: utf-8 -*-

$LOAD_PATH.push File.expand_path('../lib', __FILE__)
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
  s.required_ruby_version = '>= 2.3.0'

  s.files = `git ls-files`.split($RS).reject do |file|
    file =~ %r{^(?:
    spec/.*
    |Gemfile
    |Rakefile
    |\.rspec
    |\.gitignore
    |\.rubocop.yml
    |\.travis.yml
    )$}x
  end
  s.test_files = []
  s.extra_rdoc_files = ['LICENSE', 'README.md']
  s.require_paths = ['lib']

  s.add_dependency('pronto', '>= 0.11.2')
end
