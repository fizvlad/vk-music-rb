# frozen_string_literal: true

module VkMusic
  module Utility
    # Load wall audios
    module WallLoader
      # @param agent [Mechanize]
      # @param client_id [Integer]
      # @param owner_id [Integer]
      # @param post_id [Integer]
      # @param up_to [Integer]
      # @return [Playlist?]
      def self.call(agent, client_id, owner_id, post_id)
        page = Request::WallSection.new(owner_id, post_id, client_id)
        page.call(agent)
        audios = page.audios
        return if audios.nil? || audios.empty?

        Playlist.new(audios, id: 0, owner_id: owner_id, access_hash: '',
                             title: page.title, subtitle: page.subtitle,
                             real_size: audios.size)
      end
    end
  end
end
