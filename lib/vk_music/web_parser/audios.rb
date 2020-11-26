# frozen_string_literal: true

module VkMusic
  module WebParser
    # Audios reload JSON parser
    class AudiosReload < Base
      # Array with audio data
      def audios_data
        @audios_data ||= json['data'].first || []
      end

      # @return [Array<Audio>]
      def audios
        audios_data.map do |el|
          Utility::AudioDataParser.call(el, @client_id)
        end
      end
    end
  end
end
