# frozen_string_literal: true

# Path to file where testing cookies will be stored
AGENT_COOKIES_PATH = 'spec/.cookies'

# @return [Mechanize] logged in Mechanize client.
def logged_in_agent
  VkMusic::Utility::Authorizer.call(ENV.fetch('VK_LOGIN', nil), ENV.fetch('VK_PASSWORD', nil), AGENT_COOKIES_PATH)
end

# @return [Client] logged in client.
def logged_in_client
  VkMusic::Client.new(agent: logged_in_agent)
end
