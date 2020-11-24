# frozen_string_literal: true

# Logs in provided agent
def login_agent(agent)
  login = VkMusic::Request::Login.new
  login.call(agent)
  login.send_form(ENV['VK_LOGIN'], ENV['VK_PASSWORD'], agent)
end

# Path to file where testing cookies will be stored
AGENT_COOKIES_PATH = 'spec/.cookies'

# @return [Mechanize] logged in Mechanize client.
def logged_in_agent
  agent = Mechanize.new
  if File.exist?(AGENT_COOKIES_PATH)
    load_cookie_jar(agent.cookie_jar)
  else
    login_agent(agent)
  end
  agent.cookie_jar.save(AGENT_COOKIES_PATH)
  agent
end

# @return [Client] logged in client.
def logged_in_client
  VkMusic::Client.new(agent: logged_in_agent)
end

# @param [HTTP::CookieJar]
def load_cookie_jar(jar)
  data = File.read(AGENT_COOKIES_PATH)
  data.start_with?('{') ? load_cookie_jar_json(jar, data) : load_cookie_jar_mechanize(jar)
rescue StandardError => e
  VkMusic.log.error('spec') { "Failed to parse saved cookies: #{e}:\m#{e.full_message}" }
end

# Loads cookies from JSON data
def load_cookie_jar_json(jar, data)
  VkMusic.log.info('spec') { 'Loading JSON cookies' }
  JSON.parse(data).each_pair do |k, v|
    jar.add(URI('https://m.vk.com'), HTTP::Cookie.new(k, v))
  end
end

# Loads cookies from Mechanize file
def load_cookie_jar_mechanize(jar)
  VkMusic.log.info('spec') { 'Loading Mechanize cookies' }
  jar.load(AGENT_COOKIES_PATH)
end
