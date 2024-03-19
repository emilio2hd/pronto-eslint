# frozen_string_literal: true

module Pronto
  module Eslint
    class MessagesExtractor
      SEVERITY_LEVELS = [nil, :warning, :error].freeze

      def initialize(eslint_result, patches)
        @result = eslint_result
        @patches = patches
      end

      def extract_messages
        return [] if errors_with_lines.empty?

        patches.flat_map(&method(:extract_messages_from_patch)).compact
      end

      private

      attr_reader :result, :patches

      def extract_messages_from_patch(patch)
        lines = patch.added_lines
        file_offences = find_patch_offences(patch)

        file_offences[:messages].map do |offence|
          line = find_matching_line(offence, lines)
          build_message(offence, line) if line
        end
      end

      def find_patch_offences(patch)
        errors_with_lines.find { |offence| offence[:filePath] == patch.new_file_full_path.to_s }
      end

      def find_matching_line(offence, lines)
        range = offence[:line]..(offence[:endLine] || offence[:line])
        lines.select { |line| range.cover?(line.new_lineno) }.last
      end

      def errors_with_lines
        @errors_with_lines ||= result
          .select { |offence| (offence[:errorCount] + offence[:warningCount]).positive? }
          .flat_map(&method(:filter_messages_with_lines))
          .reject { |offence| offence[:messages].empty? }
      end

      def filter_messages_with_lines(offence)
        offence
          .slice(:messages, :filePath)
          .tap { |new_offence| new_offence[:messages].reject! { |message| message[:line].nil? } }
      end

      def build_message(offence, line)
        path = line.patch.delta.new_file[:path]
        level = SEVERITY_LEVELS.fetch(offence[:severity], :warning)
        msg = [offence[:ruleId], offence[:message]].compact.join(': ')

        Pronto::Message.new(path, line, level, msg, nil, Pronto::Eslint::Runner)
      end
    end
  end
end
