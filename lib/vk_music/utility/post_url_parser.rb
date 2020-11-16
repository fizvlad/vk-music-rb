# frozen_string_literal: true

module VkMusic
  module Utility
    # Load wall audios
    class PostUrlParser
      # Regex for post URL
      POST_REGEX = /wall(-?\d+)_(\d+)/.freeze
      private_constant :POST_REGEX

      # @param url [String]
      # @return [Array(owner_id?, post_id?)]
      def self.call(url)
        matches = url.match(POST_REGEX)&.captures
        return [nil, nil] unless matches && matches.size == 2

        owner_id = Integer(matches[0], 10)
        post_id = Integer(matches[1], 10)

        [owner_id, post_id]
      end
    end
  end
end
