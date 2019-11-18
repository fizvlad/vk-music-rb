##
# @!macro [new] options_hash_param
#   @param options [Hash] hash with options.
#
# @!macro [new] playlist_return
#   @return [Playlist] playlist with audios. Possibly empty.
#     Possibly contains audios without download URL.

##
# Main module.
module VkMusic

  ##
  # Main class with all the interface.
  # To start working with VK audios firstly create new client with +Client.new+.
  class Client
  
    ##
    # @return [Integer] ID of client.
    attr_reader :id

    ##
    # @return [String] name of client.
    attr_reader :name
    
    @agent = nil # Mechanize agent

    ##
    # Create new client and login.
    #
    # @macro options_hash_param
    #
    # @option options [String] :username usually telephone number or email.
    # @option options [String] :password
    # @option options [String] :user_agent (Constants::DEFAULT_USER_AGENT)
    def initialize(options = {})
      # Arguments check
      raise ArgumentError, "Options hash must be provided", caller unless options.class == Hash
      raise ArgumentError, "Username is not provided", caller unless options.has_key?(:username)
      raise ArgumentError, "Password is not provided", caller unless options.has_key?(:password)
      
      # Setting up client
      @agent = Mechanize.new
      @agent.user_agent = options[:user_agent] || Constants::DEFAULT_USER_AGENT
      login(options[:username], options[:password])
    end

    ##
    #@!group Loading audios
    
    ##
    # @!macro [new] find__options
    #   @option options [Symbol] :type (:audio) what to search for (you can find available values for this option above).
    #
    # Search for audio or playlist.
    #
    # @note some audios and playlists might be removed from search.
    #
    # @todo search in group audios.
    #
    # Possible values of +type+ option:
    # * +:audio+ - search for audios. Returns up to 50 audios.
    # * +:playlist+ - search for playlists. Returns up to 6 playlists *without* audios (Loaded with +up_to: 0+ option). 
    #   You can get all the audios of selected playlist calling {Client#playlist} method with gained info.
    #
    # @overload find(query, options)
    #   @param query [String] string to search for.
    #   @macro options_hash_param
    #   @macro find__options
    #
    # @overload find(options)
    #   @macro options_hash_param
    #   @option options [String] :query string to search for.
    #   @macro find__options
    #
    # @return [Array<Audio>, Array<Playlist>] array with audios or playlists matching given string. 
    #   Possibly empty. Possibly contains audios or playlists without download URL.
    def find(*args)
      begin
        case
          when (args.size == 1 && String === args[0]) ||
               (args.size == 2 && String === args[0] && Hash === args[1])
            options = args[1] || {}
            query = args[0]
          when args.size == 1 && Hash === args[0]
            options = args[0]
            query = options[:query].to_s
          else
            raise
        end
      rescue
        raise ArgumentError, "Bad arguments", caller
      end

      options[:type] ||= :audio

      uri = URI(Constants::URL::VK[:audios])

      case options[:type]
        when :audio
          uri.query = Utility.hash_to_params({ "act" => "search", "q" => query })
          audios__from_page(uri)
        when :playlist
          uri.query = Utility.hash_to_params({ "q" => query, "tab" => "global" })
          urls = playlist_urls__from_page(uri)
          urls.map { |url| playlist(url, up_to: 0, with_url: false) }
        else
          raise ArgumentError, "Bad :type option", caller
      end
    end
    alias search find
    
    ##
    # @!macro [new] pl__options
    #   @option options [Integer] :up_to (MAXIMUM_PLAYLIST_SIZE) maximum amount of audios to load.
    #     If 0, no audios would be loaded (Just information about playlist).
    #     If less than 0, will load whole playlist.
    #   @option options [Boolean] :with_url (true) makes all the audios have download URLs,
    #     but every 100 audios will cost one more request. You can reduce amount of requests using option +up_to+.
    #     Otherwise audio download URL would be accessable only with {Client#from_id}.
    #     Main advantage of disabling URLs is the fact that 2000 audios will be loaded per request,
    #     which is 20 times more effecient.
    #
    # Get VK playlist.
    #
    # @overload playlist(url, options)
    #   @param url [String] URL to playlist.
    #   @macro options_hash_param
    #   @macro pl__options
    #
    # @overload playlist(options)
    #   Use options +owner_id+, +playlist_id+ and +access_hash+ instead of URL.
    #   @macro options_hash_param
    #   @option options [Integer] :owner_id playlist owner ID.
    #   @option options [Integer] :playlist_id ID of the playlist.
    #   @option options [String] :access_hash access hash to playlist. Might not exist.
    #   @macro pl__options
    #
    # @macro playlist_return 
    def playlist(*args)
      begin
        case
          when (args.size == 1 && String === args[0]) ||
               (args.size == 2 && String === args[0] && Hash === args[1])
            options = args[1] || {}
            owner_id, playlist_id, access_hash = args[0].to_s.match(Constants::Regex::VK_PLAYLIST_URL_POSTFIX).captures
          when args.size == 1 && Hash === args[0]
            options = args[0]
            owner_id, playlist_id, access_hash = options[:owner_id].to_i, options[:playlist_id].to_i, options[:access_hash].to_s
          else
            raise
        end
      rescue
        raise ArgumentError, "Bad arguments", caller
      end
      
      options[:up_to] ||= Constants::MAXIMUM_PLAYLIST_SIZE
      options[:with_url] = true if options[:with_url].nil?

      if options[:with_url]
        playlist__web(owner_id, playlist_id, access_hash, options)
      else
        playlist__json(owner_id, playlist_id, access_hash, options)
      end
    end
    
    ##
    # @!macro [new] ua__options
    #   @option options [Integer] :up_to (MAXIMUM_PLAYLIST_SIZE) maximum amount of audios to load.
    #     If 0, no audios would be loaded (Just information about playlist).
    #     If less than 0, will load whole playlist.
    #
    # Get user or group audios.
    #
    # @note currently this method is only able to load 100 audios with download URL.
    #
    # @overload audios(url, options)
    #   @param url [String] URL to user/group page or audios.
    #   @macro options_hash_param
    #   @macro ua__options
    #
    # @overload audios(options)
    #   @macro options_hash_param
    #   @option options [Integer] :owner_id numerical ID of owner.
    #   @macro ua__options
    #
    # @macro playlist_return
    def audios(*args)
      begin
        case
          when (args.size == 1 && String === args[0] ) ||
               (args.size == 2 && String === args[0] && Hash === args[1])
            owner_id = page_id(args[0].to_s)
            options = args[1] || {}
          when args.size == 1 && Hash === args[0]
            owner_id = args[0][:owner_id].to_i
            options = args[0]
          else
            raise
        end
      rescue
        raise ArgumentError, "Bad arguments", caller
      end

      options[:up_to]    ||= Constants::MAXIMUM_PLAYLIST_SIZE

      playlist__json(owner_id, -1, nil, options)
    end

    ##
    # @!macro [new] wall__up_to_option
    #   @option up_to [Integer] :up_to (50) maximum amount of audios to load from wall.
    #   
    # @!macro [new] wall__with_url_option
    #   @option options [Boolean] :with_url (true) automatically use {Client#from_id} to get download URLs.
    #
    # Get audios on wall of user or group starting with given post.
    #
    # @note this method is only able to load up to 91 audios from wall.
    #
    # @todo this method breaks when club got fixed post with attached audios.
    #
    # @overload wall(url, options)
    #   Load last audios from wall.
    #   @param url [String] URL to user/group page.
    #   @macro options_hash_param
    #   @macro wall__up_to_option
    #   @macro wall__with_url_option
    #
    # @overload wall(options)
    #   Load audios starting from some exact post.
    #   @macro options_hash_param
    #   @option options [Integer] :owner_id numerical ID of wall owner.
    #   @option options [Integer] :post_id numerical ID of post.
    #   @macro wall__up_to_option
    #   @macro wall__with_url_option
    #
    # @return [Array<Audio>] array of audios from wall. Possibly empty.
    def wall(*args)
      begin
        case
          when (args.size == 1 && args[0].class == String) ||
               (args.size == 2 && args[0].class == String && args[1].class == Hash)
            url = args[0].to_s
            owner_id = page_id(url)
            post_id = last_post_id(owner_id)
            options = args[1] || {}
            return [] if post_id.nil?
          when args.length == 1 && Hash === args[0]
            options = args[0]
            owner_id = options[:owner_id].to_i
            post_id = options[:post_id].to_i
          else
            raise
        end
      rescue Exceptions::ParseError => error
        raise Exceptions::ParseError, "Unable to get last post id. Error: #{error.message}", caller
      rescue
        raise ArgumentError, "Bad arguments", caller
      end

      options[:up_to] ||= 50
      options[:with_url] = true if options[:with_url].nil?

      wall__json(owner_id, post_id, options)
    end

    ##
    # Get audios attached to post.
    #
    # @note currently this method works incorrectly with reposts.
    #
    # @overload post(url)
    #   @param url [String] URL to post.
    #
    # @overload post(options)
    #   @macro options_hash_param
    #   @option options [Integer] :owner_id numerical ID of wall owner.
    #   @option options [Integer] :post_id numerical ID of post.
    #
    # @return [Array<Audio>] array of audios. Possibly without download URL.
    def post(arg)
      begin
        case arg
          when String
            owner_id, post_id = arg.match(Constants::Regex::VK_WALL_URL_POSTFIX).captures
          when Hash
            options = arg
            owner_id = options[:owner_id].to_i
            post_id = options[:post_id].to_i
          else
            raise
        end
      rescue
        raise ArgumentError, "Bad arguments", caller
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
    #
    # @param args [Array<Audio, Array<(owner_id, audio_id, secret_1, secret_2)>, "#{owner_id}_#{id}_#{secret_1}_#{secret_2}">]
    #
    # @return [Array<Audio, nil>] array of: audio with download URLs or audio
    #   audio without URL if wasn't able to get it for audio or +nil+ if
    #   matching element can't be retrieved for array or string.
    def from_id(args)
      begin
        args_formatted = args.map do |el| 
          case el
            when Array
              el.join("_")
            when Audio
              el.full_id
            when String
              el # Do not change
            else
              raise
          end
        end
      rescue
        raise ArgumentError, "Bad arguments", caller
      end
      args_formatted.compact.uniq # Not dealing with nil or doubled IDs
      
      audios = []
      args_formatted.each_slice(10) do |subarray|
        json = load__json__audios_by_id(subarray)
        subresult = audios__from_data(json["data"][0].to_a)
        audios.concat(subresult)
      end
      Utility.debug("Loaded audios from ids: #{audios.map(&:pp).join(", ")}")

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

    ##
    # @!endgroup

    ##
    # @!group Other

    ##
    # Get user or group ID. Sends one request if custom ID provided
    #
    # @param str [String] link, ID with/without prefix or custom ID.
    #
    # @return [Integer] page ID.
    def page_id(str)
      raise ArgumentError, "Bad arguments", caller unless str.class == String

      case str
        when Constants::Regex::VK_URL
          path = str.match(Constants::Regex::VK_URL)[1]
          id = page_id(path) # Recursive call
        when Constants::Regex::VK_ID_STR
          id = str.to_i
        when Constants::Regex::VK_AUDIOS_URL_POSTFIX
          id = str.match(/-?\d+/).to_s.to_i # Numbers with sign
        when Constants::Regex::VK_PREFIXED_ID_STR
          id = str.match(/\d+/).to_s.to_i # Just numbers. Sign needed
          id *= -1 unless str.start_with?("id")
        when Constants::Regex::VK_CUSTOM_ID
          url = "#{Constants::URL::VK[:home]}/#{str}"
          begin
            page = load__page(url)
          rescue Exceptions::RequestError => error
            raise Exceptions::ParseError, "Failed request: #{error.message}", caller
          end          
          
          raise Exceptions::ParseError, "Page #{str} doesn't seem to be a group or user page", caller unless page.at_css(".PageBlock .owner_panel")
          
          begin
            id = page.link_with(href: Constants::Regex::VK_HREF_ID_CONTAINING).href.slice(Constants::Regex::VK_ID).to_i # Numbers with sign
          rescue Exception => error
            raise Exceptions::ParseError, "Unable to get user or group ID. Custom ID: #{str}. Error: #{error.message}", caller
          end
        else
          raise Exceptions::ParseError, "Unable to convert \"#{str}\" into ID", caller
      end
      id
    end

    ##
    # Get ID of last post.
    #
    # @note requesting for "vk.com/id0" will raise ArgumentError.
    #   Use +client.last_post_id(owner_id: client.id)+ to get last post of client.
    #
    # @overload last_post_id(url)
    #   @param url [String] URL to wall owner.
    #
    # @overload last_post_id(owner_id)
    #   @param owner_id [Integer] numerical ID of wall owner.
    #
    # @return [Integer, nil] ID of last post or +nil+ if there are no posts.
    def last_post_id(arg)
      begin
        case arg
          when String
            path = arg.match(Constants::Regex::VK_URL)[1]
          when Integer
            owner_id = arg
            path = "#{owner_id < 0 ? "club" : "id"}#{owner_id.abs}"
          else
            raise
        end
      rescue
        raise ArgumentError, "Bad arguments", caller
      end
      raise ArgumentError, "Requesting this method for id0 is forbidden", caller if path == "id0"

      url = "#{Constants::URL::VK[:home]}/#{path}"

      begin
        page = load__page(url)
      rescue Exceptions::RequestError => error
        raise Exceptions::ParseError, "Failed request: #{error.message}", caller
      end

      # Ensure this isn't some random vk page
      raise Exceptions::ParseError, "Page at #{url} doesn't seem to be a group or user page", caller unless page.at_css(".PageBlock .owner_panel")

      begin
        posts = page.css(".wall_posts > .wall_item .post__anchor")
        posts_ids = posts.map do |post|
          post ? post.attribute("name").to_s.match(Constants::Regex::VK_POST_URL_POSTFIX)[2].to_i : 0
        end
        # To avoid checking id of pinned post need to take maximum id.
        return posts_ids.max
      rescue Exception => error
        raise Exceptions::ParseError, "Unable to get last post on #{url}. Error: #{error.message}", caller
      end
    end

    ##
    # Get audios attached to specified post.
    #
    # @overload attached_audios(url)
    #   @param url [String] URL to post.
    #
    # @overload attached_audios(options)
    #   @macro options_hash_param
    #   @option options [Integer] :owner_id numerical ID of wall owner.
    #   @option options [Integer] :post_id numerical ID of post.
    #
    # @return [Array<Audio>] audios with only artist, title and duration.
    def attached_audios(arg)
      begin
        case arg
          when String
            owner_id, post_id = arg.match(Constants::Regex::VK_WALL_URL_POSTFIX).captures
          when Hash
            options = arg
            owner_id = options[:owner_id].to_i
            post_id = options[:post_id].to_i
          else
            raise
        end
      rescue
        raise ArgumentError, "Bad arguments", caller
      end

      url = "#{Constants::URL::VK[:wall]}#{owner_id}_#{post_id}"
      begin
        page = load__page(url)
      rescue Exceptions::RequestError => error
        raise Exceptions::ParseError, "Failed request: #{error.message}", caller
      end

      raise Exceptions::ParseError, "Post not found: #{owner_id}_#{post_id}", caller unless page.css(".service_msg_error").empty?
      begin
        result = page.css(".wi_body > .pi_medias .medias_audio").map { |e| Audio.from_node(e, @id) }
      rescue Exception => error
        raise Exceptions::ParseError, "Unable to get amount of audios in post #{owner_id}_#{post_id}. Error: #{error.message}", caller
      end
      result
    end

    ##
    # @!endgroup

    private

    # Load page by URL. And return Mechanize::Page.
    def load__page(url)
      uri = URI(url) if url.class != URI
      Utility.debug("Loading #{uri}")
      begin
        @agent.get(uri)
      rescue Exception => error
        raise Exceptions::RequestError, error.message, caller
      end
    end

    # Load JSON by URL. And return JSON object.
    def load__json(url)
      page = load__page(url)
      begin
        JSON.parse(page.body.strip)
      rescue Exception => error
        raise Exceptions::ParseError, error.message, caller
      end
    end


    # Load playlist web page.
    def load__page__playlist(owner_id, playlist_id, access_hash, options)
      uri = URI(Constants::URL::VK[:audios])
      uri.query = Utility.hash_to_params({
        "act" => "audio_playlist#{owner_id.to_i}_#{playlist_id.to_i}",
        "access_hash" => access_hash.to_s,
        "offset" => options[:offset].to_i
      })
      load__page(uri)
    end

    # Load JSON playlist part with +load_section+ request.
    def load__json__playlist_section(owner_id, playlist_id, access_hash, options)
      uri = URI(Constants::URL::VK[:audios])
      uri.query = Utility.hash_to_params({
        "act" => "load_section",
        "owner_id" => owner_id.to_i,
        "playlist_id" => playlist_id.to_i,
        "access_hash" => access_hash.to_s,
        "type" => "playlist",
        "offset" => options[:offset].to_i,
        "utf8" => true
      })
      load__json(uri)
    end


    # Load JSON audios with +reload_audio+ request.
    def load__json__audios_by_id(ids)
      uri = URI(Constants::URL::VK[:audios])
      uri.query = Utility.hash_to_params({
        "act" => "reload_audio",
        "ids" => ids.to_a,
        "utf8" => true
      })
      load__json(uri)
    end

    # Load JSON audios with +load_section+ from wall.
    def load__json__audios_wall(owner_id, post_id)
      uri = URI(Constants::URL::VK[:audios])
      uri.query = Utility.hash_to_params({
        "act" => "load_section",
        "owner_id" => owner_id,
        "post_id" => post_id,
        "type" => "wall",
        "wall_type" => "own",
        "utf8" => true
      })
      load__json(uri)
    end


    # Loading audios from web page.
    def audios__from_page(obj)
      page = obj.class == Mechanize::Page ? obj : load__page(obj)
      begin
        page.css(".audio_item.ai_has_btn").map { |elem| Audio.from_node(elem, @id) }
      rescue Exception => error
        raise Exceptions::ParseError, error.message, caller
      end
    end 

    # Load audios from JSON data.
    def audios__from_data(data)
      begin
        data.map { |audio_data| Audio.from_data(audio_data, @id) }
      rescue Exception => error
        raise Exceptions::ParseError, error.message, caller
      end
    end


    # Load playlist through web page requests.
    def playlist__web(owner_id, playlist_id, access_hash, options)
      begin
        # Load first page and get info
        first_page = load__page__playlist(owner_id, playlist_id, access_hash, offset: 0)
        
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
      rescue Exception => error
        raise Exceptions::ParseError, error.message, caller
      end
      # Now we can be sure we are on correct page
      
      first_page_audios = audios__from_page(first_page)
      
      # Check whether need to make additional requests
      options[:up_to] = real_size if (options[:up_to] < 0 || options[:up_to] > real_size)
      list = first_page_audios[0, options[:up_to]]
      while list.length < options[:up_to] do
        playlist_page = load__page__playlist(owner_id, playlist_id, access_hash, offset: list.length)
        list.concat(audios__from_page(playlist_page)[0, options[:up_to] - list.length])
      end
      
      Playlist.new(list, {
        :id => id,
        :owner_id => owner_id,
        :access_hash => access_hash,
        :title => title,
        :subtitle => subtitle,
        :real_size => real_size
      })
    end

    # Load playlist through JSON requests.
    def playlist__json(owner_id, playlist_id, access_hash, options)
      # Trying to parse out audios
      begin
        first_json = load__json__playlist_section(owner_id, playlist_id, access_hash, offset: 0)
        first_data = first_json["data"][0]
        first_data_audios = audios__from_data(first_data["list"])
      rescue Exception => error
        raise Exceptions::ParseError, error.message, caller
      end
      
      real_size = first_data["totalCount"]
      options[:up_to] = real_size if (options[:up_to] < 0 || options[:up_to] > real_size)
      list = first_data_audios[0, options[:up_to]]
      while list.length < options[:up_to] do
        json = load__json__playlist_section(owner_id, playlist_id, access_hash,
          offset: list.length
        )
        audios = audios__from_data(json["data"][0]["list"])
        list.concat(audios[0, options[:up_to] - list.length])
      end
      
      Playlist.new(list, {
        :id => first_data["id"],
        :owner_id => first_data["owner_id"],
        :access_hash => first_data["access_hash"],
        :title => CGI.unescapeHTML(first_data["title"].to_s),
        :subtitle => CGI.unescapeHTML(first_data["subtitle"].to_s),
        :real_size => real_size
      })
    end

    # Found playlist on *global* search page
    def playlist_urls__from_page(obj)
      page = obj.class == Mechanize::Page ? obj : load__page(obj)
      begin
        page.css(".AudioSerp__foundGlobal .AudioPlaylistSlider .al_playlist").map { |elem| elem.attribute("href").to_s }
      rescue Exception => error
        raise Exceptions::ParseError, error.message, caller
      end
    end

    # Load audios from wall using JSON request.
    def wall__json(owner_id, post_id, options)
      if options[:up_to] < 0 || options[:up_to] > 91
        options[:up_to] = 91
        Utility.warn("Current implementation of this method is not able to return more than 91 audios from wall.")
      end

      begin
        json = load__json__audios_wall(owner_id, post_id)
        data = json["data"][0]
        audios = audios__from_data(data["list"])[0, options[:up_to]]
      rescue Exception => error
        raise Exceptions::ParseError, error.message, caller
      end
      options[:with_url] ? from_id(audios) : audios
    end


    # Login
    def login(username, password)
      Utility.debug("Logging in.")
      # Loading login page
      homepage = load__page(Constants::URL::VK[:login])
      # Submitting login form
      login_form = homepage.forms.find { |form| form.action.start_with?(Constants::URL::VK[:login_action]) }
      login_form[Constants::VK_LOGIN_FORM_NAMES[:username]] = username.to_s
      login_form[Constants::VK_LOGIN_FORM_NAMES[:password]] = password.to_s
      after_login = @agent.submit(login_form)

      # Checking whether logged in
      raise Exceptions::LoginError, "Unable to login. Redirected to #{after_login.uri.to_s}", caller unless after_login.uri.to_s == Constants::URL::VK[:feed]
      
      # Parsing information about this profile
      profile = load__page(Constants::URL::VK[:profile])      
      @name = profile.title.to_s
      @id = profile.link_with(href: Constants::Regex::VK_HREF_ID_CONTAINING).href.slice(/\d+/).to_i
    end
    
    # Shortcut
    def unmask_link(link)
      VkMusic::LinkDecoder.unmask_link(link, @id)
    end
    
  end
  
end
