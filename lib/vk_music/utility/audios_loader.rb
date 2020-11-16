# frozen_string_literal: true

module VkMusic
  module Utility
    # Load user or group audios
    class AudiosLoader
      # @param agent [Mechanize]
      # @param client_id [Integer]
      # @param owner_id [Integer]
      # @param up_to [Integer]
      # @return [Playlist?]
      def self.call(agent, client_id, owner_id, up_to)
        page = Request::Section.new(owner_id, -1, '', 0, client_id)
        page.call(agent)
        audios = page.audios
        return if audios.nil? || audios.empty?

        up_to = page.real_size if up_to > page.real_size

        rest = SectionLoader.call(agent, client_id, owner_id, -1, '', audios.size, up_to - audios.size)
        audios.concat(rest)

        Playlist.new(audios, id: -1, owner_id: owner_id, access_hash: '',
                             title: page.title, subtitle: page.subtitle, real_size: page.real_size)
      end
    end
  end
end
