require 'spec_helper'

RSpec.describe Pronto::Eslint::Runner do
  let(:patches) { nil }
  let(:commit) { instance_double('Pronto::Git::Commit') }

  describe '#run' do
    subject(:runner) { described_class.new(patches, commit) }

    context 'when there are no patches' do
      it 'returns an empty array' do
        expect(runner.run).to eq([])
      end
    end

    context 'when there are patches' do
      let(:added_lines) { [instance_double(Pronto::Git::Line)] }
      let(:patches) do
        [
          instance_double(
            'Pronto::Git::Patch', added_lines: added_lines, additions: 1, new_file_full_path: '/path/to/file.js'
          )
        ]
      end

      context 'when linter output is empty' do
        let(:linter) { instance_double(Pronto::Eslint::Linter) }
        let(:linter_output) { '' }

        it 'returns an empty array' do
          allow(Pronto::Eslint::Linter).to receive(:new).and_return(linter)
          allow(linter).to receive(:analyze).and_return(linter_output)

          expect(runner.run).to eq([])
        end
      end

      context 'when linter output is not empty' do
        let(:linter) { instance_double(Pronto::Eslint::Linter) }
        let(:parser) { instance_double(Pronto::Eslint::ResultParser) }
        let(:linter_output) do
          '[{"filePath": "/path/to/file.js", "messages":[{"message":"Lint error", "line": 1, "endLine": 1}]}]'
        end
        let(:messages) { [instance_double(Pronto::Message)] }

        it 'returns an array of linted messages' do
          allow(Pronto::Eslint::Linter).to receive(:new).and_return(linter)
          allow(linter).to receive(:analyze).and_return(linter_output)

          allow(Pronto::Eslint::ResultParser).to receive(:new).and_return(parser)
          allow(parser).to receive(:error_messages).and_return(messages)

          expect(runner.run).to eq(messages)
        end
      end

      context 'when file is not javascript' do
        let(:linter) { instance_double(Pronto::Eslint::Linter) }
        let(:patches) do
          [
            instance_double(
              'Pronto::Git::Patch', added_lines: added_lines, additions: 1, new_file_full_path: '/path/to/file.rb'
            )
          ]
        end

        it 'returns an empty array' do
          allow(Pronto::Eslint::Linter).to receive(:new).and_return(linter)
          expect(linter).not_to receive(:analyze)

          expect(runner.run).to eq([])
        end
      end
    end
  end

  describe 'eslint configuration options' do
    let(:config) { instance_double(Pronto::Config) }
    let(:added_lines) { [instance_double(Pronto::Git::Line)] }
    let(:patches) do
      [
        instance_double(
          'Pronto::Git::Patch', added_lines: added_lines, additions: 1, new_file_full_path: '/path/to/file.js'
        )
      ]
    end
    let(:linter) { instance_double(Pronto::Eslint::Linter) }
    let(:linter_output) { '' }

    it 'apply the patch to enhance options' do
      allow(Pronto::Config).to receive(:new).and_return(config)
      allow(config).to receive(:extend)

      described_class.new(patches, commit)

      expect(config).to have_received(:extend)
    end

    context 'with custom options' do
      let(:custom_options) do
        {
          'bin_path' => './node_modules/.bin/eslint',
          'eslint_config_file' => 'config/.eslintrc.js'
        }
      end
      let(:custom_config) { Pronto::Config.new({ 'eslint' => custom_options }) }

      it 'uses data from config' do
        allow(Pronto::Config).to receive(:new).and_return(custom_config)
        allow(Pronto::Eslint::Linter).to receive(:new).and_return(linter)
        allow(linter).to receive(:analyze).and_return(linter_output)

        runner = described_class.new(patches, commit)

        expect(runner.run).to eq([])

        expect(Pronto::Eslint::Linter)
          .to have_received(:new)
          .with(custom_options['bin_path'], custom_options['eslint_config_file'])
        expect(linter).to have_received(:analyze)
      end
    end
  end
end
