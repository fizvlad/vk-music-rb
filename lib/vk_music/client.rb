require "mechanize"

module VkMusic

  class Client
  
    # User id and name
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
      # Loading page
      uri = URI(VK_URL[:audios])
      uri.query = URI.encode_www_form("act" => "search", "q" => query.to_s)
      page = load_page(uri)
      
      # Parsing audio elements
      audios = page.css(".audio_item.ai_has_btn").map { |elem| Audio.from_node(elem, @id) }
    end
    
    def get_playlist(url)
      # TODO
    end
    
    private
    def load_page(url)
      # Need URI object
      uri = URI(url) if url.class != URI
      
      # Arguments check
      raise ArgumentError, "HTTPS scheme required", caller unless uri.scheme == VK_URL[:scheme]
      raise ArgumentError, "this method is only used to interact with #{VK_URL[:host]}", caller unless uri.host == VK_URL[:host]
      
      @agent.get(url)
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