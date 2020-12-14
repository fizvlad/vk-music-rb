# frozen_string_literal: true

module VkMusic
  module Utility
    # Parse {Audio} from +Array+ of audio data
    class AudioDataParser
      class << self
        # @param data [Array]
        # @param client_id [Integer]
        # @return [Audio]
        def call(data, client_id)
          url_encoded = get_url_encoded(data)
          secrets = get_secrets(data)

          secret1 = secrets[3]
          secret2 = secrets[5]
          secret1 = secret2 if secret1.nil? || secret1.empty?

          Audio.new(id: data[0], owner_id: data[1],
                    secret1: secret1, secret2: secret2,
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
