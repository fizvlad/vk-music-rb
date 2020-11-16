# frozen_string_literal: true

module VkMusic
  module Utility
    # Load sections into playlist
    class SectionLoader
      # @param agent [Mechanize]
      # @param client_id [Integer]
      # @param owner_id [Integer]
      # @param playlist_id [Integer]
      # @param access_hash [String, nil]
      # @param offset [Integer]
      # @param up_to [Integer]
      # @return [Array<Audio>]
      def self.call(agent, client_id, owner_id, playlist_id, access_hash, offset, up_to)
        audios = []

        while audios.size < up_to
          section = Request::Section.new(owner_id, playlist_id, access_hash, offset + audios.size, client_id)
          section.call(agent)
          audios.concat(section.audios)
          break if section.audios.empty? || !section.more?
        end

        audios.first(up_to)
      end
    end
  end
end
