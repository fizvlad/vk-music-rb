# frozen_string_literal: true

module VkMusic
  module Utility
    # Parse {Audio} from +Nokogiri::XML::Node+
    module AudioNodeParser
      class << self
        # @param node [Nokogiri::XML::Node]
        # @param client_id [Integer]
        # @return [Audio]
        def call(node, client_id)
          input = node.at_css('input')
          if input
            parse_input(input, node, client_id)
          else
            parse_post(node, client_id)
          end
        end

        private

        def parse_input(input, node, client_id)
          id_array = get_id_array(node)
          artist, title, duration = get_main_data(node)

          Audio.new(id: Integer(id_array[1], 10), owner_id: Integer(id_array[0], 10),
                    artist: artist, title: title, duration: duration,
                    url_encoded: get_encoded_url(input), url: nil, client_id: client_id)
        end

        def get_encoded_url(input)
          url_encoded = input.attribute('value').to_s
          url_encoded = nil if url_encoded.empty? || url_encoded == Constants::URL::VK[:audio_unavailable]

          url_encoded
        end

        def get_id_array(node)
          node.attribute('data-id').to_s.split('_')
        end

        def get_main_data(node)
          [
            node.at_css('.ai_artist').text.strip,
            node.at_css('.ai_title').text.strip,
            Integer(node.at_css('.ai_dur').attribute('data-dur').to_s, 10)
          ]
        end

        def parse_post(node, client_id)
          artist = node.at_css('.medias_music_author').text.strip
          title = NodeTextChildrenReader.call(node.at_css('.medias_audio_title'))
          duration = DurationParser.call(node.at_css('.medias_audio_dur').text)
          Audio.new(artist: artist, title: title, duration: duration, client_id: client_id)
        end
      end
    end
  end
end
