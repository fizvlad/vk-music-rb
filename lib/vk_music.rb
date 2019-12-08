require "cgi"
require "logger"
require "mechanize"
require "execjs"
require "json"

require_relative "vk_music/version"
require_relative "vk_music/constants"
require_relative "vk_music/exceptions"
require_relative "vk_music/utility"
require_relative "vk_music/link_decoder"
require_relative "vk_music/audio"
require_relative "vk_music/playlist"
require_relative "vk_music/client"

##
# Main module.
module VkMusic; end
