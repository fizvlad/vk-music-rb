# frozen_string_literal: true

module VkMusic
  module Utility
    # Load ids from array of data
    module AudiosIdsGetter
      # @param args [Array<Audio, (owner_id, audio_id, secret_1, secret_2),
      #   "#{owner_id}_#{id}_#{secret_1}_#{secret_2}">]
      # @return [Array<String>] array of uniq full ids
      def self.call(args)
        ids = args.map do |item|
          case item
          when Audio then item.full_id
          when Array then item.join('_')
          when String then item
          end
        end
        ids.compact!
        ids.uniq!

        ids
      end
    end
  end
end
