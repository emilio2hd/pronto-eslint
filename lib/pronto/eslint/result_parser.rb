# frozen_string_literal: true

module Pronto
  module Eslint
    class ResultParser
      SEVERITY_LEVELS = [nil, :warning, :error].freeze

      def initialize(eslint_result, lines, eslint_config = nil)
        @result = JSON.parse(eslint_result, symbolize_names: true)
        @lines = lines
        @eslint_config = eslint_config
      end

      def error_messages
        error_with_lines
          .map do |offence|
            range = offence[:line]..(offence[:endLine] || offence[:line])
            line = lines.select { |l| range.cover?(l.new_lineno) }.last
            build_error_message(offence, line) if line
          end
          .compact
      end

      def fatal_messages
        raise 'To process a fatal errors, eslint_config is required' if eslint_config.nil?

        result
          .select { |offence| offence[:fatalErrorCount] > 0 }
          .flat_map { |offence| offence[:messages] }
          .map do |offence|
            msg = "#{eslint_config}: #{offence[:message]}"
            Message.new(eslint_config, nil, :fatal, msg, nil, Pronto::Eslint::Runner)
          end
      end

      private

      attr_reader :result, :lines, :eslint_config

      def error_with_lines
        @error_with_lines ||= @result
          .select { |offence| offence[:errorCount] + offence[:warningCount] > 0 }
          .flat_map { |offence| offence[:messages] }
          .select { |offence| offence[:line] }
      end

      def build_error_message(offence, line)
        path  = line.patch.delta.new_file[:path]
        level = SEVERITY_LEVELS.fetch(offence[:severity], :warning)

        msg = [offence[:ruleId], offence[:message]].compact.join(': ')
        Message.new(path, line, level, msg, nil, Pronto::Eslint::Runner)
      end
    end
  end
end
