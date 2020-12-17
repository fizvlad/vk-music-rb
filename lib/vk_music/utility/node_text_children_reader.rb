# frozen_string_literal: true

module VkMusic
  module Utility
    # Read inner of text-childrens of +Nokogiri::XML::Node+ node
    module NodeTextChildrenReader
      # @param node [Nokogiri::XML::Node]
      # @return [String]
      def self.call(node)
        node.children.select(&:text?).map(&:text).join.strip
      end
    end
  end
end
