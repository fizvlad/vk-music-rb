module VkMusic
  ##
  # Main class with all the interface.
  class Client
    ##
    # @return [Integer] ID of client.
    attr_reader :id
    ##
    # @return [String] name of client.
    attr_reader :name
    ##
    # @return [Mechanize] client used to access web pages.
    attr_reader :agent

    ##
    # Create new client and login.
    # @param username [String] usually telephone number or email.
    # @param password [String]
    # @param user_agent [String]
    def initialize(username: "", password: "", user_agent: Constants::DEFAULT_USER_AGENT)
      raise ArgumentError if username.empty? || password.empty?
      # Setting up client
      @agent = Mechanize.new
      @agent.user_agent = user_agent
      login(username, password)
    end

    ##
    #@!group Loading audios

    ##
    # Search for audio or playlist.
    # Possible values of +type+ option:
    # * +:audio+ - search for audios. Returns up to 50 audios.
    # * +:playlist+ - search for playlists. Returns up to 6 playlists *without* audios (Loaded with +up_to: 0+ option).
    #   You can get all the audios of selected playlist calling {Client#playlist} method with gained info.
    # @note some audios and playlists might be removed from search.
    # @todo search in group audios.
    # @param query [String] search query.
    # @param type [Symbol] what to search for.
    # @return [Array<Audio>, Array<Playlist>] array with audios or playlists
    #   matching given string.
    def find(query = "", type: :audio)
      raise ArgumentError if query.empty?
      uri = URI(Constants::URL::VK[:audios])
      case type
      when :audio
        uri.query = Utility.hash_to_params({ "act" => "search", "q" => query })
        audios_from_page(uri)
      when :playlist
        uri.query = Utility.hash_to_params({ "q" => query, "tab" => "global" })
        urls = playlist_urls_from_page(uri)
        urls.map { |url| playlist(url: url, up_to: 0, use_web: false) }
      else
        raise ArgumentError
      end
    end
    alias_method :search, :find

    ##
    # Get VK playlist.
    # Specify either +url+ or +(owner_id,playlist_id,access_hash)+.
    # @note since updating URLs can take a lot of time in this case, you have to
    #   do it manually with {Client#update_urls}.
    # @param url [String, nil] playlist URL.
    # @param owner_id [Integer, nil] playlist owner ID.
    # @param playlist_id [Integer, nil] ID of the playlist.
    # @param access_hash [String, nil] access hash to playlist. Might not exist.
    # @param up_to [Integer] maximum amount of audios to load.
    #   If 0, no audios would be loaded (Just information about playlist).
    #   If less than 0, will load whole playlist.
    # @param use_web [Boolean, nil] if +true+ web version of pages sill be used, if +false+
    #   JSON will be used (latter is faster, but using web allow to get URLs instantly).
    #   If +nil+ mixed algorithm will be used: if provided +up_to+ value is less than 200
    #   web will be used.
    # @return [Playlist]
    def playlist(url: nil, owner_id: nil, playlist_id: nil, access_hash: nil, up_to: Constants::MAXIMUM_PLAYLIST_SIZE, use_web: nil)
      begin
        owner_id, playlist_id, access_hash = url.match(Constants::Regex::VK_PLAYLIST_URL_POSTFIX).captures if url
      rescue
        raise Exceptions::ParseError
      end
      raise ArgumentError unless owner_id && playlist_id
      use_web = up_to > 200 if use_web.nil?
      if use_web
        playlist_web(owner_id, playlist_id, access_hash, up_to: up_to)
      else
        playlist_json(owner_id, playlist_id, access_hash, up_to: up_to)
      end
    end

    ##
    # Get user or group audios.
    # Specify either +url+ or +owner_id+.
    # @note since updating URLs can take a lot of time in this case, you have to
    #   do it manually with {Client#update_urls}.
    # @param url [String, nil]
    # @param owner_id [Integer, nil] numerical ID of owner.
    # @param up_to [Integer] maximum amount of audios to load.
    #   If 0, no audios would be loaded (Just information about playlist).
    #   If less than 0, will load whole playlist.
    # @return [Playlist]
    def audios(url: nil, owner_id: nil, up_to: Constants::MAXIMUM_PLAYLIST_SIZE)
      owner_id = page_id(url) if url
      playlist_json(owner_id, -1, nil, up_to: up_to)
    end

    ##
    # Get audios on wall of user or group starting with given post.
    # Specify either +url+ or +(owner_id,post_id)+.
    # @note this method is only able to load up to 91 audios from wall.
    # @param url [String] URL to post.
    # @param owner_id [Integer]  numerical ID of wall owner.
    # @param post_id [Integer] numerical ID of post.
    # @return [Array<Audio>] array of audios from wall.
    def wall(url: nil, owner_id: nil, post_id: nil, up_to: 91, with_url: false)
      if url
        owner_id = page_id(url)
        post_id = last_post_id(owner_id: owner_id)
      end
      wall_json(owner_id, post_id, up_to: up_to, with_url: with_url)
    end

    ##
    # Get audios attached to post.
    # Specify either +url+ or +(owner_id,post_id)+.
    # @param url [String] URL to post.
    # @param owner_id [Integer] numerical ID of wall owner.
    # @param post_id [Integer] numerical ID of post.
    # @return [Array<Audio>] array of audios attached to post. Most of audios will
    #   already have download URLs, but there might be audios which can't be resolved.
    def post(url: nil, owner_id: nil, post_id: nil)
      begin
        owner_id, post_id = url.match(Constants::Regex::VK_WALL_URL_POSTFIX).captures if url
      rescue
        raise Exceptions::ParseError
      end

      attached = attached_audios(owner_id: owner_id, post_id: post_id)
      wall = wall(owner_id: owner_id, post_id: post_id, with_url: false)

      no_link = attached.map do |a_empty|
        # Here we just search for matching audios on wall
        wall.find { |a| a.artist == a_empty.artist && a.title == a_empty.title } || a_empty
      end
      loaded_audios = from_id(no_link)

      loaded_audios.map.with_index { |el, i| el || no_link[i] }
    end

    ##
    # Get audios with download URLs by their IDs and secrets.
    # @param args [Array<Audio, Array<(owner_id, audio_id, secret_1, secret_2)>, "#{owner_id}_#{id}_#{secret_1}_#{secret_2}">]
    # @return [Array<Audio, nil>] array of: audio with download URLs or audio
    #   without URL if wasn't able to get it for audio or +nil+ if
    #   matching element can't be retrieved for array or string.
    def get_urls(args)
      args_formatted = args.map do |el|
        case el
        when Array
          el.join("_")
        when Audio
          el.full_id
        when String
          el # Do not change
        else
          raise ArgumentError
        end
      end
      args_formatted.compact.uniq # Not dealing with nil or doubled IDs

      audios = []
      begin
        args_formatted.each_slice(10) do |subarray|
          json = load_json_audios_by_id(subarray)
          subresult = audios_from_data(json["data"][0].to_a)
          audios.concat(subresult)
        end
      rescue
        raise Exceptions::ParseError
      end
      VkMusic.debug("Loaded audios from ids: #{audios.map(&:pp).join(", ")}")

      args.map do |el|
        case el
        when Array
          audios.find { |audio| audio.owner_id == el[0].to_i && audio.id == el[1].to_i }
        when Audio
          next el if el.full_id.nil? # Audio was skipped
          audios.find { |audio| audio.owner_id == el.owner_id && audio.id == el.id }
        when String
          audios.find { |audio| [audio.owner_id, audio.id] == el.split("_").first(2).map(&:to_i) }
        else
          nil # This shouldn't happen actually
        end
      end
    end
    alias_method :from_id, :get_urls

    ##
    # Update download URLs of audios.
    # @param audios [Array<Audio>]
    def update_urls(audios)
      audios_with_urls = get_urls(audios)
      audios.each.with_index do |a, i|
        a_u = audios_with_urls[i]
        a.update(from: a_u) unless a_u.nil?
      end
    end

    ##
    # Retrieve audios from recommendations or alike pages.
    # Specify either +url+ or +block_id+.
    # @param url [String] URL.
    # @param block_id [String] ID of block.
    # @return [Array<Audio>] array of audios attached to post. Most of audios will
    #   already have download URLs, but there might be audios which can't be resolved.
    def block(url: nil, block_id: nil)
      begin
        block_id = url.match(Constants::Regex::VK_BLOCK_URL).captures.first if url
      rescue
        raise Exceptions::ParseError
      end

      uri = URI(Constants::URL::VK[:audios])
      uri.query = Utility.hash_to_params({ "act" => "block", "block" => block_id })
      audios_from_page(uri)
    end

    ##
    # @!endgroup

    ##
    # @!group Other

    ##
    # Get user or group ID. Sends one request if custom ID provided.
    # @param str [String] link, ID with/without prefix or custom ID.
    # @return [Integer] page ID.
    def page_id(str)
      case str
      when Constants::Regex::VK_URL
        path = str.match(Constants::Regex::VK_URL)[1]
        page_id(path) # Recursive call
      when Constants::Regex::VK_ID_STR
        str.to_i
      when Constants::Regex::VK_AUDIOS_URL_POSTFIX
        str.match(/-?\d+/).to_s.to_i # Numbers with sign
      when Constants::Regex::VK_PREFIXED_ID_STR
        id = str.match(/\d+/).to_s.to_i # Just numbers. Sign needed
        id *= -1 unless str.start_with?("id")
        id
      when Constants::Regex::VK_CUSTOM_ID
        url = "#{Constants::URL::VK[:home]}/#{str}"
        begin
          page = load_page(url)
        rescue Exceptions::RequestError
          raise Exceptions::ParseError
        end

        raise Exceptions::ParseError unless page.at_css(".PageBlock .owner_panel")

        begin
          page.link_with(href: Constants::Regex::VK_HREF_ID_CONTAINING).href.slice(Constants::Regex::VK_ID).to_i # Numbers with sign
        rescue
          raise Exceptions::ParseError
        end
      else
        raise Exceptions::ParseError
      end
    end

    ##
    # Get ID of last post.
    # Specify either +url+ or +owner_id+.
    # @note requesting for "vk.com/id0" will raise ArgumentError.
    #   Use +client.last_post_id(owner_id: client.id)+ to get last post of client.
    # @param url [String] URL to wall owner.
    # @param owner_id [Integer] numerical ID of wall owner.
    # @return [Integer, nil] ID of last post or +nil+ if there are no posts.
    def last_post_id(url: nil, owner_id: nil)
      path = if url
        url.match(Constants::Regex::VK_URL)[1]
      else
        path = "#{owner_id < 0 ? "club" : "id"}#{owner_id.abs}"
      end
      raise ArgumentError, "Requesting this method for id0 is forbidden", caller if path == "id0"

      url = "#{Constants::URL::VK[:home]}/#{path}"
      page = load_page(url)

      # Ensure this isn't some random vk page
      raise Exceptions::ParseError unless page.at_css(".PageBlock .owner_panel")

      begin
        posts = page.css(".wall_posts > .wall_item .anchor")
        posts_ids = posts.map do |post|
          post ? post.attribute("name").to_s.match(Constants::Regex::VK_POST_URL_POSTFIX)[2].to_i : 0
        end
        # To avoid checking id of pinned post need to take maximum id.
        return posts_ids.max
      rescue
        raise Exceptions::ParseError
      end
    end

    ##
    # Get audios attached to specified post.
    # Specify either +url+ or +(owner_id,post_id)+.
    # @param url [String] URL to post.
    # @param owner_id [Integer] numerical ID of wall owner.
    # @param post_id [Integer] numerical ID of post.
    # @return [Array<Audio>] audios with only artist, title and duration.
    def attached_audios(url: nil, owner_id: nil, post_id: nil)
      begin
        owner_id, post_id = url.match(Constants::Regex::VK_WALL_URL_POSTFIX).captures if url
      rescue
        raise Exceptions::ParseError
      end

      url = "#{Constants::URL::VK[:wall]}#{owner_id}_#{post_id}"
      begin
        page = load_page(url)
      rescue Exceptions::RequestError
        raise Exceptions::ParseError
      end

      raise Exceptions::ParseError unless page.css(".service_msg_error").empty?
      begin
        page.css(".wi_body > .pi_medias .medias_audio").map { |e| Audio.from_node(e, @id) }
      rescue
        raise Exceptions::ParseError
      end
    end

    ##
    # @!endgroup

    private

    ##
    # Load page web page.
    # @param url [String, URI]
    # @return [Mechanize::Page]
    def load_page(url)
      uri = URI(url) if url.class != URI
      VkMusic.debug("Loading #{uri}")
      begin
        @agent.get(uri)
      rescue
        raise Exceptions::RequestError
      end
    end
    ##
    # Load JSON from web page.
    # @param url [String, URI]
    # @return [Hash]
    def load_json(url)
      page = load_page(url)
      begin
        JSON.parse(page.body.strip)
      rescue Exception => error
        raise Exceptions::ParseError, error.message, caller
      end
    end

    ##
    # Load playlist web page.
    # @param owner_id [Integer]
    # @param playlist_id [Integer]
    # @param access_hash [String, nil]
    # @param offset [Integer]
    # @return [Mechanize::Page]
    def load_page_playlist(owner_id, playlist_id, access_hash = nil, offset: 0)
      uri = URI(Constants::URL::VK[:audios])
      uri.query = Utility.hash_to_params({
        act: "audio_playlist#{owner_id}_#{playlist_id}",
        access_hash: access_hash.to_s,
        offset: offset
      })
      load_page(uri)
    end
    ##
    # Load JSON playlist section with +load_section+ request.
    # @param owner_id [Integer]
    # @param playlist_id [Integer]
    # @param access_hash [String, nil]
    # @param offset [Integer]
    # @return [Hash]
    def load_json_playlist_section(owner_id, playlist_id, access_hash = nil, offset: 0)
      uri = URI(Constants::URL::VK[:audios])
      uri.query = Utility.hash_to_params({
        act: "load_section",
        owner_id: owner_id,
        playlist_id: playlist_id,
        access_hash: access_hash.to_s,
        type: "playlist",
        offset: offset,
        utf8: true
      })
      load_json(uri)
    end

    ##
    # Load JSON audios with +reload_audio+ request.
    # @param ids [Array<String>]
    # @return [Hash]
    def load_json_audios_by_id(ids)
      uri = URI(Constants::URL::VK[:audios])
      uri.query = Utility.hash_to_params({
        act: "reload_audio",
        ids: ids,
        utf8: true
      })
      load_json(uri)
    end
    ##
    # Load JSON audios with +load_section+ from wall.
    # @param owner_id [Integer]
    # @param post_id [Integer]
    # @return [Hash]
    def load_json_audios_wall(owner_id, post_id)
      uri = URI(Constants::URL::VK[:audios])
      uri.query = Utility.hash_to_params({
        act: "load_section",
        owner_id: owner_id,
        post_id: post_id,
        type: "wall",
        wall_type: "own",
        utf8: true
      })
      load_json(uri)
    end

    ##
    # Load audios from web page.
    # @param obj [Mechanize::Page, String, URI]
    # @return [Array<Audio>]
    def audios_from_page(obj)
      page = obj.is_a?(Mechanize::Page) ? obj : load_page(obj)
      begin
        page.css(".audio_item.ai_has_btn").map do |elem|
          data = JSON.parse(elem.attribute("data-audio"))
          Audio.from_data(data, @id)
        end
      rescue
        raise Exceptions::ParseError
      end
    end
    ##
    # Load audios from JSON data.
    # @param data [Hash]
    # @return [Array<Audio>]
    def audios_from_data(data)
      begin
        data.map { |audio_data| Audio.from_data(audio_data, @id) }
      rescue
        raise Exceptions::ParseError
      end
    end

    ##
    # Load playlist through web page requests.
    # @param owner_id [Integer]
    # @param playlist_id [Integer]
    # @param access_hash [String, nil]
    # @param up_to [Integer] if less than 0, all audios will be loaded.
    # @return [Playlist]
    def playlist_web(owner_id, playlist_id, access_hash = nil, up_to: -1)
      # Load first page and get info
      first_page = load_page_playlist(owner_id, playlist_id, access_hash, offset: 0)
      begin
        # Parse out essential data
        title = first_page.at_css(".audioPlaylist__title").text.strip
        subtitle = first_page.at_css(".audioPlaylist__subtitle").text.strip

        footer_node = first_page.at_css(".audioPlaylist__footer")
        if footer_node
          footer_match = footer_node.text.strip.match(/^\d+/)
          real_size = footer_match ? footer_match[0].to_i : 0
        else
          real_size = 0
        end
      rescue
        raise Exceptions::ParseError
      end
      # Now we can be sure we are on correct page and have essential data.

      first_page_audios = audios_from_page(first_page)

      # Check whether need to make additional requests
      up_to = real_size if (up_to < 0 || up_to > real_size)
      list = first_page_audios.first(up_to)
      while list.length < up_to do
        playlist_page = load_page_playlist(owner_id, playlist_id, access_hash, offset: list.length)
        list.concat(audios_from_page(playlist_page).first(up_to - list.length))
      end

      Playlist.new(list,
        id: id,
        owner_id: owner_id,
        access_hash: access_hash,
        title: title,
        subtitle: subtitle,
        real_size: real_size
      )
    end

    ##
    # Load playlist through JSON requests.
    # @param owner_id [Integer]
    # @param playlist_id [Integer]
    # @param access_hash [String, nil]
    # @param up_to [Integer] if less than 0, all audios will be loaded.
    # @return [Playlist]
    def playlist_json(owner_id, playlist_id, access_hash, up_to: -1)
      # Trying to parse out audios
      first_json = load_json_playlist_section(owner_id, playlist_id, access_hash, offset: 0)
      begin
        first_data = first_json["data"][0]
        first_data_audios = audios_from_data(first_data["list"])
      rescue
        raise Exceptions::ParseError
      end

      real_size = first_data["totalCount"]
      up_to = real_size if (up_to < 0 || up_to > real_size)
      list = first_data_audios.first(up_to)
      while list.length < up_to do
        json = load_json_playlist_section(owner_id, playlist_id, access_hash, offset: list.length)
        audios = begin
          audios_from_data(json["data"][0]["list"])
        rescue
          raise Exceptions::ParseError
        end
        list.concat(audios.first(up_to - list.length))
      end

      begin
        Playlist.new(list,
          id: first_data["id"],
          owner_id: first_data["owner_id"],
          access_hash: first_data["access_hash"],
          title: CGI.unescapeHTML(first_data["title"].to_s),
          subtitle: CGI.unescapeHTML(first_data["subtitle"].to_s),
          real_size: real_size
        )
      rescue
        raise Exceptions::ParseError
      end
    end

    ##
    # Found playlist URLs on *global* search page.
    # @param obj [Mechanize::Page, String, URI]
    # @return [Array<String>]
    def playlist_urls_from_page(obj)
      page = obj.is_a?(Mechanize::Page) ? obj : load_page(obj)
      begin
        page.css(".AudioBlock_music_playlists .AudioPlaylistSlider .al_playlist").map { |elem| elem.attribute("href").to_s }
      rescue
        raise Exceptions::ParseError
      end
    end

    ##
    # Load audios from wall using JSON request.
    # @param owner_id [Integer]
    # @param post_id [Intger]
    # @param up_to [Integer]
    # @param with_url [Boolean] whether to retrieve URLs with {Client#from_id} method
    # @return [Array<Audio>]
    def wall_json(owner_id, post_id, up_to: 91, with_url: false)
      if up_to < 0 || up_to > 91
        up_to = 91
        VkMusic.warn("Current implementation of this method is not able to return more than 91 audios from wall.")
      end

      json = load_json_audios_wall(owner_id, post_id)
      begin
        data = json["data"][0]
        audios = audios_from_data(data["list"]).first(up_to)
      rescue
        raise Exceptions::ParseError
      end
      with_url ? from_id(audios) : audios
    end

    ##
    # Login to VK.
    def login(username, password)
      VkMusic.debug("Logging in.")
      # Loading login page
      homepage = load_page(Constants::URL::VK[:login])
      # Submitting login form
      login_form = homepage.forms.find { |form| form.action.start_with?(Constants::URL::VK[:login_action]) }
      login_form[Constants::VK_LOGIN_FORM_NAMES[:username]] = username.to_s
      login_form[Constants::VK_LOGIN_FORM_NAMES[:password]] = password.to_s
      after_login = @agent.submit(login_form)

      # Checking whether logged in
      raise Exceptions::LoginError, "Unable to login. Redirected to #{after_login.uri.to_s}", caller unless after_login.uri.to_s == Constants::URL::VK[:feed]

      # Parsing information about this profile
      profile = load_page(Constants::URL::VK[:profile])
      @name = profile.title.to_s
      @id = profile.link_with(href: Constants::Regex::VK_HREF_ID_CONTAINING).href.slice(/\d+/).to_i
    end

    # Shortcut
    def unmask_link(link)
      VkMusic::LinkDecoder.unmask_link(link, @id)
    end
  end
end
