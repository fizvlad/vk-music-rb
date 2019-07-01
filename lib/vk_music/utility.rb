module VkMusic

  module Utility
  
    def self.format_seconds(s)
      s = s.to_i # Require integer      
      "#{(s / 60).to_s.rjust(2, "0")}:#{(s % 60).to_s.rjust(2, "0")}";
    end
    
    def self.guess_request_type(str)
      # Guess what type of request is this. Returns Symbol: :find, :playlist, :audios
      if str.match? PLAYLIST_URL_REGEX
        :playlist
      elsif str.match? VK_URL_REGEX
        :audios
      else
        :find
      end
    end
    
  end
  
end