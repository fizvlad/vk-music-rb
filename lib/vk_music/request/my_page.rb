# frozen_string_literal: true

module VkMusic
  module Request
    # Logging in request
    class MyPage < Base
      # @return [Integer]
      attr_reader :id
      # @return [String]
      attr_reader :name

      # Initialize new request
      def initialize
        super("#{VK_ROOT}/id0", {}, 'GET', {})
        @id = nil
        @name = nil
      end

      private

      def after_call
        parser = WebParser::MyPage.new(@response)
        @id = parser.id
        @name = parser.name
      end
    end
  end
end
