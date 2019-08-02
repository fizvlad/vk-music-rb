module VkMusic

  # VK playlist. Extended with Enumerable.
  class Playlist
    include Enumerable
    
    # Playlist id.
    attr_reader :id
    # Owner of playlist.
    attr_reader :owner_id
    # Access hash which should be part of link for some playlists.
    attr_reader :access_hash
    # Playlist title.
    attr_reader :title
    # Playlist subtitle. May be empty.
    attr_reader :subtitle
    
    # Return string describing playlist in Russian.
    def to_s
      (@subtitle.empty? ? "" : "#{@subtitle} - ") + "#{@title} (#{self.length} аудиозаписей)"
    end

    # Same to +to_s+, but also outputs list of audios.
    def pp
      "#{to_s}:\n#{@list.map(&:to_s).join("\n")}"
    end

    # Returns audios array.
    def to_a
      @list.dup
    end
    
    # :nodoc:
    def each(&block)
      @list.each(&block)
    end

    # :stopdoc:
    def length
      @list.length
    end
    alias size length

    def empty?
      @list.empty?
    end
    # :startdoc:
    
    # Access to audios from playlist.
    #
    # ===== Parameters:
    # * [+index+] (+Integer+) - index of audio (starting from 0).
    #
    # ===== Returns:
    # * (+Audio+, +nil+) - audio or +nil+ if out of range.
    def [](index)
      @list[index]
    end
  
    # Initialize new playlist.
    #
    # ===== Parameters:
    # * [+list+] (+Array+) - list of audios in album.
    # * [+options+] (+Hash+)
    #
    # ===== Options:
    # * [+:id+]
    # * [+:owner_id+]
    # * [+:access_hash+]
    # * [+:title+]
    # * [+:subtitle+]
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
