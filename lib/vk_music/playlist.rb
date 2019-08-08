module VkMusic

  ##
  # VK playlist.
  class Playlist
    include Enumerable
    
    ##
    # @return [Integer, nil] playlist ID.
    attr_reader :id

    ##
    # @return [Integer, nil] owner of playlist ID.
    attr_reader :owner_id

    ##
    # @return [String, nil] access hash which should be part of link for some playlists.
    attr_reader :access_hash

    ##
    # @return [String] playlist title.
    attr_reader :title

    ##
    # @return [String, nil] playlist subtitle. May be empty.
    attr_reader :subtitle
    
    ##
    # @return [String] playlist description in Russian.
    def to_s
      (@subtitle ? "#{@subtitle} - " : "") + "#{@title} (#{self.length} аудиозаписей)"
    end

    ##
    # @return [String] Same to {#to_s}, but also outputs list of audios.
    def pp
      "#{to_s}:\n#{@list.map(&:pp).join("\n")}"
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
      raise ArgumentError, "Bad arguments", caller unless list.class == Array      
      # Saving list
      @list = list.dup
      
      # Setting up attributes
      @id          = Utility.unless_nil_to Integer, options[:id]
      @owner_id    = Utility.unless_nil_to Integer, options[:owner_id]
      @access_hash = Utility.unless_nil_to String, options[:access_hash]
      @title       = options[:title].to_s
      @subtitle    = Utility.unless_nil_to String, options[:subtitle]
    end
  
  end
  
end
