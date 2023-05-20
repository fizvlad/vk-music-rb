# frozen_string_literal: true

module VkMusic
  module Utility
    # Load playlist audios
    module PlaylistLoader
      # @param agent [Mechanize]
      # @param client_id [Integer]
      # @param owner_id [Integer]
      # @param playlist_id [Integer]
      # @param access_hash [String, nil]
      # @param up_to [Integer]
      # @return [Playlist?]
      def self.call(agent, client_id, owner_id, playlist_id, access_hash, up_to)
        page = Request::Playlist.new(owner_id, playlist_id, access_hash, client_id)
        page.call(agent)
        audios = page.audios
        return if audios.nil? || audios.empty?

        up_to = page.real_size if up_to > page.real_size

        rest = PlaylistSectionLoader.call(agent, client_id, owner_id, playlist_id, access_hash,
                                          audios.size, up_to - audios.size)
        audios.concat(rest)
        Playlist.new(audios, id: playlist_id, owner_id:, access_hash:,
                             title: page.title, subtitle: page.subtitle, real_size: page.real_size)
      end
    end
  end
end
