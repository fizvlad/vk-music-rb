# frozen_string_literal: true

module VkMusic
  module WebParser
    # WallSection JSON parser
    class WallSection < Base
      # Parsed JSON
      def data
        @data ||= json['data'].first || {}
      end

      # @return [Array<Audio>]
      def audios
        return unless data&.key?('list')

        data['list'].map do |el|
          Utility::AudioDataParser.call(el, @client_id)
        end
      end

      # @return [String]
      def title
        return unless data&.key?('title')

        data['title'].to_s
      end

      # @return [String?]
      def subtitle
        return unless data&.key?('rawDescription')

        re = data['rawDescription']
        return if re.nil? || re.empty?

        re
      end

      # @return [Integer?]
      def real_size
        return unless data&.key?('totalCount')

        data['totalCount']
      end

      # @return [Boolean]
      def more?
        return unless data&.key?('hasMore')

        data['hasMore'].to_s == '1'
      end
    end
  end
end
