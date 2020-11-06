# frozen_string_literal: true

module VkMusic
  # VK client
  class Client
    # Default user agent to use
    DEFAULT_USERAGENT = 'Mozilla/5.0 (Linux; Android 5.0; SM-G900P Build/LRX21T) ' \
                        'AppleWebKit/537.36 (KHTML, like Gecko) ' \
                        'Chrome/86.0.4240.111 Mobile Safari/537.36'
    public_constant :DEFAULT_USERAGENT

    # @return [Integer] ID of client
    attr_reader :id
    # @return [String] name of client
    attr_reader :name
    # @return [Mechanize] client used to access web pages
    attr_reader :agent

    # @param login [String]
    # @param password [String]
    def initialize(login:, password:, user_agent: DEFAULT_USERAGENT)
      @login = login
      @password = password

      @agent = Mechanize.new
      @agent.user_agent = user_agent

      self.login
    end

    # Make a login request
    def login
      VkMusic.log.info("Client#{@id}") { 'Logging in...' }
      # TODO
    end
  end
end
