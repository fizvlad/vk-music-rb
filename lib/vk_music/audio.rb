module VkMusic

  def self.unmask_link(link, client_id)
    # TODO
    return link
  end

  class Audio
    # Attributes
    attr_reader :id, :owner_id, :artist, :title, :duration, :url, :url_encoded
    
    def to_s
      "#{@artist} - #{@title} [#{Utility.format_seconds(@duration)}]"
    end
  
    def initialize(options)
      # Arguments check
      raise ArgumentError, "options hash must be provided", caller unless options.class == Hash
      raise ArgumentError, "artist is not provided", caller unless options.has_key?(:artist)
      raise ArgumentError, "title is not provided", caller unless options.has_key?(:title)
      raise ArgumentError, "duration is not provided", caller unless options.has_key?(:duration)
      raise ArgumentError, "url is not provided", caller unless options.has_key?(:url)
      
      # Setting up attributes
      @id          = options[:id].to_s
      @owner_id    = options[:owner_id].to_s
      @artist      = options[:artist].to_s
      @title       = options[:title].to_s
      @duration    = options[:duration].to_i
      @url_encoded = options[:url_encoded].to_s
      @url         = options[:url].to_s
    end
    
    def self.from_node(node, client_id)
      puts node
      new({
        :id => node.attribute("data-id").to_s,
        :owner_id => "", # TODO
        :artist => node.at_css(".ai_artist").text.strip,
        :title => node.at_css(".ai_title").text.strip,
        :duration => node.at_css(".ai_dur").attribute("data-dur").to_s.to_i,
        :url_encoded => node.at_css("input").attribute("value").to_s,
        :url => VkMusic.unmask_link(@url_encoded, client_id),
      })
    end
  
  end
  
end