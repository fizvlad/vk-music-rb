# frozen_string_literal: true

module VkMusic
  module Utility
    # Read inner of text-childrens of +Nokogiri::XML::Node+ node
    class PlaylistLoader
      class << self
        # @param agent [Mechanize]
        # @param client_id [Integer]
        # @param owner_id [Integer]
        # @param playlist_id [Integer]
        # @param access_hash [String, nil]
        # @param up_to [Integer]
        # @return [Playlist]
        def call(agent, client_id, owner_id, playlist_id, access_hash, up_to)
          page = Request::Playlist.new(owner_id, playlist_id, access_hash, client_id)
          page.call(agent)
          audios = page.audios
          up_to = page.real_size if up_to > page.real_size

          section_loop(audios, agent, client_id, owner_id, playlist_id, access_hash, up_to)

          audios = audios.first(up_to)
          Playlist.new(audios, id: playlist_id, owner_id: owner_id, access_hash: access_hash,
                               title: page.title, subtitle: page.subtitle, real_size: page.real_size)
        end

        private

        def section_loop(audios, agent, client_id, owner_id, playlist_id, access_hash, up_to)
          while audios.size < up_to
            section = Request::Section.new(owner_id, playlist_id, access_hash, audios.size, client_id)
            section.call(agent)
            break if section.audios.empty? || !section.more?

            audios += section.audios
          end
        end
      end
    end
  end
end
