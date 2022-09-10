# frozen_string_literal: true

module VkMusic
  module Request
    # Playlist in web-mobile request
    class PlaylistSection < Base
      # Initialize new request
      # @param owner_id [Integer]
      # @param playlist_id [Integer]
      # @param access_hash [String, nil]
      # @param offset [Integer]
      # @param client_id [Integer]
      def initialize(owner_id, playlist_id, access_hash, offset, client_id)
        @client_id = client_id
        super(
          "#{VK_ROOT}/audio",
          {
            act: 'load_section', type: 'playlist', offset:, utf8: true,
            owner_id:, playlist_id:, access_hash: access_hash.to_s
          },
          'GET',
          {}
        )
      end

      def_delegators :@parser, :audios, :title, :subtitle, :real_size, :more?

      private

      def after_call
        @parser = WebParser::PlaylistSection.new(@response, client_id: @client_id)
      end
    end
  end
end
