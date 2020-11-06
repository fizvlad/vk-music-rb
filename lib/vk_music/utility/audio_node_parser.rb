# frozen_string_literal: true

module VkMusic
  # Parse {Audio} from +Nokogiri::XML::Node+
  class AudioNodeParser
    class << self
      # @param node [Nokogiri::XML::Node]
      # @param client_id [Integer]
      # @return [Audio]
      def call(node, client_id)
        input = node.at_css('input')
        if input
          url_encoded = input.attribute('value').to_s
          url_encoded = nil if url_encoded == Constants::URL::VK[:audio_unavailable] || url_encoded.empty?
          id_array = node.attribute('data-id').to_s.split('_')

          new(
            id: id_array[1].to_i,
            owner_id: id_array[0].to_i,
            artist: node.at_css('.ai_artist').text.strip,
            title: node.at_css('.ai_title').text.strip,
            duration: node.at_css('.ai_dur').attribute('data-dur').to_s.to_i,
            url_encoded: url_encoded,
            url: nil,
            client_id: client_id
          )
        else
          new(
            artist: node.at_css('.medias_music_author').text.strip,
            title: Utility.plain_text(node.at_css('.medias_audio_title')).strip,
            duration: Utility.parse_duration(node.at_css('.medias_audio_dur').text)
          )
        end
      end

      private

      def parse_post(node, client_id)
        artist = node.at_css('.medias_music_author').text.strip
        title = NodeTextChildrenReader.call(node.at_css('.medias_audio_title'))
        duration = DurationParser.call(node.at_css('.medias_audio_dur').text)
        new(
          artist: artist,
          title: title,
          duration: duration,
          client_id: client_id
        )
      end
    end
  end
end
