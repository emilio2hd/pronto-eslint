# frozen_string_literal: true

module Pronto
  module Eslint
    class ResultParser
      def initialize(eslint_result, patches, eslint_config = nil)
        @eslint_result = JSON.parse(eslint_result, symbolize_names: true)
        @patches = patches
        @eslint_config = eslint_config
      end

      def error_messages
        MessagesExtractor.new(eslint_result, patches).extract_messages
      end

      def fatal_messages
        raise 'To process a fatal errors, eslint_config is required' if eslint_config.nil?

        FatalMessagesExtractor.new(eslint_result, eslint_config).fatal_messages
      end

      private

      attr_reader :eslint_config, :eslint_result, :patches
    end
  end
end
