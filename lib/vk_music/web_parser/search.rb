# frozen_string_literal: true

module VkMusic
  module WebParser
    # Audio search page parser
    class Search < Base
      # Audios found
      # @return [Array<Audio>]
      def audios
        title_index = search_result_blocks.find_index { |node| node.inner_text.include?('Все аудиозаписи') }
        return [] if title_index.nil?

        block = search_result_blocks[title_index + 1]

        Utility::AudioItemsParser(block, @client_id)
      end

      # Path to page with all results
      # @return [String?]
      def audios_all_path
        title = search_result_blocks.find { |node| node.inner_text.include?('Все аудиозаписи') }
        return if title.nil?

        title.at_css('a').attribute('href').value
      end

      # Playlists found
      # @return [Array<Playlist>]
      def playlists
        title_index = search_result_blocks.find_index { |node| node.inner_text.include?('Альбомы') }
        return [] if title_index.nil?

        block = search_result_blocks[title_index + 1]

        block.css('.audioPlaylists__item').map do |elem|
          Utility::PlaylistNodeParser.call(elem)
        end
      end

      # Path to page with all results
      # @return [String?]
      def playlists_all_path
        title = search_result_blocks.find { |node| node.inner_text.include?('Альбомы') }
        return if title.nil?

        title.at_css('a').attribute('href').value
      end

      private

      def search_result_blocks
        @search_result_blocks ||= @node.css('.AudioBlock').children
      end
    end
  end
end
