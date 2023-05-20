# frozen_string_literal: true

module VkMusic
  module Request
    # Audios reload
    class AudiosReload < Base
      # Initialize new request
      # @param ids [Array<String>]
      # @param client_id [Integer]
      def initialize(ids, client_id)
        @client_id = client_id
        super(
          "#{VK_ROOT}/audio?act=reload_audios",
          { audio_ids: ids.join(',') },
          'POST',
          { 'content-type' => 'application/x-www-form-urlencoded', 'x-requested-with' => 'XMLHttpRequest' }
        )
      end

      def_delegators :@parser, :audios

      private

      def after_call
        @parser = WebParser::AudiosReload.new(@response.body, client_id: @client_id)
      end
    end
  end
end
