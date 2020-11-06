require_relative 'utility/log'

module VkMusic
  ##
  # Utility methods.
  module Utility
    ##
    # Turn amount of seconds into string.
    # @param s [Integer] amount of seconds.
    # @return [String] formatted string.
    def self.format_seconds(s)
      s = s.to_i # Require integer
      "#{(s / 60).to_s.rjust(2, '0')}:#{(s % 60).to_s.rjust(2, '0')}"
    end

    ##
    # Guess type of request by from string.
    #
    # Possible results:
    # * +:playlist+ - if string match playlist URL.
    # * +:post+ - if string match post URL.
    # * +:audios+ - if string match user or group URL.
    # * +:find+ - in rest of cases.
    # @param str [String] request from user for some audios.
    # @return [Symbol]
    def self.guess_request_type(str)
      case str
      when Constants::Regex::VK_PLAYLIST_URL_POSTFIX
        :playlist
      when Constants::Regex::VK_WALL_URL_POSTFIX, Constants::Regex::VK_POST_URL_POSTFIX
        :post
      when Constants::Regex::VK_BLOCK_URL
        :block
      when Constants::Regex::VK_URL
        :audios
      else
        :find
      end
    end

    ##
    # Turn hash into URL query string.
    # @param hash [Hash]
    # @return [String]
    def self.hash_to_params(hash = {})
      qs = ''
      hash.each_key do |key|
        qs << '&' unless qs.empty?
        qs << CGI.escape(key.to_s) << '=' << case hash[key]
                                             when Array
                                               hash[key].map { |value| CGI.escape(value.to_s) }.join(',')
                                             else
                                               CGI.escape(hash[key].to_s)
                                             end
      end
      qs
    end
  end
end
