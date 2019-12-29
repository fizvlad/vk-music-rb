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
    # @return [Integer, nil] real size of playlist or +nil+ if unknown.
    attr_reader :real_size

    ##
    # @return [String] playlist description in Russian.
    def to_s
      (@subtitle && !@subtitle.empty? ? "#{@subtitle} - " : "") +
      @title +
      (@real_size ? "(#{self.length} из #{@real_size} аудиозаписей загружено)" : " (#{self.length} аудиозаписей)")
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
    # @!visibility private
    def each(&block)
      @list.each(&block)
    end
    ##
    # @return [Integer] amount of audios. This can be less than real size as not all audios might be loaded.
    def length
      @list.length
    end
    alias size length
    ##
    # Access audios from playlist.
    # @param index [Integer] index of audio (starting from 0).
    # @return [Audio, nil] audio or +nil+ if out of range.
    def [](index)
      @list[index]
    end
    ##
    # @return [Boolean] whether no audios loaded for this playlist.
    def empty?
      @list.empty?
    end

    ##
    # Initialize new playlist.
    #
    # @param list [Array] list of audios in playlist.
    # @param id [Integer, nil]
    # @param owner_id [Integer, nil]
    # @param access_hash [String, nil]
    # @param title [String]
    # @param subtitle [String, nil]
    # @param real_size [Integer, nil]
    def initialize(list, id: nil, owner_id: nil, access_hash: nil, title: "", subtitle: nil, real_size: nil)
      raise ArgumentError unless list.is_a?(Array)
      # Saving list
      @list = list.dup

      # Setting up attributes
      @id = id
      @owner_id = owner_id
      @access_hash = access_hash
      @title = title
      @subtitle = subtitle
      @real_size = real_size
    end
  end
end
