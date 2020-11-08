# frozen_string_literal: true

module VkMusic
  module WebParser
    # Base class for all web parsers
    class Base
      # @param obj [String, Nokogiri::XML::Searchable]
      # @param client_id [Integer?]
      def initialize(obj, client_id: nil)
        @node = obj.is_a?(String) ? Nokogiri::HTML.fragment(obj) : obj
        @client_id = client_id
      end
    end
  end
end
