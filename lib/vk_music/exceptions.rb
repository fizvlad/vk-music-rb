module VkMusic

  class LoginError < RuntimeError
    # Unable to login
  end
  
  class PlaylistParseError < RuntimeError
    # Unable to find playlist or got permission error
  end
  
  class AudiosParseError < RuntimeError
    # Unable to find user/group or got permission error
  end
  
  class AudiosSectionParseError < AudiosParseError
    # Unable to load or parse audios section
  end
  
end