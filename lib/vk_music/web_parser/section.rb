# frozen_string_literal: true

module VkMusic
  module WebParser
    # Section JSON parser
    class Section < Base
      # Parsed JSON
      def json
        @json ||= JSON.parse(@node.content.strip)['data'].first || {}
      end

      # @return [Array<Audio>]
      def audios
        return unless json&.key?('list')

        json['list'].map do |el|
          Utility::AudioDataParser.call(el, @client_id)
        end
      end

      # @return [String]
      def title
        return unless json&.key?('title')

        json['title'].to_s
      end

      # @return [String?]
      def subtitle
        return unless json&.key?('rawDescription')

        re = json['rawDescription']
        return if re.empty?

        re
      end

      # @return [Integer?]
      def real_size
        return unless json&.key?('totalCount')

        json['totalCount']
      end

      # @return [Boolean]
      def more?
        return unless json&.key?('hasMore')

        json['hasMore'].to_s == '1'
      end
    end
  end
end
