# frozen_string_literal: true

module VkMusic
  module WebParser
    # Current user page parser
    class MyPage < Base
      # Link with user id in it
      ID_CONTAINING_HREF = /(?:audios|photo|write|owner_id=|friends\?id=)(-?\d+)/.freeze
      private_constant :ID_CONTAINING_HREF

      # User id
      def id
        Integer(@node.link_with(href: ID_CONTAINING_HREF).href.slice(/\d+/), 10)
      end

      # User name
      def name
        @node.title.to_s
      end
    end
  end
end
