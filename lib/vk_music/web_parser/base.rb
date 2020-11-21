# frozen_string_literal: true

module VkMusic
  module WebParser
    # Base class for all web parsers
    class Base
      # @param content [String, Nokogiri::XML::Searchable]
      # @param client_id [Integer?]
      def initialize(content, client_id: nil)
        @content = content
        @client_id = client_id
      end

      private

      attr_reader :content

      def node
        @node ||= @content.is_a?(String) ? Nokogiri::HTML.fragment(@content) : @content
      end

      def json
        @json ||= JSON.parse(@content.is_a?(String) ? @content : @content.body)
      end
    end
  end
end
