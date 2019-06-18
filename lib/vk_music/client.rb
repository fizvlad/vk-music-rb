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
      load_audios_from(uri)
    end
    
    def get_playlist(url, up_to = nil)
      url, owner_id, id, access_hash = url.match(PLAYLIST_URL_REGEX).to_a

      # Load first page and get info
      first_page = load_playlist_page(owner_id: owner_id, id: id, access_hash: access_hash, offset: 0)
      title = first_page.at_css(".audioPlaylist__title").text.strip
      subtitle = first_page.at_css(".audioPlaylist__subtitle").text.strip
      
      footer_node = first_page.at_css(".audioPlaylist__footer")
      if footer_node
        footer_match = footer_node.text.strip.match(/^\d+/)
        playlist_size = footer_match ? footer_match[0].to_i : 0
      else
        playlist_size = 0
      end
      
      first_page_audios = load_audios_from(first_page)
      
      # Check whether need to make additional requests
      up_to = playlist_size if (up_to.nil? || up_to < 0 || up_to > playlist_size)
      if first_page_audios.length >= up_to
        list = first_page_audios[0, up_to]
      else        
        list = first_page_audios
        loop do
          playlist_page = load_playlist_page(owner_id: owner_id, id: id, access_hash: access_hash, offset: list.length)
          list.concat(load_audios_from(playlist_page)[0, up_to - list.length])
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
    
    def get_audios(id)
      data = load_playlist_json_section(id: id, playlist_id: -1, offset: -1 * AUDIO_MAXIMUM_COUNT)[3][0]
      
      full_data_list = data["list"]
      
      # TODO: currently this method loads up to 2000 audio
      
      list = full_data_list.map do |audio_data|
        url_encoded = audio_data[2]
      
        Audio.new({
          :id => audio_data[0],
          :owner_id => audio_data[1],
          :artist => audio_data[4],
          :title => audio_data[3],
          :duration => audio_data[5],
          :url_encoded => url_encoded,
          :url => url_encoded ? VkMusic.unmask_link(url_encoded, @id) : "",
        })
      end
      
      Playlist.new(list, {
        :id => data["id"],
        :owner_id => data["owner_id"],
        :access_hash => data["access_hash"],
        :title => data["title"],
        :subtitle => data["subtitle"],
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
      uri.query = URI.encode_www_form({ "act" => "audio_playlist#{options[:owner_id]}_#{options[:id]}", "access_hash" => options[:access_hash].to_s, "offset" => options[:offset].to_i })
      load_page(uri)
    end
    def load_playlist_json_section(options)
      uri = URI(VK_URL[:audios])
      uri.query = URI.encode_www_form({ "act" => "load_section", "owner_id" => options[:id], "playlist_id" => options[:playlist_id], "type" => "playlist", "offset" => options[:offset].to_i })
      load_json(uri)
    end
    
    
    # Loading audios
    def load_audios_from(obj)
      page = obj.class == Mechanize::Page ? obj : load_page(obj)
      page.css(".audio_item.ai_has_btn").map { |elem| Audio.from_node(elem, @id) }
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