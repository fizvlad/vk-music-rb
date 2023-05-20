# frozen_string_literal: true

module VkMusic
  module Utility
    # Creates authorized client based of cookies file or ENV variables
    module Authorizer
      class << self
        # @param cookie_path [String?]
        # @return [Mechanize] logged in Mechanize client
        def call(login, password, cookie_path = nil)
          agent = Mechanize.new
          if cookie_path && File.exist?(cookie_path)
            load_cookie_jar(agent.cookie_jar, cookie_path)
          else
            login_agent(agent, login, password)
          end
          agent.cookie_jar.save(cookie_path, session: true) if cookie_path
          agent
        end

        private

        # @return [Client] logged in client.
        def logged_in_client
          VkMusic::Client.new(agent: logged_in_agent)
        end

        # @param jar [HTTP::CookieJar]
        # @param path [string]
        def load_cookie_jar(jar, path)
          data = File.read(path)
          VkMusic::Utility::CookieReader.call(jar, data)
        rescue StandardError => e
          VkMusic.log.error('authorizer') { "Failed to parse saved cookies: #{e}:\m#{e.full_message}" }
        end

        # Logs in provided agent
        def login_agent(agent, login, password)
          login_request = VkMusic::Request::Login.new
          login_request.call(agent)
          login_request.send_form(login, password, agent)
        end
      end
    end
  end
end
