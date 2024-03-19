# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Pronto::Eslint::ResultParser do
  describe '#error_messages' do
    subject { described_class.new(eslint_result_json, patches) }

    let(:eslint_result) { [] }
    let(:eslint_result_json) { eslint_result.to_json }
    let(:patches) { [double('git change')] }

    let(:error_messages_extractor) { instance_double('Pronto::Eslint::MessagesExtractor') }
    let(:error_messages) { [instance_double('Pronto::Message')] }

    it 'call error messages extractor' do
      allow(Pronto::Eslint::MessagesExtractor)
        .to receive(:new)
        .and_return(error_messages_extractor)
      allow(error_messages_extractor)
        .to receive(:extract_messages)
        .and_return(error_messages)

      expect(subject.error_messages).to eq(error_messages)

      allow(Pronto::Eslint::MessagesExtractor)
        .to receive(:new)
        .with(eslint_result, patches)
      expect(error_messages_extractor).to have_received(:extract_messages)
    end
  end

  describe '#fatal_messages' do
    subject { described_class.new(eslint_result_json, [], eslint_config) }

    let(:eslint_result) { [] }
    let(:eslint_result_json) { eslint_result.to_json }
    let(:eslint_config) { '.eslintrc.js' }

    let(:fatal_messages_extractor) { instance_double('Pronto::Eslint::FatalMessagesExtractor') }
    let(:fatal_messages) { [instance_double('Pronto::Message')] }

    it 'call fatal messages extractor' do
      allow(Pronto::Eslint::FatalMessagesExtractor)
        .to receive(:new)
        .and_return(fatal_messages_extractor)
      allow(fatal_messages_extractor)
        .to receive(:fatal_messages)
        .and_return(fatal_messages)

      expect(subject.fatal_messages).to eq(fatal_messages)

      allow(Pronto::Eslint::FatalMessagesExtractor)
        .to receive(:new)
        .with(eslint_result, eslint_config)
      expect(fatal_messages_extractor).to have_received(:fatal_messages)
    end

    context 'when eslint_config is nil' do
      let(:eslint_config) { nil }

      it 'rises an error' do
        expect { subject.fatal_messages }.to raise_exception(RuntimeError, /eslint_config is required/)
      end
    end
  end
end
