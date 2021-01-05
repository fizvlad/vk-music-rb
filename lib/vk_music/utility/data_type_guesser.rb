# frozen_string_literal: true

require_relative 'playlist_url_parser'
require_relative 'post_url_parser'

module VkMusic
  module Utility
    # Guess type of method to use based on string data
    module DataTypeGuesser
      # End of playlist URL
      PLAYLIST_POSTFIX = PlaylistUrlParser::VK_PLAYLIST_URL_POSTFIX
      public_constant :PLAYLIST_POSTFIX

      # Artist URL postfix
      ARTIST_POSTFIX = ArtistUrlParser::ARTIST_POSTFIX
      public_constant :ARTIST_POSTFIX

      # End of post URL
      POST_POSTFIX = PostUrlParser::POST_POSTFIX
      public_constant :POST_POSTFIX

      # End of wall URL
      WALL_POSTFIX = /.*wall(-?\d+)/.freeze
      public_constant :WALL_POSTFIX

      # End of profile audios URL
      AUDIOS_POSTFIX = /.*audios(-?\d+)/.freeze
      public_constant :AUDIOS_POSTFIX

      # Full profile URL regex
      PROFILE_URL = %r{(?:https?://)?(?:vk\.com/)([^/?&]+)}.freeze
      public_constant :PROFILE_URL

      # @param data [String]
      # @return [Symbol]
      def self.call(data)
        case data
        when PLAYLIST_POSTFIX then :playlist
        when ARTIST_POSTFIX then :artist
        when POST_POSTFIX then :post
        when WALL_POSTFIX then :wall
        when AUDIOS_POSTFIX, PROFILE_URL then :audios
        else :find
        end
      end
    end
  end
end
