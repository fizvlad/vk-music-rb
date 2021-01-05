# frozen_string_literal: true

module VkMusic
  module WebParser
    # Artist top audios web page
    class Artist < Base
      # @return [Array<Audio>]
      def audios
        audio_section = node.at_css('.AudioSection.AudioSection__artist_audios')
        return [] if audio_section.nil?

        Utility::AudioItemsParser.call(audio_section, @client_id)
      end
    end
  end
end
