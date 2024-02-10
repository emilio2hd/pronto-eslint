require 'spec_helper'

RSpec.describe Pronto::Eslint::Linter do
  let(:bin_path) { 'eslint' }
  let(:eslint_file_path) { 'custom_eslintrc' }

  describe '#initialize' do
    context 'with valid bin_path' do
      it 'creates a new instance with bin_path as a string' do
        linter = described_class.new(bin_path)

        expect(linter.bin_path).to eq([bin_path])
        expect(linter.eslint_file_path).to be_nil
      end

      it 'creates a new instance with bin_path as an array' do
        bin_path_array = ['npx', bin_path]

        linter = described_class.new(bin_path_array)

        expect(linter.bin_path).to eq(bin_path_array)
        expect(linter.eslint_file_path).to be_nil
      end
    end

    context 'with valid bin_path and eslint_file_path' do
      it 'creates a new instance with bin_path and eslint_file_path' do
        linter = described_class.new(bin_path, eslint_file_path)

        expect(linter.bin_path).to eq([bin_path])
        expect(linter.eslint_file_path).to eq(eslint_file_path)
      end
    end

    context 'with invalid bin_path' do
      it 'raises an error when bin_path is neither a string nor an array' do
        expect { described_class.new(123) }
          .to raise_error(RuntimeError, 'bin_path Invalid! It must be either an array or string')
      end
    end
  end

  describe '#analyze' do
    let(:file_path) { 'file.js' }

    subject(:linter) { described_class.new(bin_path) }

    context 'when eslint command is successful with no lint errors' do
      it 'returns an empty array' do
        allow(Open3)
          .to receive(:capture3)
          .and_return(['', '', instance_double(Process::Status, exitstatus: 0)])

        result = linter.analyze(file_path)

        expect(result).to eq([])
        expect(Open3)
          .to have_received(:capture3)
          .with(bin_path, '-f', 'json', '--no-color', '--exit-on-fatal-error', file_path)
      end
    end

    context 'when the eslint config is passed' do
      subject(:linter) { described_class.new(bin_path, eslint_file_path) }

      it 'returns an empty array and includes the eslint config in the call' do
        allow(Open3)
          .to receive(:capture3)
          .and_return(['', '', instance_double(Process::Status, exitstatus: 0)])

        result = linter.analyze(file_path)

        expect(result).to eq([])
        expect(Open3)
          .to have_received(:capture3)
          .with(bin_path, '-f', 'json', '--no-color', '-c', eslint_file_path, '--exit-on-fatal-error', file_path)
      end
    end

    context 'when eslint command is successful with lint errors' do
      let(:stdout_result) { '{"messages":[{"message":"Lint error"}]}' }

      it 'returns the stdout result' do
        allow(Open3)
          .to receive(:capture3)
          .and_return([stdout_result, '', instance_double(Process::Status, exitstatus: 1)])

        result = linter.analyze(file_path)

        expect(result).to eq(stdout_result)
      end
    end

    context 'when eslint command is unsuccessful' do
      let(:stderr_message) { 'Error message' }

      it 'raises an error with the appropriate message' do
        allow(Open3)
          .to receive(:capture3)
          .and_return(['', stderr_message, instance_double(Process::Status, exitstatus: 2)])

        expect { linter.analyze(file_path) }
          .to raise_error(RuntimeError, /The eslint command failed with #{stderr_message}/)
      end
    end

    context 'when eslint command exit on fatal error and no eslint config is passed' do
      let(:fatal_error_message) { 'Fatal error message' }
      let(:stdout_result) { 'some json output with fatal error' }
      let(:parser) { instance_double(Pronto::Eslint::ResultParser) }
      let(:default_eslint_file) { described_class::DEFAULT_ESLINT_FILE }
      let(:fatal_message) { instance_double(Pronto::Message, msg: fatal_error_message) }

      it 'raises a fatal error with the appropriate message' do
        allow(Open3)
          .to receive(:capture3)
          .and_return([stdout_result, '', instance_double(Process::Status, exitstatus: 2)])

        allow(Pronto::Eslint::ResultParser).to receive(:new).and_return(parser)
        allow(parser).to receive(:fatal_messages).and_return([fatal_message])

        expect { linter.analyze(file_path) }
          .to raise_error(Pronto::Eslint::EslintFatalError, fatal_error_message)

        expect(Pronto::Eslint::ResultParser)
          .to have_received(:new)
          .with(stdout_result, nil, default_eslint_file)
        expect(parser).to have_received(:fatal_messages)
      end
    end

    context 'when eslint command exit on fatal error and eslint config is passed' do
      subject(:linter) { described_class.new(bin_path, eslint_file_path) }

      let(:fatal_error_message) { 'Fatal error message' }
      let(:stdout_result) { 'some json output with fatal error' }
      let(:parser) { instance_double(Pronto::Eslint::ResultParser) }
      let(:fatal_message) { instance_double(Pronto::Message, msg: fatal_error_message) }

      it 'raises a fatal error with the appropriate message adding the custom eslint config' do
        allow(Open3)
          .to receive(:capture3)
          .and_return([stdout_result, '', instance_double(Process::Status, exitstatus: 2)])

        allow(Pronto::Eslint::ResultParser).to receive(:new).and_return(parser)
        allow(parser).to receive(:fatal_messages).and_return([fatal_message])

        expect { linter.analyze(file_path) }
          .to raise_error(Pronto::Eslint::EslintFatalError, fatal_error_message)

        expect(Pronto::Eslint::ResultParser)
          .to have_received(:new)
          .with(stdout_result, nil, eslint_file_path)
        expect(parser).to have_received(:fatal_messages)
      end
    end
  end
end
