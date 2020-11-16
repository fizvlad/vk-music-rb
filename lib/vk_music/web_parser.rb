# frozen_string_literal: true

module VkMusic
  # Parses out any data from page received by {Request} objects
  module WebParser; end
end

Dir[File.join(__dir__, 'web_parser', '*.rb')].each { |file| require_relative file }
