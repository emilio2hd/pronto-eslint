# frozen_string_literal: true

require 'rspec'
require 'rspec/its'
require 'pronto/eslint'

RSpec.shared_context 'test repo' do
  let(:git) { 'spec/fixtures/test.git/git' }
  let(:dot_git) { 'spec/fixtures/test.git/.git' }

  before { FileUtils.mv(git, dot_git) }
  let(:repo) { Pronto::Git::Repository.new('spec/fixtures/test.git') }
  after { FileUtils.mv(dot_git, git) }
end

RSpec.shared_context 'invalid_eslintrc' do
  let(:eslintrc) { 'spec/fixtures/eslintrc8' }
  let(:dot_eslintrc) { '.eslintrc' }

  before { FileUtils.mv(eslintrc, dot_eslintrc) }
  after { FileUtils.mv(dot_eslintrc, eslintrc) }
end

RSpec.shared_context 'valid_eslintrc' do
  let(:eslintrc) { 'spec/fixtures/eslintrc' }
  let(:dot_eslintrc) { '.eslintrc' }

  before { FileUtils.mv(eslintrc, dot_eslintrc) }
  after { FileUtils.mv(dot_eslintrc, eslintrc) }
end
