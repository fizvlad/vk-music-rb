# frozen_string_literal: true

module VkMusic
  module Utility
    # Reads preserved cookies from file and writes them into a cookie jar
    module CookieReader
      class << self
        # @param jar [HTTP::CookieJar]
        # @param data [string]
        def call(jar, data)
          return load_cookie_jar_json(jar, data) if data.start_with?('{')

          return load_cookie_jar_mechanize(jar, data) if data.start_with?('---')

          load_cookie_jar_string(jar, data)
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
        def load_cookie_jar_mechanize(jar, data)
          VkMusic.log.info('cookie_reader') { 'Loading Mechanize cookies' }
          file = Tempfile.new
          file.write(data)
          file.rewind
          jar.load(file)
          file.unlink
        end

        # Loads cookies from string
        def load_cookie_jar_string(jar, data)
          VkMusic.log.info('cookie_reader') { 'Loading String cookies' }
          data.split(';').each do |part|
            k, v = part.strip.split('=', 2)
            jar.add(URI('https://m.vk.com'), HTTP::Cookie.new(k, v))
          end
        end
      end
    end
  end
end
