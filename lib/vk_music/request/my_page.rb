# frozen_string_literal: true

module VkMusic
  module Request
    # Logging in request
    class MyPage < Base
      ID_CONTAINING_HREF = /(?:audios|photo|write|owner_id=|friends\?id=)(-?\d+)/.freeze
      private_constant :ID_CONTAINING_HREF

      # Initialize new request
      def initialize
        super("#{VK_ROOT}/id0", {}, 'GET', {})
        @id = nil
        @name = nil
      end

      # @return [Integer]
      def id
        @id ||= Integer(@response.link_with(href: ID_CONTAINING_HREF).href.slice(/\d+/), 10)
      end

      # @return [String]
      def name
        @name ||= @response.title.to_s
      end
    end
  end
end
