module VkMusic

  # General class for all the errors
  class VkMusicError < RuntimeError; end

  # Failed to login
  class LoginError < VkMusicError; end
  
  # Unable to parse audios from somewhere
  class AudiosParseError < VkMusicError; end

  # Unable to find playlist or got permission error
  class PlaylistParseError < AudiosParseError; end

  # Unable to load or parse audios section from json
  class AudiosSectionParseError < AudiosParseError; end

  # Unable to load or parse all of audios by ids
  class ReloadAudiosParseError < AudiosParseError; end
  
  # Unable to convert string to id
  class IdParseError < AudiosParseError; end
    
  # Unable to parse audios from post
  class PostParseError < AudiosParseError; end
  
end
