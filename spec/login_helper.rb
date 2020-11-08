# frozen_string_literal: true

# Read spec_data file.
# @param name [String]
# @return [String]
def spec_data(name)
  File.read("spec_data/#{name}.response")
end

# Logs in provided agent
def login_agent(agent)
  login = VkMusic::Request::Login.new
  login.call(agent)
  login.send_form(ENV['VK_LOGIN'], ENV['VK_PASSWORD'], agent)
end

# Path to file where testing cookies will be stored
AGENT_COOKIES_PATH = 'spec_data/logged_in_agent.cookies'

# @return [Mechanize] logged in Mechanize client.
def logged_in_agent
  agent = Mechanize.new
  scj = saved_cookie_jar
  if scj
    agent.cookie_jar = scj
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

# @return [HTTP::CookieJar?]
def saved_cookie_jar
  return unless File.exist?(AGENT_COOKIES_PATH)

  cookie_jar = HTTP::CookieJar.new
  data = File.read(AGENT_COOKIES_PATH)
  if data.start_with?('{')
    saved_cookie_jar_json(cookie_jar, data)
  else
    saved_cookie_jar_mechanize(cookie_jar)
  end
  return if cookie_jar.empty?

  cookie_jar
rescue StandardError => e
  VkMusic.log.warn('spec') { "Failed to parse saved cookies: #{e}" }
  nil
end

# Loads cookies from JSON data
def saved_cookie_jar_json(cookie_jar, data)
  VkMusic.log.info('spec') { 'Loading JSON cookies' }
  JSON.parse(data).each_pair do |k, v|
    cookie_jar.add(URI('https://m.vk.com'), HTTP::Cookie.new(k, v))
  end
end

# Loads cookies from Mechanize file
def saved_cookie_jar_mechanize(cookie_jar)
  VkMusic.log.info('spec') { 'Loading Mechanize cookies' }
  cookie_jar.load(AGENT_COOKIES_PATH)
end
