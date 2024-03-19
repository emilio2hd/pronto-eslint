# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Pronto::Eslint::FatalMessagesExtractor do
  describe '#fatal_messages' do
    subject { described_class.new(eslint_result, eslint_config) }

    let(:eslint_config) { '.eslintrc.js' }
    let(:fatal_error_message) { 'fatal error message' }
    let(:eslint_result) do
      [
        {
          filePath: '/path/to/file.js',
          messages: [{ fatal: true, severity: 2, message: fatal_error_message }],
          errorCount: 1,
          fatalErrorCount: 1
        }
      ]
    end

    it 'returns an array of Pronto::Message objects' do
      messages = subject.fatal_messages

      expect(messages.size).to eq(1)
      expect(messages.first.path).to eq(eslint_config)
      expect(messages.first.level).to eq(:fatal)
      expect(messages.first.msg).to eq("#{eslint_config}: #{fatal_error_message}")
      expect(messages.first.runner).to eq(Pronto::Eslint::Runner)
    end
  end
end
