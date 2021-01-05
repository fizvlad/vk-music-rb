# frozen_string_literal: true

module VkMusic
  module Utility
    # Load artist top audios
    module ArtistLoader
      # @param agent [Mechanize]
      # @param client_id [Integer]
      # @param name [String]
      # @return [Array<Audio>]
      def self.call(agent, client_id, name)
        page = Request::Artist.new(name, client_id).call(agent)
        page.audios
      end
    end
  end
end
