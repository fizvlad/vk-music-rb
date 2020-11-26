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

      def_delegators :@parser, :audios, :audios_all_path, :playlists, :playlists_all_path

      private

      def after_call
        json = JSON.parse(@response.body.strip)
        raise 'Captcha requested' if json['key'] == 'captcha_key'

        inner = json['data'][2]
        html = Nokogiri::HTML.fragment(CGI.unescapeElement(inner))
        @parser = WebParser::Search.new(html)
      end
    end
  end
end
