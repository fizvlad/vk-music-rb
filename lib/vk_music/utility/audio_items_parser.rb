# frozen_string_literal: true

module VkMusic
  module Utility
    # Parse {Audio} from +Nokogiri::XML::Node+
    module AudioItemsParser
      # @param node [Nokogiri::XML::Node]
      # @param client_id [Integer]
      # @return [Array<Audio>]
      def self.call(node, client_id)
        node.css('.audio_item.ai_has_btn,.audio_item.audio_item_disabled').map do |elem|
          data = JSON.parse(elem.attribute('data-audio').value)
          Utility::AudioDataParser.call(data, client_id)
        end
      end
    end
  end
end
