require "cgi"

module VkMusic

  class Audio
  
    attr_reader :id, :owner_id, :secret_1, :secret_2, :artist, :title, :duration, :url, :url_encoded

    def update_url(options)
      raise ArgumentError, "options hash must be provided", caller unless options.class == Hash
      if !options[:url].to_s.empty?
        @url_encoded = ""
        @url = options[:url].to_s
      elsif !options[:url].to_s.empty? && options[:client_id]
        @url_encoded = options[:url_encoded].to_s
        @url = VkMusic.unmask_link(options[:url_encoded], options[:client_id])
      else
        raise ArgumentError, "You should either provide :url or :url_encoded and :client_id", caller
      end
    end
    
    def to_s
      "#{@artist} - #{@title} [#{Utility.format_seconds(@duration)}]"
    end

    def pp
      "#{to_s} (Got decoded URL: #{@url ? "yes" : "no"}, able to get URL from VK: #{@id && @owner_id && @secret_1 && @secret_2 ? "yes" : "no"})"
    end
  
    def initialize(options)
      # Arguments check
      raise ArgumentError, "options hash must be provided", caller unless options.class == Hash
      raise ArgumentError, "artist is not provided", caller unless options.has_key?(:artist)
      raise ArgumentError, "title is not provided", caller unless options.has_key?(:title)
      raise ArgumentError, "duration is not provided", caller unless options.has_key?(:duration)
      
      # Setting up attributes
      @id          = options[:id].to_s
      @owner_id    = options[:owner_id].to_s
      @secret_1    = options[:secret_1].to_s
      @secret_2    = options[:secret_2].to_s
      @artist      = options[:artist].to_s
      @title       = options[:title].to_s
      @duration    = options[:duration].to_i
      @url_encoded = options[:url_encoded].to_s
      @url         = options[:url].to_s
    end
    
    def self.from_node(node, client_id)
      url_encoded = node.at_css("input").attribute("value").to_s
      url_encoded = nil if url_encoded == "https://m.vk.com/mp3/audio_api_unavailable.mp3"
      id_array = node.attribute("data-id").to_s.split("_")
      
      new({
        :id => id_array[1],
        :owner_id => id_array[0],
        :artist => node.at_css(".ai_artist").text.strip,
        :title => node.at_css(".ai_title").text.strip,
        :duration => node.at_css(".ai_dur").attribute("data-dur").to_s.to_i,
        :url_encoded => url_encoded,
        :url => url_encoded ? VkMusic.unmask_link(url_encoded, client_id) : nil,
      })
    end
    
    def self.from_data_array(data, client_id)
      url_encoded = data[2]
      url_encoded = nil if url_encoded == ""
      
      secrets = data[13].split("/")

      new({
        :id => data[0],
        :owner_id => data[1],
        :secret_1 => secrets[3],
        :secret_2 => secrets[5],
        :artist => CGI.unescapeHTML(data[4]),
        :title => CGI.unescapeHTML(data[3]),
        :duration => data[5],
        :url_encoded => url_encoded,
        :url => url_encoded ? VkMusic.unmask_link(url_encoded, client_id) : nil,
      })
    end
  
  end
  
end
