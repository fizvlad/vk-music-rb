# frozen_string_literal: true

module VkMusic
  module WebParser
    # Post page web parser
    class Post < Base
      # @return [Array<Audio>]
      def audios
        node.css('.wi_body > .pi_medias .medias_audio').map do |el|
          Utility::AudioNodeParser.call(el, @client_id)
        end
      end
    end
  end
end
