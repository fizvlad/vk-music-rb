# frozen_string_literal: true

module VkMusic
  module WebParser
    # Profile page parser
    class Profile < Base
      # Regex for href which contains id of profile
      ID_CONTAINING_HREF = /(?:audios|photo|write|owner_id=|friends\?id=)(-?\d+)/.freeze
      private_constant :ID_CONTAINING_HREF

      # Profile id
      def id
        link = @node.link_with(href: ID_CONTAINING_HREF, css: '.basisProfile a,.basisGroup a')
        return unless link

        Integer(link.href.match(ID_CONTAINING_HREF).captures.first, 10)
      end
    end
  end
end
