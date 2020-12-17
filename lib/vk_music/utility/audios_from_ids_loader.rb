# frozen_string_literal: true

module VkMusic
  module Utility
    # Load audios from ids
    module AudiosFromIdsLoader
      # @param agent [Mechanize]
      # @param ids [Array<String>]
      # @return [Array<Audio>]
      def self.call(agent, ids, client_id)
        audios = []
        ids.each_slice(10) do |subarray|
          page = Request::AudiosReload.new(subarray, client_id)
          page.call(agent)
          audios.concat(page.audios)
        end
        audios
      end
    end
  end
end
