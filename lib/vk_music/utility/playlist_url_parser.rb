# frozen_string_literal: true

module VkMusic
  module Utility
    # Read inner of text-childrens of +Nokogiri::XML::Node+ node
    module PlaylistUrlParser
      # Regular expression to parse playlist link. Oh my, it is so big
      VK_PLAYLIST_URL_POSTFIX = %r{
        .*                                                              # Garbage
        (?:audio_playlist|album/|playlist/)                             # Start of ids
        (-?\d+)_(\d+)                                                   # Ids themself
        (?:(?:(?:.*(?=&access_hash=)&access_hash=)|/|%2F|_)([\da-z]+))? # Access hash
      }x
      public_constant :VK_PLAYLIST_URL_POSTFIX

      # @param url [String]
      # @return [Array(Integer?, Integer?, String?)] playlist data array:
      #   +[owner_id, playlist_id, access_hash]+
      def self.call(url)
        owner_id, playlist_id, access_hash = url.match(VK_PLAYLIST_URL_POSTFIX).captures

        owner_id = Integer(owner_id, 10)
        playlist_id = Integer(playlist_id, 10)
        access_hash = nil if access_hash&.empty?

        [owner_id, playlist_id, access_hash]
      rescue StandardError
        [nil, nil, nil]
      end
    end
  end
end
