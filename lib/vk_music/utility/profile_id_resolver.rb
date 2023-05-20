# frozen_string_literal: true

module VkMusic
  module Utility
    # Get user or group id from url
    module ProfileIdResolver
      # vk.com url regex
      VK_PATH = %r{(?:https?://)?(?:vk\.com/)?([^/?&]+)}
      public_constant :VK_PATH

      # audios list page
      AUDIOS_PATH = /audios(-?\d+)/
      public_constant :AUDIOS_PATH

      # vk.com user path regex
      USER_PATH = /id(\d+)/
      public_constant :USER_PATH

      # vk.com user club regex
      CLUB_PATH = /(?:club|group|public|event)(\d+)/
      public_constant :CLUB_PATH

      class << self
        # @param agent [Mechanize]
        # @param url [String] URL to profile page
        # @return [Integer?] ID of profile or +nil+ if not a profile page
        def call(agent, url)
          path = url.match(VK_PATH)&.captures&.first
          return unless path

          direct_match = direct_match(path)
          return direct_match if direct_match

          request = VkMusic::Request::Profile.new(profile_custom_path: path)
          request.call(agent)
          request.id
        rescue Mechanize::ResponseCodeError
          nil
        end

        private

        def direct_match(path)
          audios_match = path.match(AUDIOS_PATH)
          return Integer(audios_match.captures.first, 10) if audios_match

          user_match = path.match(USER_PATH)
          return Integer(user_match.captures.first, 10) if user_match

          club_match = path.match(CLUB_PATH)
          return -1 * Integer(club_match.captures.first, 10) if club_match

          nil
        end
      end
    end
  end
end
