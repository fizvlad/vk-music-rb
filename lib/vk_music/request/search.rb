# frozen_string_literal: true

module VkMusic
  module Request
    # Logging in request
    class Search < Base
      # Initialize new request
      # @param query [String]
      # @param client_id [Integer]
      def initialize(query, client_id)
        @client_id = client_id
        super(
          "#{VK_ROOT}/audio",
          { q: query, _ajax: 1 },
          'POST',
          { 'content-type' => 'application/x-www-form-urlencoded', 'x-requested-with' => 'XMLHttpRequest' }
        )
      end

      # @return [Array<Audio>]
      def audios
        @parser.audios
      end

      # @return [String?]
      def all_audios_link
        # TODO
      end

      # @return [Array<Playlist>]
      def playlists
        @parser.playlists
      end

      # @return [String?]
      def all_playlists_link
        # TODO
      end

      private

      def after_call
        inner = JSON.parse(@response.body.strip)['data'][2]
        html = Nokogiri::HTML.fragment(CGI.unescapeElement(inner))
        @parser = WebParser::Search.new(html)
      end
    end
  end
end
