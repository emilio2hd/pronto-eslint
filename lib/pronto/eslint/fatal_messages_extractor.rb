# frozen_string_literal: true

module Pronto
  module Eslint
    class FatalMessagesExtractor
      def initialize(eslint_result, eslint_config)
        @result = eslint_result
        @eslint_config = eslint_config
      end

      def fatal_messages
        result.flat_map(&method(:extract_fatal_messages_from_offence))
      end

      private

      attr_reader :result, :eslint_config

      def extract_fatal_messages_from_offence(offence)
        return [] unless offence[:fatalErrorCount].positive?

        offence[:messages].map do |message|
          msg = "#{eslint_config}: #{message[:message]}"
          Pronto::Message.new(eslint_config, nil, :fatal, msg, nil, Pronto::Eslint::Runner)
        end
      end
    end
  end
end
