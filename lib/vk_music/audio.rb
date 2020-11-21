# frozen_string_literal: true

module VkMusic
  # Class representing VK audio
  class Audio
    # @return [Integer, nil] ID of audio
    attr_reader :id
    # @return [Integer, nil] ID of audio owner
    attr_reader :owner_id
    # @return [String, nil] part of secret hash which used when using +act=reload_audio+
    attr_reader :secret1, :secret2
    # @return [String] name of artist
    attr_reader :artist
    # @return [String] title of song
    attr_reader :title
    # @return [Integer] duration of track in seconds
    attr_reader :duration

    # Initialize new audio
    # @param id [Integer, nil]
    # @param owner_id [Integer, nil]
    # @param secret1 [String, nil]
    # @param secret2 [String, nil]
    # @param artist [String]
    # @param title [String]
    # @param duration [Integer]
    # @param url_encoded [String, nil]
    # @param url [String, nil]
    # @param client_id [Integer, nil]
    def initialize(id: nil, owner_id: nil, secret1: nil, secret2: nil,
                   artist: '', title: '', duration: 0,
                   url_encoded: nil, url: nil, client_id: nil)
      @id = id
      @owner_id = owner_id
      @secret1 = secret1
      @secret2 = secret2
      @artist = artist.to_s.strip
      @title = title.to_s.strip
      @duration = duration
      @url_encoded = url_encoded
      @url = url
      @client_id = client_id
    end

    # @return [String?]
    def full_id
      return unless @id && @owner_id && @secret1 && @secret2

      "#{@owner_id}_#{@id}_#{@secret1}_#{@secret2}"
    end

    # @return [Boolean] whether URL saved into url attribute
    def url_cached?
      !!@url
    end

    # @return [Boolean] whether able to get download URL without web requests
    def url_available?
      url_cached? || !!(@url_encoded && @client_id)
    end

    # @return [Boolean] whether it's possible to get download URL with {Client#from_id}
    def url_accessable?
      !!full_id
    end

    # @param audio [Autio]
    # @return [Boolean] whether artist, title and duration are same
    def like?(audio)
      artist == audio.artist && title == audio.title && duration == audio.duration
    end
  end
end
