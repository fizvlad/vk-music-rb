# frozen_string_literal: true

module VkMusic
  module Utility
    # Reads preserved cookies from file and writes them into a cookie jar
    module CookieReader
      class << self
        # @param jar [HTTP::CookieJar]
        # @param path [string]
        def call(jar, path)
          data = File.read(path)
          data.start_with?('{') ? load_cookie_jar_json(jar, data) : load_cookie_jar_mechanize(jar)
        end

        private

        # Loads cookies from JSON data
        def load_cookie_jar_json(jar, data)
          VkMusic.log.info('cookie_reader') { 'Loading JSON cookies' }
          JSON.parse(data).each_pair do |k, v|
            jar.add(URI('https://m.vk.com'), HTTP::Cookie.new(k, v))
          end
        end

        # Loads cookies from Mechanize file
        def load_cookie_jar_mechanize(jar)
          VkMusic.log.info('cookie_reader') { 'Loading Mechanize cookies' }
          jar.load(AGENT_COOKIES_PATH)
        end
      end
    end
  end
end
