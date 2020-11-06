module VkMusic
  ##
  # Constants.
  module Constants
    ##
    # Default web user agent.
    DEFAULT_USER_AGENT = ''.freeze # Using empty user agent confuses VK and it returnes MP3

    ##
    # Different URLs
    module URL
      ##
      # Hash with URLs to VK pages which are used by library.
      VK = {
        scheme: 'https',
        host: 'm.vk.com',
        home: 'https://m.vk.com',
        profile: 'https://m.vk.com/id0',
        feed: 'https://m.vk.com/feed',
        audios: 'https://m.vk.com/audio',
        login: 'https://m.vk.com/login',
        login_action: 'https://login.vk.com',
        wall: 'https://m.vk.com/wall',
        audio_unavailable: 'https://m.vk.com/mp3/audio_api_unavailable.mp3',
        profile_audios: 'https://m.vk.com/audios'
      }.freeze
    end

    ##
    # Regular expressions
    module Regex
      ##
      # VK user or group ID.
      VK_ID_STR = /^-?\d+$/.freeze
      ##
      # VK user or group ID.
      VK_ID = /-?\d+/.freeze
      ##
      # VK prefixed user or group ID.
      VK_PREFIXED_ID_STR = /^(?:id|club|group|public|event)(\d+)$/.freeze
      ##
      # VK custom ID regular expression.
      VK_CUSTOM_ID = /^\w+$/.freeze
      ##
      # VK URL regular expression.
      VK_URL = %r{(?:https?://)?(?:m\.|www\.)?vk\.com/([\w\-]+)}.freeze
      ##
      # +href+ attribute with VK ID regular expression.
      VK_HREF_ID_CONTAINING = /(?:audios|photo|write|owner_id=|friends\?id=)(-?\d+)/.freeze
      ##
      # VK audios page regular expression.
      VK_AUDIOS_URL_POSTFIX = /^audios(-?\d+)$/.freeze
      ##
      # Playlist URL regular expression.
      VK_PLAYLIST_URL_POSTFIX = %r{.*(?:audio_playlist|album/|playlist/)(-?\d+)_(\d+)(?:(?:(?:.*(?=&access_hash=)&access_hash=)|/|%2F|_)([\da-z]+))?}.freeze
      ##
      # Post URL regular expression #1.
      VK_POST_URL_POSTFIX = /.*post(-?\d+)_(\d+)/.freeze
      ##
      # Post URL regular expression #2.
      VK_WALL_URL_POSTFIX = /.*wall(-?\d+)_(\d+)/.freeze
      ##
      # Audios block ID
      VK_BLOCK_URL = /(?:section=recoms_block&type=|act=block&block=)([a-zA-Z\d]+)/.freeze
    end

    ##
    # Names used in VK login form.
    VK_LOGIN_FORM_NAMES = {
      username: 'email',
      password: 'pass'
    }.freeze

    ##
    # Maximum amount of audios in VK playlist.
    MAXIMUM_PLAYLIST_SIZE = 10_000
  end
end