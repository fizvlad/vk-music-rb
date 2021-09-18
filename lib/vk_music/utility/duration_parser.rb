# frozen_string_literal: true

module VkMusic
  module Utility
    # Turn human readable track length to its size in seconds
    module DurationParser
      # @param str [String] string in format "HH:MM:SS" or something alike (+/d++ Regex selector is used)
      # @return [Integer] amount of seconds
      def self.call(str)
        str
          .scan(/\d+/)
          .map { |i| Integer(i, 10) }
          .reverse
          .each_with_index
          .reduce(0) { |acc, (count, position)| acc + (count * (60**position)) }
      end
    end
  end
end
