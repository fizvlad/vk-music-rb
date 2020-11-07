# frozen_string_literal: true

module VkMusic
  module WebParser
    # Audio search page parser
    class Search < Base
      # Audios found
      def audios
        title_index = search_result_blocks.find_index { |node| node.inner_text.include?('Все аудиозаписи') }
        block = search_result_blocks[title_index + 1]

        block.css('.audio_item.ai_has_btn').map do |elem|
          data = JSON.parse(elem.attribute('data-audio').value)
          Utility::AudioDataParser.call(data, @client_id)
        end
      end

      # Link to page with all results
      def audios_all_path
        title = search_result_blocks.find { |node| node.inner_text.include?('Все аудиозаписи') }
        title.at_css('a').attribute('href').value

        block.css('.audioPlaylists__item').map do |elem|
          Utility::PlaylistNodeParser.call(elem)
        end
      end

      # Playlists found
      def playlists
        title_index = search_result_blocks.find_index { |node| node.inner_text.include?('Альбомы') }
        block = search_result_blocks[title_index + 1]

        # TODO
        []
      end

      # Link to page with all results
      def playlists_all_path
        title = search_result_blocks.find { |node| node.inner_text.include?('Альбомы') }
        title.at_css('a').attribute('href').value
      end

      private

      def search_result_blocks
        @search_result_blocks ||= @node.css('.AudioBlock').children
      end
    end
  end
end
