require 'spec_helper'

RSpec.describe Pronto::Eslint::Runner do
  let(:eslint) { Pronto::Eslint::Runner.new(patches) }

  describe '#run' do
    subject { eslint.run }

    context 'patches are nil' do
      let(:patches) { nil }
      it { should == [] }
    end

    context 'no patches' do
      let(:patches) { [] }
      it { should == [] }
    end

    context 'invalid .eslintrc config' do
      include_context 'test repo'
      include_context 'invalid_eslintrc'

      let(:patches) { repo.diff('master') }

      it 'raises error' do
        expect { subject }
          .to raise_error(
            Pronto::Eslint::EslintFatalError,
            '.eslintrc: Parsing error: ecmaVersion must be a number or "latest". Received value of type string instead.'
          )
      end
    end

    context 'patches with a four and a five warnings' do
      include_context 'test repo'
      include_context 'valid_eslintrc'

      let(:patches) { repo.diff('master') }

      its(:count) { should == 9 }

      its(:'first.msg') { should == "no-undef: 'foo' is not defined." }
    end
  end
end
