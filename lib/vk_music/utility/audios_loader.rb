# frozen_string_literal: true

module VkMusic
  module Utility
    # Load user or group audios
    module AudiosLoader
      class << self
        # @param agent [Mechanize]
        # @param client_id [Integer]
        # @param owner_id [Integer]
        # @param up_to [Integer]
        # @return [Playlist?]
        def call(agent, client_id, owner_id, up_to)
          page = Request::PlaylistSection.new(owner_id, -1, '', 0, client_id).call(agent)
          audios = page.audios
          return if audios.nil? || audios.empty?

          up_to = page.real_size if up_to > page.real_size

          load_till_up_to(audios, agent, client_id, owner_id, up_to)

          Playlist.new(audios, id: -1, owner_id:, access_hash: '',
                               title: page.title, subtitle: page.subtitle, real_size: page.real_size)
        end

        private

        def load_till_up_to(audios, agent, client_id, owner_id, up_to)
          return audios.slice!(up_to..) if up_to <= audios.size

          rest = PlaylistSectionLoader.call(agent, client_id, owner_id, -1, '', audios.size, up_to - audios.size)
          audios.concat(rest)
        end
      end
    end
  end
end
