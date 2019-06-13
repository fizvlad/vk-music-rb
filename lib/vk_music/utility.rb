module VkMusic

  module Utility
  
    def self.format_seconds(s)
      s = s.to_i # Require integer      
      "#{(s / 60).to_s.rjust(2, "0")}:#{(s % 60).to_s.rjust(2, "0")}";
    end
    
  end
  
end