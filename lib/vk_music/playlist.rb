module VkMusic

  class Playlist
    include Enumerable
    
    attr_reader :id, :owner_id, :access_hash, :title, :subtitle
    
    def length
      @list.length
    end
    alias size length
    
    def to_s
      "#{@subtitle} - #{@title} (#{self.length} аудиозаписей)"
    end
    
    def each(&block)
      @list.each(&block)
    end
    
    def [](index)
      @list[index]
    end
  
    def initialize(list, options = {})
      # Arguments check
      raise ArgumentError, "array of audios must be provided", caller unless list.class == Array
      
      # Saving list
      @list = list.dup
      
      # Setting up attributes
      @id          = options[:id].to_s
      @owner_id    = options[:owner_id].to_s
      @access_hash = options[:access_hash].to_s
      @title       = options[:title].to_s
      @subtitle    = options[:subtitle].to_s
    end
  
  end
  
end