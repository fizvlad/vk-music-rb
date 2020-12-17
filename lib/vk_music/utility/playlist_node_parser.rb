# frozen_string_literal: true

module VkMusic
  module Utility
    # Read inner of text-childrens of +Nokogiri::XML::Node+ node
    module PlaylistNodeParser
      # @param node [Nokogiri::XML::Node]
      # @return [Playlist]
      def self.call(node)
        url = node.at_css('.audioPlaylists__itemLink').attribute('href').value
        owner_id, id, access_hash = PlaylistUrlParser.call(url)

        Playlist.new([],
                     id: id, owner_id: owner_id, access_hash: access_hash,
                     title: node.at_css('.audioPlaylists__itemTitle').content,
                     subtitle: node.at_css('.audioPlaylists__itemSubtitle').content,
                     real_size: nil)
      end
    end
  end
end
