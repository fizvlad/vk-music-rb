require "cgi"

module VkMusic

  # Utility methods.
  module Utility
  
    # Turn amount of seconds into string.
    #
    # ===== Parameters:
    # * [+s+] (+Integer+) - amount of seconds.
    #
    # ===== Returns:
    # * (+String+) - formatted string.
    def self.format_seconds(s)
      s = s.to_i # Require integer      
      "#{(s / 60).to_s.rjust(2, "0")}:#{(s % 60).to_s.rjust(2, "0")}";
    end
    
    # Guess type of request by from string.
    #
    # ===== Parameters:
    # * [+str+] (+String+) - request from user for some audios.
    #
    # ===== Returns:
    # * +:playlist+ - if string match playlist URL.
    # * +:post+ - if string match post URL.
    # * +:audios+ - if string match user or group URL.
    # * +:find+ - in rest of cases.
    def self.guess_request_type(str)
      # Guess what type of request is this. Returns Symbol: :find, :playlist, :audios
      case str
        when Constants::PLAYLIST_URL_REGEX
          :playlist
        when Constants::POST_URL_REGEX
          :post
        when Constants::VK_URL_REGEX
          :audios
      else
        :find
      end
    end

    # Turn hash into URL query string.
    #
    # ===== Parameters:
    # * [+hash+] (+Hash+)
    #
    # ===== Returns:
    # * (+String+)
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

    # Send warning.
    def self.warn(*args)
      if defined?(Warning.warn)
        Warning.warn args.join("\n")
      else
        STDERR.puts "Warning:", *args
      end
    end
    
  end
  
end
