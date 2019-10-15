##
# @!macro [new] options_hash_param
#   @param options [Hash] hash with options.

module VkMusic

  ##
  # Class representing VK audio.
  class Audio
  
    ##
    # @return [Integer, nil] ID of audio.
    attr_reader :id

    ##
    # @return [Integer, nil] ID of audio owner.
    attr_reader :owner_id
    
    ##
    # @return [String, nil] part of secret hash which used when using +act=reload_audio+.
    attr_reader :secret_1, :secret_2
    
    ##
    # @return [String] name of artist.
    attr_reader :artist
    
    ##
    # @return [String] title of song.
    attr_reader :title

    ##
    # @return [Integer] duration of track in seconds.
    attr_reader :duration

    ##
    # Access decoded download URL.
    #
    # If link was already decoded, returns cached value. Else decodes existing link.
    # If no link can be provided, returns +nil+.
    #
    # @return [String, nil] decoded download URL or +nil+ if not available.
    def url
      if url_cached?
        @url
      elsif @url_encoded && @client_id
        @url = VkMusic::LinkDecoder.unmask_link(@url_encoded, @client_id)
      else
        @url # nil
      end
    end

    ##
    # @return [String, nil] encoded download URL.
    attr_reader :url_encoded

    ##
    # @return [Integer, nil] user ID which should be use for decoding.
    attr_reader :client_id

    ##
    # @return [String, nil] full ID of audio or +nil+ if some of components are missing.
    def full_id
      return nil unless @owner_id && @id && @secret_1 && @secret_2
      "#{@owner_id}_#{@id}_#{@secret_1}_#{@secret_2}"
    end

    ##
    # @return [Boolean] whether decoded URL is already cached.
    def url_cached?
      !!(@url)
    end

    ##
    # @return [Boolean] whether able to get download URL without web requests.
    def url_available?
      !!(url_cached? || (@url_encoded && @client_id))
    end

    ##
    # @return [Boolean] whether it's possible to get download URL with {Client#from_id}.
    def url_accessable?
      !!(@id && @owner_id && @secret_1 && @secret_2)
    end
    
    ##
    # @return [String] information about audio.
    def to_s
      "#{@artist} - #{@title} [#{Utility.format_seconds(@duration)}]"
    end

    ##
    # @return [String] extended information about audio.
    def pp
      "#{to_s} (#{
        if url_available?
          "Able to get decoded URL right away"
        elsif url_accessable?
          "Able to retrieve URL with request"
        else
          "URL not accessable"
        end
      })"
    end

    ##
    # Update audio URLs.
    #
    # @overload update_url(decoded_url)
    #   Simply save download URL.
    #   @param decoded_url [String]
    #
    # @overload update_url(audio)
    #   Copy URLs from this audio (no checks applied).
    #   @param audio [Audio]
    #
    # @overload update_url(options)
    #   @macro options_hash_param
    #   @option options [String, nil] :url decoded download URL.
    #   @option options [String, nil] :url_encoded decoded download URL.
    #   @option options [String, nil] :client_id decoded download URL.
    #
    # @return [self]
    def update_url(arg)
      case arg
        when String
          @url = arg
        when Audio
          # Only save URL if it's already decoded and cached
          @url = arg.url if arg.url_cached?
          @url_encoded = arg.url_encoded
          @client_id = arg.client_id
        when Hash
          @url_encoded = Utility.unless_nil_to String, options[:url_encoded]
          @url         = Utility.unless_nil_to String, options[:url]
          @client_id   = Utility.unless_nil_to Integer, options[:client_id]
        else
          raise ArgumentError, "Bad arguments", caller
      end
      self
    end
  
    ##
    # Initialize new audio.
    #
    # @macro options_hash_param
    #
    # @option options [Integer, nil] :id
    # @option options [Integer, nil] :owner_id
    # @option options [String, nil] :secret_1
    # @option options [String, nil] :secret_2
    # @option options [String] :artist
    # @option options [String] :title
    # @option options [Integer] :duration
    # @option options [String, nil] :url_encoded
    # @option options [String, nil] :url
    # @option options [Integer, nil] :client_id
    def initialize(options = {})
      @id          = Utility.unless_nil_to Integer, options[:id]
      @owner_id    = Utility.unless_nil_to Integer, options[:owner_id]
      @secret_1    = Utility.unless_nil_to String, options[:secret_1]
      @secret_2    = Utility.unless_nil_to String, options[:secret_2]
      @artist      = options[:artist].to_s.strip
      @title       = options[:title].to_s.strip
      @duration    = options[:duration].to_i
      @url_encoded = Utility.unless_nil_to String, options[:url_encoded]
      @url         = Utility.unless_nil_to String, options[:url]
      @client_id   = Utility.unless_nil_to Integer, options[:client_id]
    end
    
    ##
    # Initialize new audio from Nokogiri HTML node.
    #
    # @param node [Nokogiri::XML::Node] node, which match following CSS selector: +.audio_item.ai_has_btn+
    # @param client_id [Integer]
    #
    # @return [Audio]
    def self.from_node(node, client_id)
      input = node.at_css("input")
      if input
        url_encoded = input.attribute("value").to_s
        url_encoded = nil if url_encoded == Constants::URL::VK[:audio_unavailable] || url_encoded.empty?
        id_array = node.attribute("data-id").to_s.split("_")
        
        new({
          :id => id_array[1].to_i,
          :owner_id => id_array[0].to_i,
          :artist => node.at_css(".ai_artist").text.strip,
          :title => node.at_css(".ai_title").text.strip,
          :duration => node.at_css(".ai_dur").attribute("data-dur").to_s.to_i,
          :url_encoded => url_encoded,
          :url => nil,
          :client_id => client_id
        })
      else
        # Probably audios from some post
        new({
          :artist => node.at_css(".medias_audio_artist").text.strip,
          :title => Utility.plain_text(node.at_css(".medias_audio_title")).strip,
          :duration => Utility.parse_duration(node.at_css(".medias_audio_dur").text)
        })
      end
    end
    
    ##
    # Initialize new audio from VK data array.
    #
    # @param data [Array]
    # @param client_id [Integer]
    #
    # @return [Audio]
    def self.from_data(data, client_id)
      url_encoded = data[2].to_s
      url_encoded = nil if url_encoded.empty?
      
      secrets = data[13].to_s.split("/")

      new({
        :id => data[0].to_i,
        :owner_id => data[1].to_i,
        :secret_1 => secrets[3],
        :secret_2 => secrets[5],
        :artist => CGI.unescapeHTML(data[4]),
        :title => CGI.unescapeHTML(data[3]),
        :duration => data[5].to_i,
        :url_encoded => url_encoded,
        :url => nil,
        :client_id => client_id
      })
    end
  
  end
  
end
