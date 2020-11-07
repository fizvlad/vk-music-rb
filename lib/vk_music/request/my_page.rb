# frozen_string_literal: true

module VkMusic
  module Request
    # Logging in request
    class MyPage < Base
      # Initialize new request
      def initialize
        super("#{VK_ROOT}/id0", {}, 'GET', {})
      end

      def_delegators :@parser, :id, :name

      private

      def after_call
        @parser = WebParser::MyPage.new(@response)
      end
    end
  end
end
