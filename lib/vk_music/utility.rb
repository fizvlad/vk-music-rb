require "cgi"
require "logger"

module VkMusic

  ##
  # Utility methods.
  module Utility
  
    ##
    # Turn amount of seconds into string.
    #
    # @param s [Integer] amount of seconds.
    #
    # @return [String] formatted string.
    def self.format_seconds(s)
      s = s.to_i # Require integer      
      "#{(s / 60).to_s.rjust(2, "0")}:#{(s % 60).to_s.rjust(2, "0")}";
    end
    
    ##
    # Guess type of request by from string.
    #
    # Possible results:
    # * +:playlist+ - if string match playlist URL.
    # * +:post+ - if string match post URL.
    # * +:audios+ - if string match user or group URL.
    # * +:find+ - in rest of cases.
    #
    # @param str [String] request from user for some audios.
    #
    # @return [Symbol]
    def self.guess_request_type(str)
      # Guess what type of request is this. Returns Symbol: :find, :playlist, :audios
      case str
        when Constants::Regex::VK_PLAYLIST_URL_POSTFIX
          :playlist
        when Constants::Regex::VK_WALL_URL_POSTFIX, Constants::Regex::VK_POST_URL_POSTFIX
          :post
        when Constants::Regex::VK_URL
          :audios
      else
        :find
      end
    end

    ##
    # Turn hash into URL query string.
    #
    # @param hash [Hash]
    #
    # @return [String]
    def self.hash_to_params(hash = {})
      qs = ""
      hash.each_key do |key|
        qs << "&" unless qs.empty?
        case hash[key]
          when Array
            qs << CGI.escape(key.to_s) << "=" << hash[key].map { |value| CGI.escape(value.to_s) }.join(",")
          else
            qs << CGI.escape(key.to_s) << "=" << CGI.escape(hash[key].to_s)
        end
      end
      qs
    end

    ##
    # Utility loggers
    @@loggers = {
      debug: Logger.new(STDOUT),
      warn: Logger.new(STDERR)
    }
    @@loggers[:debug].level = Logger::DEBUG
    @@loggers[:warn].level = Logger::WARN

    ##
    # Send warning.
    def self.warn(*args)
      @@loggers[:warn].warn(args.join("\n"))
    end

    ##
    # Send debug message.
    def self.debug(*args)
      @@loggers[:debug].debug(args.join("\n")) if $DEBUG
    end

    ##
    # Function to turn values into given class unless nil provided
    #
    # Supported types:
    # * +String+
    # * +Integer+
    #
    # @param new_class [Class] class to transform to.
    # @param obj [Object] object to check.
    #
    # @return object transformed to given class or +nil+ if object was +nil+ already.
    def self.unless_nil_to(new_class, obj)
      case
        when obj.nil?
          nil
        when String <= new_class
          obj.to_s
        when Integer <= new_class
          obj.to_i
        else
          raise ArgumentError, "Bad arguments", caller
      end
    end
    
  end
  
end
