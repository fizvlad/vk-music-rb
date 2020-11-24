# frozen_string_literal: true

module VkMusic
  # Class representing VK audio
  class Audio
    # @return [String] name of artist
    attr_reader :artist
    # @return [String] title of song
    attr_reader :title
    # @return [Integer] duration of track in seconds
    attr_reader :duration
    # @return [String?] encoded URL which can be manually decoded if client ID is known
    attr_reader :url_encoded

    # Initialize new audio
    # @param id [Integer, nil]
    # @param owner_id [Integer, nil]
    # @param secret1 [String, nil]
    # @param secret2 [String, nil]
    # @param artist [String]
    # @param title [String]
    # @param duration [Integer]
    # @param url_encoded [String, nil]
    # @param url [String, nil] decoded URL
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
      @url_decoded = url
      @client_id = client_id
    end

    # @return [String?]
    def url
      return @url_decoded if @url_decoded

      return unless @url_encoded && @client_id

      Utility::LinkDecoder.call(@url_encoded, @client_id)
    end

    # Update audio data from another one
    def update(audio)
      VkMusic.log.warn('Audio') { "Performing update of #{self} from #{audio}" } unless like?(audio)
      @id = audio.id
      @owner_id = audio.owner_id
      @secret1 = audio.secret1
      @secret2 = audio.secret2
      @url_encoded = audio.url_encoded
      @url_decoded = audio.url_decoded
      @client_id = audio.client_id
    end

    # @return [String?]
    def full_id
      return unless @id && @owner_id && @secret1 && @secret2

      "#{@owner_id}_#{@id}_#{@secret1}_#{@secret2}"
    end

    # @return [Boolean] whether URL saved into url attribute
    def url_cached?
      !!@url_decoded
    end

    # @return [Boolean] whether able to get download URL without web requests
    def url_available?
      url_cached? || !!(@url_encoded && @client_id)
    end

    # @return [Boolean] whether it's possible to get download URL with {Client#from_id}
    def url_accessable?
      !!full_id
    end

    # @param audio [Audio]
    # @return [Boolean] whether artist, title and duration are same
    def like?(audio)
      artist == audio.artist && title == audio.title && duration == audio.duration
    end

    # @param [Audio, Array(owner_id, audio_id, secret1, secret2), String]
    # @return [Boolean] id-based comparison
    def id_matches?(data)
      data_id = case data
      when Array then data.join('_')
      when Audio then data.full_id
      when String then data.strip
      end

      full_id == data_id
    end

    # @return [String] pretty-printed audio name
    def to_s
      "#{@artist} - #{@title} [#{@duration}s]"
    end

    protected

    attr_reader :id, :owner_id, :secret1, :secret2, :url_decoded, :client_id
  end
end
