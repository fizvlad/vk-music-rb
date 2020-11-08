# frozen_string_literal: true

module VkMusic
  module WebParser
    # Current user page parser
    class MyPage < Base
      # User id
      def id
        link = @node.at_css('.ip_user_link .op_owner')
        Integer(link.attribute('href').value.delete_prefix('/id'), 10)
      end

      # User name
      def name
        link = @node.at_css('.ip_user_link .op_owner')
        link.attribute('data-name').value
      end
    end
  end
end
