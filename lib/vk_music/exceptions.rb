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

  class ReloadAudiosParseError < AudiosParseError
    # Unable to load or parse all of audios by ids
  end
  
  class IdParseError < AudiosParseError
    # Unable to convert string to id
  end
  
end
