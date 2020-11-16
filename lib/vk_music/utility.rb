# frozen_string_literal: true

module VkMusic
  # Helpers
  module Utility; end
end

Dir[File.join(__dir__, 'utility', '*.rb')].each { |file| require_relative file }
