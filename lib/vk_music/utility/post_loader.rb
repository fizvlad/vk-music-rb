# frozen_string_literal: true

module VkMusic
  module Utility
    # Load wall audios
    module PostLoader
      # @param agent [Mechanize]
      # @param client_id [Integer]
      # @param owner_id [Integer]
      # @param post_id [Integer]
      # @return [Array<Audio>]
      def self.call(agent, client_id, owner_id, post_id)
        page = Request::Post.new(owner_id, post_id, client_id)
        page.call(agent)
        urlles_audios = page.audios

        wall_audios = WallLoader.call(agent, client_id, owner_id, post_id).audios

        urlles_audios.map { |urlles| wall_audios.find { |audio| audio.like?(urlles) } }.compact
      end
    end
  end
end
