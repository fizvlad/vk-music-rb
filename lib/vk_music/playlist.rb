# frozen_string_literal: true

module VkMusic
  # Class representing VK playlist
  class Playlist
    include Enumerable

    # @return [Integer, nil] playlist ID
    attr_reader :id
    # @return [Integer, nil] playlist owner ID
    attr_reader :owner_id
    # @return [String, nil] access hash which should be part of link for some playlists
    attr_reader :access_hash
    # @return [String] playlist title
    attr_reader :title
    # @return [String, nil] playlist subtitle. May be empty
    attr_reader :subtitle
    # @return [Integer, nil] real size of playlist or +nil+ if unknown
    attr_reader :real_size

    # Initialize new playlist
    # @param list [Array] list of audios in playlist
    # @param id [Integer, nil]
    # @param owner_id [Integer, nil]
    # @param access_hash [String, nil]
    # @param title [String]
    # @param subtitle [String, nil]
    # @param real_size [Integer, nil]
    def initialize(list, id: nil, owner_id: nil, access_hash: nil, title: '', subtitle: nil, real_size: nil)
      @list = list.dup
      @id = id
      @owner_id = owner_id
      @access_hash = access_hash
      @title = title.to_s.strip
      @subtitle = subtitle
      @real_size = real_size
    end

    # @return [Array<Audio>] duplicate of array of playlist audios
    def to_a
      @list.dup
    end

    # @!visibility private
    def each(&block)
      @list.each(&block)
    end

    # @!visibility private
    def length
      @list.length
    end
    alias size length

    # @!visibility private
    def [](index)
      @list[index]
    end

    # @!visibility private
    def empty?
      @list.empty?
    end
  end
end
