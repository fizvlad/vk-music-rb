# frozen_string_literal: true

module VkMusic
  module Utility
    # Get user or group id from url
    class LastProfilePostLoader
      # vk.com url regex
      VK_URL = %r{(?:https?://)?(?:vk\.com/)?([^/?&]+)}.freeze
      private_constant :VK_URL

      # @param agent [Mechanize]
      # @param url [String] URL to profile page
      # @return [Array(owner_id?, post_id?)]
      def self.call(agent, url: nil, owner_id: nil)
        path = url&.match(VK_URL)&.captures&.first
        request = VkMusic::Request::Profile.new(profile_id: owner_id, profile_custom_path: path)
        request.call(agent)
        [request.id, request.last_post_id]
      rescue Mechanize::ResponseCodeError
        [nil, nil]
      end
    end
  end
end
