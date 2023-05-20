# frozen_string_literal: true

module VkMusic
  module Utility
    # Load wall audios
    module PostUrlParser
      # Regex for post URL
      POST_POSTFIX = /.*wall(-?\d+)_(\d+)/
      public_constant :POST_POSTFIX

      # @param url [String]
      # @return [Array(owner_id?, post_id?)]
      def self.call(url)
        matches = url.match(POST_POSTFIX)&.captures
        return [nil, nil] unless matches && matches.size == 2

        owner_id = Integer(matches[0], 10)
        post_id = Integer(matches[1], 10)

        [owner_id, post_id]
      end
    end
  end
end
