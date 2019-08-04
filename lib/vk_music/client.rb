require "mechanize"
require "json"

##
# Main module.
module VkMusic

  ##
  # Main class with all the interface.
  # To start working with VK audios firstly create new client with +Client.new+.
  class Client
  
    ##
    # @return [Integer] ID of user.
    attr_reader :id

    ##
    # @return [String] name of user.
    attr_reader :name
    
    @agent = nil # Mechanize agent
  
    ##
    # Create new client and login.
    #
    # @option options [String] :username usually telephone number or email.
    # @option options [String] :password
    def initialize(options = {})
      # Arguments check
      raise ArgumentError, "options hash must be provided", caller unless options.class == Hash
      raise ArgumentError, "username is not provided", caller unless options.has_key?(:username)
      raise ArgumentError, "password is not provided", caller unless options.has_key?(:password)
      
      # Setting up client
      @agent = Mechanize.new
      login(options[:username], options[:password])
    end
    
    ##
    # Search for audio.
    #
    # @param query [String] string to search for.
    #
    # @return [Array<Audio>] array with audios matching given string. Possibly empty.
    def find_audio(query)
      uri = URI(Constants::VK_URL[:audios])
      uri.query = Utility.hash_to_params({ "act" => "search", "q" => query.to_s })

      load_audios_from_page(uri)
    end
    
    ##
    # Get playlist.
    #
    # @note this method sends additional request for every 100 audios in playlist,
    #   use +up_to+ to set maximum amount of audios to load.
    #
    # @todo implement loading of audios without URL using +load_section+ requests.
    #
    # @param url [String] URL to playlist.
    # @param up_to [Integer]
    #
    # @return [Playlist] playlist iwht audios. Possibly empty.
    #   Possibly contains audios without download URL.
    def get_playlist(url, up_to = nil)
      begin
        url, owner_id, id, access_hash = url.to_s.match(Constants::PLAYLIST_URL_REGEX).to_a
      
        # Load first page and get info
        first_page = load_playlist_page(owner_id: owner_id, id: id, access_hash: access_hash, offset: 0)
        
        # Parse out essential data
        title = first_page.at_css(".audioPlaylist__title").text.strip
        subtitle = first_page.at_css(".audioPlaylist__subtitle").text.strip
        
        footer_node = first_page.at_css(".audioPlaylist__footer")
        if footer_node
          footer_match = footer_node.text.strip.match(/^\d+/)
          playlist_size = footer_match ? footer_match[0].to_i : 0
        else
          playlist_size = 0
        end
      rescue Exception => error
        raise Exceptions::PlaylistParseError, "unable to parse playlist page. Error: #{error.message}", caller
      end
      # Now we can be sure we are on correct page
      
      first_page_audios = load_audios_from_page(first_page)
      
      # Check whether need to make additional requests
      up_to = playlist_size if (up_to.nil? || up_to < 0 || up_to > playlist_size)
      if first_page_audios.length >= up_to
        list = first_page_audios[0, up_to]
      else        
        list = first_page_audios
        loop do
          playlist_page = load_playlist_page(owner_id: owner_id, id: id, access_hash: access_hash, offset: list.length)
          list.concat(load_audios_from_page(playlist_page)[0, up_to - list.length])
          break if list.length == up_to
        end        
      end
      
      Playlist.new(list, {
        :id => id,
        :owner_id => owner_id,
        :access_hash => access_hash,
        :title => title,
        :subtitle => subtitle,
      })
    end
    
    ##
    # Get user or group audios.
    #
    # @note currently this method is only able to download first 100 audios.
    #
    # @todo implement loading of audios without URL using +load_section+ requests.
    #
    # @param url [String] URL to user or group page.
    # @param up_to [Integer]
    #
    # @return [Playlist] playlist with user or group audios. Possibly empty.
    #   Possibly contains audios without download URL.
    def get_audios(url, up_to = nil)
      if up_to && up_to > 100
        Utility.warn("Current implementation of method VkMusic::Client#get_audios is only able to load first 100 audios from user page.")
      end
      
      # Firstly, we need to get numeric id
      id = get_id(url.to_s)      
      
      # Trying to parse out audios
      begin
        first_json = load_playlist_json_section(id.to_s, -1, 0)
        first_data = first_json["data"][0]
        first_data_audios = load_audios_from_data(first_data["list"])
      rescue Exception => error
        raise Exceptions::AudiosSectionParseError, "unable to load or parse audios section: #{error.message}", caller
      end
      
      #total_count = first_data["totalCount"] # Not used due to restrictions described above
      total_count = first_data_audios.length # Using this instead

      up_to = total_count if (up_to.nil? || up_to < 0 || up_to > total_count)
      list = first_data_audios.first(up_to)
      
      # It turns out user audios are just playlist with id -1
      Playlist.new(list, {
        :id => first_data["id"],
        :owner_id => first_data["owner_id"],
        :access_hash => first_data["access_hash"],
        :title => CGI.unescapeHTML(first_data["title"].to_s),
        :subtitle => CGI.unescapeHTML(first_data["subtitle"].to_s),
      })
    end

    ##
    # Get audios with download URLs by their IDs and secrets.
    #
    # @note this method is only able to get downlaod links for up to 10 audios.
    #
    # @param args [Audio, Array<(owner_id, id, secret_1, secret_2)>]
    #
    # @return [Array<Audio>] array of audios with download URLs.
    def get_audios_by_id(*args)
      if args.size > 10
        Utility.warn("Current implementation of method VkMusic::Client#get_audios_by_id is only able to handle first 10 audios.")
        args = args.first(10)
      end

      arr.map! do |el| 
        case el
          when Array
            el.join("_")
          when Audio
            "#{el.owner_id}_#{el.id}_#{el.secret_1}_#{el.secret_2}"
          else
            el.to_s
        end
      end
      json = load_audios_json_by_id(arr)
      result = load_audios_from_data(json["data"][0].to_a)
      raise Exceptions::ReloadAudiosParseError, "Result size don't match: excepected #{arr.size}, got #{result.size}", caller if result.size != arr.size

      result
    end

    ##
    # Get audios on wall of user or group starting with given post.
    #
    # @note this method will return only 10 first audios.
    #
    # @param owner_id [Integer] ID of user or group.
    # @param post_id [Integer] ID of post.
    # @param up_to [Integer] maximum amount of audios to return.
    #
    # @return [Playlist] playlist of audios with download URLs. 
    def get_audios_from_wall(owner_id, post_id, up_to = nil)
      begin
        json = load_audios_json_from_wall(owner_id, post_id)
        data = json["data"][0]
        no_url_audios = load_audios_from_data(data["list"])
      rescue Exception => error
        raise Exceptions::WallParseError, "Failed to parse wall from #{@owner_id}_#{post_id}. Error: #{error.message}", caller
      end

      up_to = no_url_audios.size if (up_to.nil? || up_to < 0 || up_to > no_url_audios.size)
      no_url_audios = no_url_audios.first(up_to) 

      list = get_audios_by_id(*no_url_audios)

      Playlist.new(list, {
        :id => data["id"],
        :owner_id => data["owner_id"],
        :access_hash => data["access_hash"],
        :title => CGI.unescapeHTML(data["title"].to_s),
        :subtitle => CGI.unescapeHTML(data["subtitle"].to_s),
      })
    end
    
    ##
    # Get audios attached to post.
    #
    # @param url [String] URL to post.
    #
    # @return [Array<Audio>] audios with download URLs.
    def get_audios_from_post(url)
      url, owner_id, post_id = url.match(Constants::POST_URL_REGEX).to_a

      amount = get_amount_of_audios_in_post(owner_id, post_id)
      get_audios_from_wall(owner_id, post_id, amount).to_a
    end

    ##
    # Get user or group id. Sends one request if custom id provided
    #
    # @param str [String] link, id with prefix or custom id.
    #
    # @return [Integer]
    def get_id(str)
      case str
        when Constants::VK_URL_REGEX
          path = str.match(Constants::VK_URL_REGEX)[1]
          get_id(path) # Recursive call
        when Constants::VK_ID_REGEX
          str
        when Constants::VK_AUDIOS_REGEX
          str.match(/-?\d+/).to_s # Numbers with sigh
        when Constants::VK_PREFIXED_ID_REGEX
          id = str.match(/\d+/).to_s # Just numbers. Sign needed
          id = "-#{id}" unless str.start_with?("id")
          id
        when Constants::VK_CUSTOM_ID_REGEX
          begin
            page = load_page("#{Constants::VK_URL[:home]}/#{str}")
          rescue Exception => error
            raise Exceptions::IdParseError, "unable to load page by id \"#{str}\". Error: #{error.message}"
          end
          
          unless page.at_css(".PageBlock .owner_panel")
            # Ensure this isn't some random vk page
            raise Exceptions::IdParseError, "page #{str} doesn't seem to be a group or user page"
          end
          
          id = page.link_with(href: Constants::VK_HREF_ID_CONTAINING_REGEX).href.slice(/-?\d+/) # Numbers with sign
          id
      else
        raise Exceptions::IdParseError, "unable to convert \"#{str}\" into id"
      end
    end

    ##
    # Get amount of audios attached to specified post.
    #
    # @param owner_id [Integer] ID of post owner.
    # @param post_id [Integer] ID of post on wall.
    #
    # @return [Integer]
    def get_amount_of_audios_in_post(owner_id, post_id)
      begin
        page = load_page("#{Constants::VK_URL[:wall]}#{owner_id}_#{post_id}")
        result = page.css(".wi_body > .pi_medias .medias_audio").size
      rescue Exception => error
        raise Exceptions::PostParseError, "Unable to get amount of audios in post #{owner_id}_#{post_id}. Error: #{error.message}", caller
      end
      raise Exceptions::PostParseError, "Post not found: #{owner_id}_#{post_id}", caller if result == 0 && !page.css(".service_msg_error").empty?
      result
    end


    private
    
    # Loading pages
    def load_page(url)
      uri = URI(url) if url.class != URI      
      @agent.get(uri)
    end
    def load_json(url)
      page = load_page(url)
      JSON.parse(page.body.strip)
    end
    
    def load_playlist_page(options)
      uri = URI(Constants::VK_URL[:audios])
      uri.query = Utility.hash_to_params({
        "act" => "audio_playlist#{options[:owner_id]}_#{options[:id]}",
        "access_hash" => options[:access_hash].to_s,
        "offset" => options[:offset].to_i
      })
      load_page(uri)
    end
    def load_playlist_json_section(owner_id, playlist_id, offset = 0)
      uri = URI(Constants::VK_URL[:audios])
      uri.query = Utility.hash_to_params({
        "act" => "load_section",
        "owner_id" => owner_id,
        "playlist_id" => playlist_id,
        "type" => "playlist",
        "offset" => offset,
        "utf8" => true
      })
      begin
        load_json(uri)
      rescue Exception => error
        raise Exceptions::AudiosSectionParseError, "unable to load or parse audios section: #{error.message}", caller
      end
    end

    def load_audios_json_by_id(ids)
      uri = URI(Constants::VK_URL[:audios])
      uri.query = Utility.hash_to_params({
        "act" => "reload_audio",
        "ids" => ids,
        "utf8" => true
      })
      begin
        load_json(uri)
      rescue Exception => error
        raise Exceptions::AudiosSectionParseError, "unable to load or parse audios section: #{error.message}", caller
      end
    end

    def load_audios_json_from_wall(owner_id, post_id)
      uri = URI(Constants::VK_URL[:audios])
      uri.query = Utility.hash_to_params({
        "act" => "load_section",
        "owner_id" => owner_id,
        "post_id" => post_id,
        "type" => "wall",
        "wall_type" => "own",
        "utf8" => true
      })
      begin
        load_json(uri)
      rescue Exception => error
        raise Exceptions::AudiosSectionParseError, "unable to load or parse audios section: #{error.message}", caller
      end
    end
    
    
    # Loading audios
    def load_audios_from_page(obj)
      page = obj.class == Mechanize::Page ? obj : load_page(obj)
      page.css(".audio_item.ai_has_btn").map { |elem| Audio.from_node(elem, @id) }
    end 
    def load_audios_from_data(data)
      data.map { |audio_data| Audio.from_data_array(audio_data, @id) }
    end
    
    
    # Login
    def login(username, password)
      # Loading login page
      homepage = load_page(Constants::VK_URL[:home])
      # Submitting login form
      login_form = homepage.forms.find { |form| form.action.start_with?(Constants::VK_URL[:login_action]) }
      login_form[Constants::VK_LOGIN_FORM_NAMES[:username]] = username.to_s
      login_form[Constants::VK_LOGIN_FORM_NAMES[:password]] = password.to_s
      after_login = @agent.submit(login_form)

      # Checking whether logged in
      raise Exceptions::LoginError, "unable to login. Redirected to #{after_login.uri.to_s}", caller unless after_login.uri.to_s == Constants::VK_URL[:feed]
      
      # Parsing information about this profile
      profile = load_page(Constants::VK_URL[:profile])      
      @name = profile.title
      @id = profile.link_with(href: Constants::VK_HREF_ID_CONTAINING_REGEX).href.slice(/\d+/).to_i
    end
    
    def unmask_link(link)
      VkMusic::LinkDecoder.unmask_link(link, @id)
    end
    
  end
  
end
