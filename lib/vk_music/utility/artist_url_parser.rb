# frozen_string_literal: true

module VkMusic
  module Utility
    # Artist URL parser
    module ArtistUrlParser
      # Regex for artist URL
      ARTIST_POSTFIX = %r{.*artist/([\w.\-~]+)}
      public_constant :ARTIST_POSTFIX

      # Get artist name based on provided URL

      # @param url [String]
      # @return [String?]
      def self.call(url)
        url.match(ARTIST_POSTFIX)&.captures&.first
      rescue StandardError
        nil
      end
    end
  end
end
