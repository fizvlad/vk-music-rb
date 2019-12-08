module VkMusic
  ##
  # Constants.
  module Constants
    ##
    # Default web user agent.
    DEFAULT_USER_AGENT = "Mozilla/5.0 (Linux; Android 5.1.1; Redmi 3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.132 Mobile Safari/537.36 OPR/54.2.2672.49907"

    ##
    # Different URLs
    module URL
      ##
      # Hash with URLs to VK pages which are used by library.
      VK = {
        scheme: "https",
        host: "m.vk.com",
        home: "https://m.vk.com",
        profile: "https://m.vk.com/id0",
        feed: "https://m.vk.com/feed",
        audios: "https://m.vk.com/audio",
        login: "https://m.vk.com/login",
        login_action: "https://login.vk.com",
        wall: "https://m.vk.com/wall",
        audio_unavailable: "https://m.vk.com/mp3/audio_api_unavailable.mp3",
        profile_audios: "https://m.vk.com/audios",
      }
    end

    ##
    # Regular expressions
    module Regex
      ##
      # VK user or group ID.
      VK_ID_STR = /^-?\d+$/
      ##
      # VK user or group ID.
      VK_ID = /-?\d+/
      ##
      # VK prefixed user or group ID.
      VK_PREFIXED_ID_STR = /^(?:id|club|group|public|event)(\d+)$/
      ##
      # VK custom ID regular expression.
      VK_CUSTOM_ID = /^\w+$/
      ##
      # VK URL regular expression.
      VK_URL = /(?:https?:\/\/)?(?:m\.|www\.)?vk\.com\/([\w\-]+)/
      ##
      # +href+ attribute with VK ID regular expression.
      VK_HREF_ID_CONTAINING = /(?:audios|photo|write|owner_id=|friends\?id=)(-?\d+)/
      ##
      # VK audios page regular expression.
      VK_AUDIOS_URL_POSTFIX = /^audios(-?\d+)$/
      ##
      # Playlist URL regular expression.
      VK_PLAYLIST_URL_POSTFIX = /.*(?:audio_playlist|album\/)(-?\d+)_(\d+)(?:(?:(?:.*(?=&access_hash=)&access_hash=)|\/|%2F|_)([\da-z]+))?/
      ##
      # Post URL regular expression #1.
      VK_POST_URL_POSTFIX = /.*post(-?\d+)_(\d+)/
      ##
      # Post URL regular expression #2.
      VK_WALL_URL_POSTFIX = /.*wall(-?\d+)_(\d+)/
    end

    ##
    # Names used in VK login form.
    VK_LOGIN_FORM_NAMES = {
      username: "email",
      password: "pass"
    }

    ##
    # Maximum amount of audios in VK playlist.
    MAXIMUM_PLAYLIST_SIZE = 10000
  end
end
