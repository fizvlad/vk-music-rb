# frozen_string_literal: true

module VkMusic
  module Request
    # Wall in JSON sections request
    class WallSection < Base
      # Initialize new request
      # @param owner_id [Integer]
      # @param post_id [Integer]
      # @param offset [Integer]
      # @param client_id [Integer]
      def initialize(owner_id, post_id, client_id)
        @client_id = client_id
        super(
          "#{VK_ROOT}/audio",
          {
            act: 'load_section', type: 'wall', utf8: true,
            owner_id: owner_id, post_id: post_id, wall_type: 'own'
          },
          'GET',
          {}
        )
      end

      def_delegators :@parser, :audios, :title, :subtitle, :real_size, :more?

      private

      def after_call
        @parser = WebParser::WallSection.new(@response, client_id: @client_id)
      end
    end
  end
end
