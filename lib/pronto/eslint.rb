# frozen_string_literal: true

require 'pronto'

require_relative 'eslint/version'
require_relative 'eslint/linter'
require_relative 'eslint/fatal_messages_extractor'
require_relative 'eslint/messages_extractor'
require_relative 'eslint/result_parser'
require_relative 'eslint/runner'

module Pronto
  module Eslint
    class Error < StandardError; end
    class EslintFatalError < StandardError; end

    # This patch enhance eslint options, opening it to allow user to pass custom options
    module ConfigPatch
      def eslint_config
        @config_hash['eslint'] || {}
      end
    end
  end
end
