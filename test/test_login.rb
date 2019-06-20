require "minitest/autorun"
require_relative "../lib/vk_music.rb"

class TestVkMusic < MiniTest::Test

  def test_bad_data
    assert_raises(VkMusic::LoginError) do
      VkMusic::Client.new(username: "login", password: "password")
    end
  end
  
  def test_empty_data
    assert_raises(VkMusic::LoginError) do
      VkMusic::Client.new(username: "", password: "")
    end
  end
  
  def test_good_data
    begin
      client = VkMusic::Client.new(username: ARGV[0], password: ARGV[1])
    rescue VkMusic::LoginError
      puts "Unable to login! Please check provided credetionals"
    end
    refute_nil(client, "Client not defined")
    refute_nil(client.name, "User name undefined")
    refute_nil(client.id, "User id undefined")
  end
  
end
