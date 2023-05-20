# frozen_string_literal: true

module VkMusic
  module WebParser
    # Current user page parser
    class MyPage < Base
      # User id
      def id
        Integer(node.content.match(/window.vk = {"id":(\d+)/).captures.first, 10)
      end

      # User name
      def name
        node.at_css('.ip_user_link .op_owner')&.attribute('data-name')&.value || 'Unknown User'
      end
    end
  end
end
