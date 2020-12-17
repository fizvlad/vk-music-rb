# frozen_string_literal: true

module VkMusic
  module Utility
    # Parse {Audio} from +Array+ of audio data
    module AudioDataParser
      class << self
        # @param data [Array]
        # @param client_id [Integer]
        # @return [Audio]
        def call(data, client_id)
          url_encoded = get_url_encoded(data)
          _add_hash, _edit_hash, action_hash, _delete_hash, _teplace_hash, url_hash = get_secrets(data)

          Audio.new(id: data[0], owner_id: data[1],
                    secret1: action_hash, secret2: url_hash,
                    artist: CGI.unescapeHTML(data[4]), title: CGI.unescapeHTML(data[3]),
                    duration: data[5],
                    url_encoded: url_encoded, url: nil, client_id: client_id)
        end

        private

        def get_url_encoded(data)
          url_encoded = data[2].to_s
          url_encoded = nil if url_encoded.empty?

          url_encoded
        end

        def get_secrets(data)
          data[13].to_s.split('/')
        end
      end
    end
  end
end
