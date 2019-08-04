module VkMusic

  ##
  # VK playlist.
  class Playlist
    include Enumerable
    
    ##
    # @return [Integer] playlist ID.
    attr_reader :id

    ##
    # @return [Integer] owner of playlist ID.
    attr_reader :owner_id

    ##
    # @return [String] access hash which should be part of link for some playlists.
    attr_reader :access_hash

    ##
    # @return [String] playlist title.
    attr_reader :title

    ##
    # @return [String] playlist subtitle. May be empty.
    attr_reader :subtitle
    
    ##
    # @return [String] playlist description in Russian.
    def to_s
      (@subtitle.empty? ? "" : "#{@subtitle} - ") + "#{@title} (#{self.length} аудиозаписей)"
    end

    ##
    # @return [String] Same to {#to_s}, but also outputs list of audios.
    def pp
      "#{to_s}:\n#{@list.map(&:to_s).join("\n")}"
    end

    ##
    # @return [Array<Audio>] Returns duplicate of array of playlist audios.
    def to_a
      @list.dup
    end
    
    ##
    # @see Array#each
    def each(&block)
      @list.each(&block)
    end

    ##
    # @see Array#length
    def length
      @list.length
    end
    alias size length

    ##
    # @see Array#empty?
    def empty?
      @list.empty?
    end
    
    ##
    # Access audios from playlist.
    #
    # @param index [Integer] index of audio (starting from 0).
    # 
    # @return [Audio, nil] audio or +nil+ if out of range.
    def [](index)
      @list[index]
    end
  
    ##
    # Initialize new playlist.
    #
    # @param list [Array] list of audios in playlist.
    #
    # @option options [Integer] :id
    # @option options [Integer] :owner_id
    # @option options [String] :access_hash
    # @option options [String] :title
    # @option options [String] :subtitle
    def initialize(list, options = {})
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
