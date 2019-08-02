require "mechanize"
require "json"

module VkMusic

  # Main class with all the interface.
  class Client
  
    # ID of user
    attr_reader :id
    # Name of user
    attr_reader :name
    
    # Mechanize agent
    @agent = nil
  
    def initialize(options)
      # Arguments check
      raise ArgumentError, "options hash must be provided", caller unless options.class == Hash
      raise ArgumentError, "username is not provided", caller unless options.has_key?(:username)
      raise ArgumentError, "password is not provided", caller unless options.has_key?(:password)
      
      # Setting up client
      @agent = Mechanize.new
      login(options[:username], options[:password])
    end
    
    # Find Audio.
    #
    # ===== Parameters:
    # * [+query+] (+String+) - string to search for.
    #
    # ===== Returns:
    # * (+Array+) - array of Audio.
    def find_audio(query)
      uri = URI(Constants::VK_URL[:audios])
      uri.query = Utility.hash_to_params({ "act" => "search", "q" => query.to_s })
      load_audios_from_page(uri)
    end
    
    # Get Playlist.
    #
    # ===== Parameters:
    # * [+url+] (+String+) - url to playlist.
    # * [+up_to+] (+Integer+) - maximum amount of Audio to load.
    #
    # ===== Returns:
    # * (+Playlist+)
    def get_playlist(url, up_to = nil)
      # NOTICE: it is possible to use same type of requests as in get_audios method
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
    
    # Get user or group audios.
    #
    # ===== Parameters:
    # * [+url+] (+String+) - URL to user or group.
    # * [+up_to+] (+Integer+) - maximum amount of Audio to load.
    #
    # ===== Returns:
    # * (+Playlist+)
    def get_audios(url, up_to = nil)
      if up_to && up_to > 100
        Utility.warn("Current implementation of method VkMusic::Client#get_audios is only able to load first 100 audios from user page.")
      end
      # NOTICE: this method is only able to load first 100 audios
      # NOTICE: it is possible to download 50 audios per request on "https://m.vk.com/audios#{owner_id}?offset=#{offset}", so it will cost A LOT to download all of audios (up to 200 requests).
      # NOTICE: it is possible to load up to 2000 audios **without url** if offset is negative
      
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
      
      #total_count = first_data["totalCount"] # NOTICE: not used due to restrictions described above
      total_count = first_data_audios.length # Using this instead

      # TODO: Loading rest

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

    # Get audios by their ids and secrets.
    #
    # ===== Parameters:
    # * [+arr+] (+Array+) - Array of objects, which can have different types: Audio or Array[owner_id, id, secret_1, secret_2].
    #
    # ===== Returns:
    # * (+Array+) - array of audios with decoded URLs.
    def get_audios_by_id(*arr)
      if arr.size > 10
        Utility.warn("Current implementation of method VkMusic::Client#get_audios_by_id is only able to handle first 10 audios.")
        arr = arr.first(10)
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

    # Get audios on wall of user or group starting with given post.
    #
    # ===== Parameters:
    # * [+owner_id+] (+Integer+)
    # * [+post_id+] (+Integer+)
    # * [+up_to+] (+Integer+) - maximum amount of Audio to load.
    #
    # ===== Returns:
    # * (+Array+) - array of audios with URLs.
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
    
    # Get audios attached to post.
    #
    # ===== Parameters:
    # * [+url+] (+String+)
    #
    # ===== Returns:
    # * (+Array+) - array of audios with URLs.
    def get_audios_from_post(url)
      url, owner_id, post_id = url.match(Constants::POST_URL_REGEX).to_a

      amount = get_amount_of_audios_in_post(owner_id, post_id)
      get_audios_from_wall(owner_id, post_id, amount).to_a
    end

    # Get user or group id.
    #
    # ===== Parameters:
    # * [+str+] (+String+) - link, id with prefix or custom id.
    #
    # ===== Returns:
    # * (+Integer+)
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

    # Get amount of audios attached to specified post.
    #
    # ===== Parameters:
    # * [+owner_id+] (+Integer+)
    # * [+post_id+] (+Integer+)
    #
    # ===== Returns:
    # * (+Integer+)
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
      @id = profile.link_with(href: Constants::VK_HREF_ID_CONTAINING_REGEX).href.slice(/\d+/)
    end
    
    def unmask_link(link)
      VkMusic::LinkDecoder.unmask_link(link, @id)
    end
    
  end
  
end
