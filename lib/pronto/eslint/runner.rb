# frozen_string_literal: true

require 'json'
require 'open3'
require 'mkmf'

module Pronto
  module Eslint
    class Runner < Runner
      def self.title
        'eslint'
      end

      def initialize(patches, commit = nil)
        super(patches, commit)

        @config.extend(Pronto::Eslint::ConfigPatch)
      end

      def run
        return [] unless @patches

        @patches
          .select { |patch| patch.additions > 0 && js_file?(patch.new_file_full_path) }
          .flat_map { |patch| inspect(patch) }
          .compact
      end

      def inspect(patch)
        lines = patch.added_lines
        linter_output = linter.analyze(patch.new_file_full_path.to_s)

        return [] if linter_output.empty?

        Pronto::Eslint::ResultParser.new(linter_output, lines).error_messages
      end

      def js_file?(path)
        eslint_config[:files].include?(File.extname(path))
      end

      private

      def linter
        @linter ||= Pronto::Eslint::Linter.new(
          eslint_config[:bin_path],
          eslint_config[:eslint_config_file]
        )
      end

      def eslint_config
        @eslint_config ||= {
          bin_path: %w[npx eslint],
          eslint_config_file: nil,
          files: %w[.ts .js .es6 .js.es6 .jsx]
        }.merge(@config.eslint_config.transform_keys(&:to_sym))
      end
    end
  end
end
