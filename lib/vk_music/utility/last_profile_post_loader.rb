# frozen_string_literal: true

require_relative 'profile_id_resolver'

module VkMusic
  module Utility
    # Get user or group id from url
    module LastProfilePostLoader
      # vk.com url regex
      VK_PATH = ProfileIdResolver::VK_PATH
      private_constant :VK_PATH

      # @param agent [Mechanize]
      # @param url [String] URL to profile page
      # @return [Array(owner_id?, post_id?)]
      def self.call(agent, url: nil, owner_id: nil)
        path = url&.match(VK_PATH)&.captures&.first
        request = VkMusic::Request::Profile.new(profile_id: owner_id, profile_custom_path: path)
        request.call(agent)
        [request.id, request.last_post_id]
      rescue Mechanize::ResponseCodeError
        [nil, nil]
      end
    end
  end
end
