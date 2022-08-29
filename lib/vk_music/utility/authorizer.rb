# frozen_string_literal: true

module VkMusic
  module Utility
    # Creates authorized client based of cookies file or ENV variables
    module Authorizer
      class << self
        # @param cookie_path [string]
        # @return [Mechanize] logged in Mechanize client
        def call(cookie_path)
          agent = Mechanize.new
          if File.exist?(cookie_path)
            load_cookie_jar(agent.cookie_jar, cookie_path)
          else
            login_agent(agent)
          end
          agent.cookie_jar.save(cookie_path, session: true)
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
          VkMusic::Utility::CookieReader.call(jar, path)
        rescue StandardError => e
          VkMusic.log.error('authorizer') { "Failed to parse saved cookies: #{e}:\m#{e.full_message}" }
        end

        # Logs in provided agent
        def login_agent(agent)
          login = VkMusic::Request::Login.new
          login.call(agent)
          login.send_form(ENV['VK_LOGIN'], ENV['VK_PASSWORD'], agent)
        end
      end
    end
  end
end
