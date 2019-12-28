module VkMusic
  ##
  # Exceptions.
  module Exceptions
    ##
    # General class for all the errors.
    class VkMusicError < RuntimeError; end
    ##
    # Failed to login.
    class LoginError < VkMusicError; end
    ##
    # Failed to get request. _Only_ thrown when Mechanize failed to load page
    class RequestError < VkMusicError; end
    ##
    # Parse error. Request is OK, but something went wrong while parsing reply.
    #   It might be missing playlist/post as well.
    class ParseError < VkMusicError; end
  end

  include Exceptions
end
