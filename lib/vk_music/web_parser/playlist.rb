# frozen_string_literal: true

module VkMusic
  module WebParser
    # Playlist mobile web page parser
    class Playlist < Base
      # @return [Array<Audio>]
      def audios
        return [] if node.nil?

        Utility::AudioItemsParser.call(node, @client_id)
      end

      # @return [String]
      def title
        node.at_css('.audioPlaylist__title').content.strip
      end

      # @return [String?]
      def subtitle
        result = node.at_css('.audioPlaylist__subtitle').content.strip
        return if result.nil? || result.empty?

        result
      end

      # @return [Integer?]
      def real_size
        content = node.at_css('.audioPlaylist__footer').content
        matches = content.gsub(/\s/, '').match(/^(\d+)/)&.captures
        matches ? Integer(matches.first, 10) : nil
      end
    end
  end
end
