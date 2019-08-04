module VkMusic

  ##
  # Constants.
  module Constants
    
    ##
    # Web user agent.
    # DEFAULT_USER_AGENT = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1636.0 Safari/537.36"

    ##
    # Hash with URLs used by library.
    VK_URL = {
      :scheme => "https",
      :host => "m.vk.com",
      :home => "https://m.vk.com",
      :profile => "https://m.vk.com/id0",
      :feed => "https://m.vk.com/feed",
      :audios => "https://m.vk.com/audio",
      :login  => "https://m.vk.com/login",
      :login_action => "https://login.vk.com",
      :wall => "https://m.vk.com/wall"
    }
    
    ##
    # Names used in VK login form.
    VK_LOGIN_FORM_NAMES = {
      :username => "email",
      :password => "pass",
    }
    
    ##
    # VK ID regular expression.
    VK_ID_REGEX = /^-?\d+$/

    ##
    # VK audios page regular expression.
    VK_AUDIOS_REGEX = /^audios-?\d+$/

    ##
    # VK prefixed URL to user or group page regular expression.
    VK_PREFIXED_ID_REGEX = /^(?:id|club|group|public|event)\d+$/

    ##
    # VK custom ID regular expression.
    VK_CUSTOM_ID_REGEX = /^\w+$/

    ##
    # VK URL regular expression.
    VK_URL_REGEX = /(?:https?:\/\/)?(?:m\.|www\.)?vk\.com\/([\w\-]+)/
    
    ##
    # +href+ attribute with VK ID regular expression.
    VK_HREF_ID_CONTAINING_REGEX = /(?:audios|photo|write|owner_id=|friends\?id=)-?\d+/
    
    ##
    # Playlist URL regular expression.
    PLAYLIST_URL_REGEX = /.*audio_playlist(-?\d+)_(\d+)(?:(?:(?:&access_hash=)|\/|%2F)([\da-z]+))?/

    ##
    # Post URL regular expression.
    POST_URL_REGEX = /.*wall(-?\d+)_(\d+)/
    
  end

  include Constants

end
