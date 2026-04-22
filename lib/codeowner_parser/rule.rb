# frozen_string_literal: true

module CodeownerParser
  # Handles an individual rule and determines applicability.
  class Rule
    attr_reader :owner

    def initialize(rule_string)
      @rule_path, *@owner = rule_string.split(/\s+/)
      # Precompute this so that we aren't doing so repeatedly for additional checks.
      @rule_regex = path_regex
    end

    def applies?(path)
      @rule_regex =~ path
    end

    private

    def path_regex
      # Split on '**/' to identify zero-or-more directory segment matching,
      # then split each remaining segment on '*' for single-segment wildcards.
      regex = @rule_path.split('**/').map { |segment|
        segment.split('*', -1).map { |literal|
          Regexp.escape(literal)
        }.join('[^\/]+')
      }.join('(.*\/)?')

      # If path started with a slash, this is rooted.
      regex = "\\A#{regex}" if @rule_path.start_with?('/')
      # If path did not end with a slash, do not search into subdirectories.
      regex += '\Z' unless @rule_path.end_with?('/')

      Regexp.compile(regex)
    end
  end
end
