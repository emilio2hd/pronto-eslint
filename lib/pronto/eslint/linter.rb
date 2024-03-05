# frozen_string_literal: true

module Pronto
  module Eslint
    class Linter
      EXIT_SUCCESSFUL_NO_LINT_ERRORS = 0
      EXIT_SUCCESSFUL_LINT_ERRORS = 1
      EXIT_UNSUCCESSFUL = 2
      DEFAULT_ESLINT_FILE = '.eslintrc'

      attr_reader :bin_path, :eslint_file_path

      def initialize(bin_path, eslint_file_path = nil)
        @eslint_file_path = eslint_file_path
        @bin_path = case bin_path
                    when Array    then bin_path
                    when String   then bin_path.shellsplit
                    else raise 'bin_path Invalid! It must be either an array or string'
                    end
      end

      def analyze(file_path)
        command = build_command(file_path)

        (stdout, stderr, status) = Open3.capture3(*command)

        case status.exitstatus
        when EXIT_SUCCESSFUL_NO_LINT_ERRORS
          []
        when EXIT_SUCCESSFUL_LINT_ERRORS
          stdout
        else
          unless stdout.empty?
            eslint_file = eslint_file_path_present? ? eslint_file_path : DEFAULT_ESLINT_FILE

            message = Pronto::Eslint::ResultParser.new(stdout, nil, eslint_file).fatal_messages.first

            raise EslintFatalError, message.msg unless message.nil?
          end

          raise "The eslint command failed with #{stderr}: `#{command.shelljoin}`"
        end
      end

      private

      def build_command(files_path)
        command = bin_path
        command.push('-f', 'json', '--no-color')
        command.push('-c', eslint_file_path) if eslint_file_path_present?
        command.push('--exit-on-fatal-error')
        command.concat(Array(files_path))
      end

      def eslint_file_path_present?
        !eslint_file_path.nil? && !eslint_file_path.empty?
      end
    end
  end
end
