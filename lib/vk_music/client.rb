# frozen_string_literal: true

module VkMusic
  # VK client
  class Client
    # Default user agent to use
    DEFAULT_USERAGENT = 'Mozilla/5.0 (Linux; Android 5.0; SM-G900P Build/LRX21T) ' \
                        'AppleWebKit/537.36 (KHTML, like Gecko) ' \
                        'Chrome/86.0.4240.111 Mobile Safari/537.36'
    public_constant :DEFAULT_USERAGENT
    # Mximum size of VK playlist
    MAXIMUM_PLAYLIST_SIZE = 10_000
    public_constant :MAXIMUM_PLAYLIST_SIZE

    # @return [Integer] ID of client
    attr_reader :id
    # @return [String] name of client
    attr_reader :name
    # @return [Mechanize] client used to access web pages
    attr_reader :agent

    # @param login [String, nil]
    # @param password [String, nil]
    # @param user_agent [String]
    # @param agent [Mechanize?] if specified, provided agent will be used
    def initialize(login: nil, password: nil, user_agent: DEFAULT_USERAGENT, agent: nil)
      @login = login
      @password = password
      @agent = agent
      if @agent.nil?
        @agent = Mechanize.new
        @agent.user_agent = user_agent

        raise('Failed to login!') unless self.login
      end

      load_id_and_name
      VkMusic.log.info("Client#{@id}") { "Logged in as User##{@id} (#{@name})" }
    end

    # Make a login request
    # @return [Boolean] whether login was successful
    def login
      VkMusic.log.info("Client#{@id}") { 'Logging in...' }
      login = Request::Login.new
      login.call(agent)
      login.send_form(@login, @password, agent)
      return true if login.success?

      VkMusic.log.warn("Client#{@id}") { "Login failed. Redirected to #{login.response.uri}" }
      false
    end

    # Unmask old VK music link
    # @param limk [String]
    def unmask_link(link)
      VkMusic::LinkDecoder.unmask_link(link, @id)
    end

    # Search for audio or playlist
    #
    # Possible values of +type+ option:
    # * +:audio+ - search for audios
    # * +:playlist+ - search for playlists
    # @note some audios and playlists might be removed from search
    # @todo search in group audios
    # @param query [String]
    # @param type [Symbol]
    # @return [Array<Audio>, Array<Playlist>]
    def find(query = '', type: :audio)
      return [] if query.empty?

      page = Request::Search.new(query, id)
      page.call(agent)

      case type
      when :audio, :audios then page.audios
      when :playlist, :playlists then page.playlists
      else []
      end
    end
    alias search find

    # Get VK playlist. Specify either +url+ or +(owner_id,playlist_id,access_hash)+
    # @param url [String, nil]
    # @param owner_id [Integer, nil]
    # @param playlist_id [Integer, nil]
    # @param access_hash [String, nil] access hash for the playlist. Might not exist
    # @param up_to [Integer] maximum amount of audios to load. If 0, no audios
    #   would be loaded (plain information about playlist)
    # @return [Playlist?]
    def playlist(url: nil, owner_id: nil, playlist_id: nil, access_hash: nil,
                 up_to: MAXIMUM_PLAYLIST_SIZE)
      owner_id, playlist_id, access_hash = Utility::PlaylistUrlParser.call(url) if url
      return if owner_id.nil? || playlist_id.nil?

      Utility::PlaylistLoader.call(agent, id, owner_id, playlist_id, access_hash, up_to)
    end

    # Get user or group audios. Specify either +url+ or +owner_id+
    # @param url [String, nil]
    # @param owner_id [Integer, nil]
    # @param up_to [Integer] maximum amount of audios to load. If 0, no audios
    #   would be loaded (plain information about playlist)
    # @return [Playlist?]
    def audios(url: nil, owner_id: nil, up_to: MAXIMUM_PLAYLIST_SIZE)
      # TODO
    end

    # Get audios on wall of user or group starting with given post. Specify
    #   either +url+ or +(owner_id,post_id)+
    # @note this method is only able to load up to 91 audios from wall.
    # @param url [String] URL to post.
    # @param owner_id [Integer]  numerical ID of wall owner.
    # @param post_id [Integer] numerical ID of post.
    # @return [Array<Audio>] array of audios from wall.
    def wall(url: nil, owner_id: nil, post_id: nil, up_to: 91, with_url: false)
      # TODO
    end

    # Get audios attached to post. Specify either +url+ or +(owner_id,post_id)+.
    # @param url [String]
    # @param owner_id [Integer]
    # @param post_id [Integer]
    # @return [Array<Audio>] array of audios attached to post
    def post(url: nil, owner_id: nil, post_id: nil)
      # TODO
    end

    # Get audios with download URLs by their IDs and secrets
    # @param args [Array<Audio, Array<(owner_id, audio_id, secret_1, secret_2)>,
    #   "#{owner_id}_#{id}_#{secret_1}_#{secret_2}">]
    # @return [Array<Audio, nil>] array of: audio with download URLs or audio
    #   without URL if wasn't able to get it for audio or +nil+ if
    #   matching element can't be retrieved for array or string
    def get_urls(args)
      # TODO
    end
    alias from_id get_urls

    # Update download URLs of provided audios
    # @param audios [Array<Audio>]
    def update_urls(audios)
      # TODO
    end

    private

    def load_id_and_name
      VkMusic.log.info("Client#{@id}") { 'Loading user id and name' }
      my_page = Request::MyPage.new
      my_page.call(agent)
      @id = my_page.id
      @name = my_page.name
    end
  end
end
