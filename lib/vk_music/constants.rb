module VkMusic

  # Web
  # DEFAULT_USER_AGENT = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1636.0 Safari/537.36"

  VK_URL = {
    :scheme => "https",
    :host => "m.vk.com",
    :home => "https://m.vk.com",
    :profile => "https://m.vk.com/id0",
    :feed => "https://m.vk.com/feed",
    :audios => "https://m.vk.com/audio",
    :login  => "https://m.vk.com/login",
    :login_action => "https://login.vk.com",
  }
  
  VK_LOGIN_FORM_NAMES = {
    :username => "email",
    :password => "pass",
  }
  
  VK_URL_REGEX = /(?:https?:\/\/)?(?:m\.|www\.)?vk\.com\/(.+)/
  
  # Playlist
  PLAYLIST_URL_REGEX = /.*audio_playlist(-?[\d]+)_([\d]+)(?:(?:(?:&access_hash=)|\/|%2F)([\da-z]+))?/
  
  
  # QUESTION: Should I move ALL the constants (string, regex etc) here? It would make code more flexible, but seems like overkill
  
end