# frozen_string_literal: true

module VkMusic
  module WebParser
    # Base class for all web parsers
    class Base
      # @param obj [String, Nokogiri::XML::Searchable]
      def initialize(obj)
        @node = obj.is_a?(String) ? Nokogiri::HTML.fragment(obj) : obj
      end
    end
  end
end
