require "cgi"

module VkMusic

  module Utility
  
    def self.format_seconds(s)
      s = s.to_i # Require integer      
      "#{(s / 60).to_s.rjust(2, "0")}:#{(s % 60).to_s.rjust(2, "0")}";
    end
    
    def self.guess_request_type(str)
      # Guess what type of request is this. Returns Symbol: :find, :playlist, :audios
      case str
        when PLAYLIST_URL_REGEX
          :playlist
        when POST_URL_REGEX
          :post
        when VK_URL_REGEX
          :audios
      else
        :find
      end
    end

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

    def self.warn(*args)
      if defined?(Warning.warn)
        Warning.warn args.join("\n")
      else
        STDERR.puts "Warning:", *args
      end
    end
    
  end
  
end
