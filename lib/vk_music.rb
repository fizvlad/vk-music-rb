# frozen_string_literal: true

require 'execjs'
require 'mechanize'
require 'json'
require 'logger'

# Main module
module VkMusic
  @@log = Logger.new($stdout)

  # Logger of library classes
  # @return [Logger]
  def self.log
    @@log
  end

  # Replace logger
  # @param logger [Logger]
  def self.log=(logger)
    @@log = logger
  end
end

require_relative 'vk_music/version'
require_relative 'vk_music/utility'
require_relative 'vk_music/request'
require_relative 'vk_music/client'
require_relative 'vk_music/audio'
require_relative 'vk_music/playlist'
