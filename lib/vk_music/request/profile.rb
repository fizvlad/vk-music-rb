# frozen_string_literal: true

module VkMusic
  module Request
    # User or group page
    class Profile < Base
      # Initialize new request
      def initialize(profile_id: nil, profile_custom_path: nil)
        profile_path =
          profile_custom_path ||
          "#{profile_id.negative? ? 'club' : 'id'}#{profile_id.abs}"
        super("#{VK_ROOT}/#{profile_path}", {}, 'GET', {})
      end

      def_delegators :@parser, :id, :last_post_id

      private

      def after_call
        @parser = WebParser::Profile.new(@response)
      end
    end
  end
end
