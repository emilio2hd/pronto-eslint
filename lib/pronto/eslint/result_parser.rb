# frozen_string_literal: true

module Pronto
  module Eslint
    class ResultParser
      SEVERITY_LEVELS = [nil, :warning, :error].freeze

      def initialize(eslint_result, patches, eslint_config = nil)
        @result = JSON.parse(eslint_result, symbolize_names: true)
        @patches = patches
        @eslint_config = eslint_config
      end

      def error_messages
        return [] if error_with_lines.empty?

        patches.flat_map do |patch|
          lines = patch.added_lines

          file_offences = error_with_lines.find { |offence| offence[:filePath] == patch.new_file_full_path.to_s }

          file_offences[:messages].map do |offence|
            range = offence[:line]..(offence[:endLine] || offence[:line])
            line = lines.select { |l| range.cover?(l.new_lineno) }.last
            build_error_message(offence, line) if line
          end
          .compact
        end
      end

      def fatal_messages
        raise 'To process a fatal errors, eslint_config is required' if eslint_config.nil?

        result
          .select { |offence| (offence[:fatalErrorCount]).positive? }
          .flat_map { |offence| offence[:messages] }
          .map do |offence|
            msg = "#{eslint_config}: #{offence[:message]}"
            Message.new(eslint_config, nil, :fatal, msg, nil, Pronto::Eslint::Runner)
          end
      end

      private

      attr_reader :result, :patches, :eslint_config

      def error_with_lines
        @error_with_lines ||= @result
          .select { |offence| (offence[:errorCount] + offence[:warningCount]).positive? }
          .flat_map do |offence|
            new_offence = offence.slice(:messages, :filePath)
            new_offence[:messages] = offence[:messages].select { |message| message[:line] }
            new_offence
          end
          .reject { |offence| offence[:messages].empty? }
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
