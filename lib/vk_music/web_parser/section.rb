# frozen_string_literal: true

module VkMusic
  module WebParser
    # Section JSON parser
    class Section < Base
      # Parsed JSON
      def json
        @json ||= JSON.parse(@node.content.strip)['data'].first
      end

      # @return [Array<Audio>]
      def audios
        return [] if json.nil? || !json.key?('list')

        json['list'].map do |el|
          Utility::AudioDataParser.call(el, @client_id)
        end
      end

      # @return [String]
      def title
        json['title']
      end

      # @return [String?]
      def subtitle
        re = json['rawDescription']
        return if re&.empty?

        re
      end

      # @return [Integer?]
      def real_size
        json['totalCount']
      end

      # @return [Boolean]
      def more?
        json['hasMore'].to_s == '1'
      end
    end
  end
end
