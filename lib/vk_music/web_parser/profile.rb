# frozen_string_literal: true

module VkMusic
  module WebParser
    # Profile page parser
    class Profile < Base
      # Regex for href which contains id of profile
      ID_CONTAINING_HREF = /(?:audios|photo|write|owner_id=|friends\?id=)(-?\d+)/
      private_constant :ID_CONTAINING_HREF

      # Regex for ID of .wall_item anchor
      POST_ANCHOR_NAME_REGEX = /post(-?\d+)_(\d+)/
      private_constant :POST_ANCHOR_NAME_REGEX

      # CSS selector for link in basis
      BASIS_LINK_SELECTOR = '.basisProfile a,.basisGroup a,.BasisProfile a,.BasisGroup a'
      private_constant :BASIS_LINK_SELECTOR

      # Profile id
      def id
        link = node.link_with(href: ID_CONTAINING_HREF, css: BASIS_LINK_SELECTOR)
        return unless link

        Integer(link.href.match(ID_CONTAINING_HREF).captures.first, 10)
      end

      # Last post ID
      def last_post_id
        ids = node.css('.wall_posts .wall_item').map do |el|
          str = el.at_css('.post__anchor')&.attr('name')&.match(POST_ANCHOR_NAME_REGEX)&.captures&.last
          str ? Integer(str, 10) : nil
        end
        ids.compact.max
      end
    end
  end
end
