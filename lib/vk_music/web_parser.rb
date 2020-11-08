# frozen_string_literal: true

module VkMusic
  # Parses out any data from page received by {Request} objects
  module WebParser; end
end

require_relative 'web_parser/base'
require_relative 'web_parser/login'
require_relative 'web_parser/my_page'
require_relative 'web_parser/playlist'
require_relative 'web_parser/search'
require_relative 'web_parser/section'
