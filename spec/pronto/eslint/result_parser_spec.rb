require 'spec_helper'

RSpec.describe Pronto::Eslint::ResultParser do
  let(:eslint_result_json) { eslint_result.to_json }

  let(:lines) do
    [
      instance_double(
        'Pronto::Git::Line',
        new_lineno: 1,
        commit_sha: 'asdasdasdas',
        patch: instance_double(
          'Pronto::Git::Patch',
          delta: instance_double('Pronto::Git::Delta', new_file: { path: '/path/to/file.js' })
        )
      )
    ]
  end

  describe '#error_messages' do
    subject(:result_parser) { described_class.new(eslint_result_json, lines) }

    let(:eslint_result) do
      [
        {
          filePath: '/path/to/file.js',
          messages: [
            {
              severity: 2,
              message: 'Lint error',
              line: 1,
              column: 10,
              endLine: 1,
              endColumn: 20
            }
          ],
          errorCount: 1,
          warningCount: 0
        }
      ]
    end

    context 'when eslint result contains offenses' do
      it 'returns an array of Pronto::Message objects' do
        messages = result_parser.error_messages

        expect(messages.size).to eq(1)
        expect(messages.first.path).to eq('/path/to/file.js')
        expect(messages.first.line.new_lineno).to eq(1)
        expect(messages.first.level).to eq(:error)
        expect(messages.first.msg).to eq('Lint error')
        expect(messages.first.runner).to eq(Pronto::Eslint::Runner)
      end
    end

    context 'when result contains no offenses' do
      let(:eslint_result) do
        [
          {
            filePath: '/path/to/file.js',
            messages: [],
            errorCount: 0,
            warningCount: 0
          }
        ]
      end

      it 'returns an empty array' do
        expect(result_parser.error_messages).to eq([])
      end
    end

    context 'when message has no line number' do
      let(:eslint_result) do
        [
          {
            filePath: '/path/to/file.js',
            messages: [
              {
                severity: 2,
                message: 'Lint error',
                line: nil,
                column: 10,
                endLine: 1,
                endColumn: 20
              }
            ],
            errorCount: 1,
            warningCount: 0
          }
        ]
      end

      it 'returns an empty array' do
        expect(result_parser.error_messages).to eq([])
      end
    end

    context 'when message has no warningCount or errorCount greater than 1' do
      let(:eslint_result) do
        [
          {
            filePath: '/path/to/file.js',
            messages: [
              {
                severity: 1,
                message: 'Some random message',
                line: 1,
                column: 10,
                endLine: 1,
                endColumn: 20
              }
            ],
            errorCount: 0,
            warningCount: 0
          }
        ]
      end

      it 'returns an empty array' do
        expect(result_parser.error_messages).to eq([])
      end
    end

    context 'when offense is not related to changed line' do
      let(:eslint_result) do
        [
          {
            filePath: '/path/to/file.js',
            messages: [
              {
                severity: 2,
                message: 'Lint error',
                line: 2,
                column: 1,
                endLine: 2,
                endColumn: 2
              }
            ],
            errorCount: 1,
            warningCount: 0
          }
        ]
      end

      it 'returns an empty array' do
        expect(result_parser.error_messages).to eq([])
      end
    end
  end

  describe '#fatal_messages' do
    subject(:result_parser) { described_class.new(eslint_result_json, lines, eslint_config) }

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
      messages = result_parser.fatal_messages

      expect(messages.size).to eq(1)
      expect(messages.first.path).to eq(eslint_config)
      expect(messages.first.level).to eq(:fatal)
      expect(messages.first.msg).to eq("#{eslint_config}: #{fatal_error_message}")
      expect(messages.first.runner).to eq(Pronto::Eslint::Runner)
    end
  end
end
