# frozen_string_literal: true

module VkMusic
  module Request
    # Playlist in web-mobile request
    class Playlist < Base
      # Initialize new request
      # @param owner_id [Integer]
      # @param playlist_id [Integer]
      # @param access_hash [String, nil]
      # @param client_id [Integer]
      def initialize(owner_id, playlist_id, access_hash, client_id)
        @client_id = client_id
        super(
          "#{VK_ROOT}/audio",
          { act: "audio_playlist#{owner_id}_#{playlist_id}", access_hash: access_hash },
          'GET',
          {}
        )
      end

      def_delegators :@parser, :audios, :title, :subtitle, :real_size

      private

      def after_call
        @parser = WebParser::Playlist.new(@response.body)
      end
    end
  end
end
