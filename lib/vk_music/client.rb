require "mechanize"
require "json"

module VkMusic

  class Client
  
    attr_reader :id, :name
    
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
    
    def find_audio(query)
      uri = URI(VK_URL[:audios])
      uri.query = URI.encode_www_form({ "act" => "search", "q" => query.to_s })
      load_audios_from_page(uri)
    end
    
    def get_playlist(url, up_to = nil)
      # NOTICE: it is possible to use same type of requests as in get_audios method
      begin
        url, owner_id, id, access_hash = url.match(PLAYLIST_URL_REGEX).to_a
      
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
        raise PlaylistParseError, "unable to parse playlist page. Error: #{error.message}", caller
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
    
    def get_audios(id, up_to = nil)
      Warning.warn("Current implementation of method VkMusic::Client#get_audios is only able to load first 100 audios from user page.\n") if (up_to && up_to > 100)
      # NOTICE: this method is only able to load first 100 audios
      # NOTICE: it is possible to download 50 audios per request on "https://m.vk.com/audios#{owner_id}?offset=#{offset}", so it will cost A LOT to download all of audios (up to 200 requests).
      # NOTICE: it is possible to load up to 2000 audios **without url** if offset is negative
      
      # Trying to parse out audios
      begin
        first_json = load_playlist_json_section(id: id.to_s, playlist_id: -1, offset: 0)
        first_data = first_json["data"][0]
        first_data_audios = load_audios_from_data(first_data)
      rescue Exception => error
        raise AudiosSectionParseError, "unable to load or parse audios section: #{error.message}", caller
      end
      
      #total_count = first_data["totalCount"] # NOTICE: not used due to restrictions described above
      total_count = first_data_audios.length
      up_to = total_count if (up_to.nil? || up_to < 0 || up_to > total_count)
      list = first_data_audios[0, up_to]      
      
      # It turns out user audios are just playlist with id -1
      Playlist.new(list, {
        :id => first_data["id"],
        :owner_id => first_data["owner_id"],
        :access_hash => first_data["access_hash"],
        :title => first_data["title"],
        :subtitle => first_data["subtitle"],
      })
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
      uri = URI(VK_URL[:audios])
      uri.query = URI.encode_www_form({
        "act" => "audio_playlist#{options[:owner_id]}_#{options[:id]}",
        "access_hash" => options[:access_hash].to_s,
        "offset" => options[:offset].to_i
      })
      load_page(uri)
    end
    def load_playlist_json_section(options)
      uri = URI(VK_URL[:audios])
      uri.query = URI.encode_www_form({
        "act" => "load_section",
        "owner_id" => options[:id],
        "playlist_id" => options[:playlist_id],
        "type" => "playlist",
        "offset" => options[:offset].to_i,
        "utf8" => true
      })
      begin
        load_json(uri)
      rescue Exception => error
        raise AudiosSectionParseError, "unable to load or parse audios section: #{error.message}", caller
      end
    end
    
    
    # Loading audios
    def load_audios_from_page(obj)
      page = obj.class == Mechanize::Page ? obj : load_page(obj)
      page.css(".audio_item.ai_has_btn").map { |elem| Audio.from_node(elem, @id) }
    end 
    def load_audios_from_data(data)
      data["list"].map { |audio_data| Audio.from_data_array(audio_data, @id) }
    end
    
    
    def login(username, password)
      # Loading login page
      homepage = load_page(VK_URL[:home])
      # Submitting login form
      login_form = homepage.forms.find { |form| form.action.start_with?(VK_URL[:login_action]) }
      login_form[VK_LOGIN_FORM_NAMES[:username]] = username.to_s
      login_form[VK_LOGIN_FORM_NAMES[:password]] = password.to_s
      after_login = @agent.submit(login_form)

      # Checking whether logged in
      raise LoginError, "unable to login. Redirected to #{after_login.uri.to_s}", caller unless after_login.uri.to_s == VK_URL[:feed]
      
      # Parsing information about this profile
      profile = load_page(VK_URL[:profile])      
      @name = profile.title
      @id = profile.link_with(href: /audios/).href.slice(/\d+/)
    end
    
    def unmask_link(link)
      VkMusic.unmask_link(link, @id)
    end
    
  end
  
end