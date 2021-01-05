# frozen_string_literal: true

module VkMusic
  module Request
    # Artist audios page request
    class Artist < Base
      # Initialize new request
      # @param name [String]
      # @param client_id [Integer]
      def initialize(name, client_id)
        @client_id = client_id
        super("#{VK_ROOT}/artist/#{name}/top_audios", {}, 'GET', {})
      end

      def_delegators :@parser, :audios

      private

      def after_call
        @parser = WebParser::Artist.new(@response, client_id: @client_id)
      end
    end
  end
end
