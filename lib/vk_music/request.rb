# frozen_string_literal: true

module VkMusic
  # Bunch of different web requests
  module Request
    # VK root URL
    VK_ROOT = 'https://m.vk.com'
    public_constant :VK_ROOT
  end
end

require_relative 'request/base'
Dir[File.join(__dir__, 'request', '*.rb')].each { |file| require_relative file }
