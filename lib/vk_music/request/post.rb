# frozen_string_literal: true

module VkMusic
  module Request
    # Post page
    class Post < Base
      # Initialize new request
      def initialize(owner_id, post_id, client_id)
        @client_id = client_id
        super("#{VK_ROOT}/wall#{owner_id}_#{post_id}", {}, 'GET', {})
      end

      def_delegators :@parser, :audios

      private

      def after_call
        @parser = WebParser::Post.new(@response, client_id: @client_id)
      end
    end
  end
end
