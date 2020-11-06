# frozen_string_literal: true

module VkMusic
  # Read inner of text-childrens of +Nokogiri::XML::Node+ node
  class NodeTextChildrenReader
    # @param node [Nokogiri::XML::Node]
    # @return [String]
    def self.call(node)
      node.children.select(&:text?).map(&:text).join('').strip
    end
  end
end