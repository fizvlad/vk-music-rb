require "minitest/autorun"
require_relative "../lib/vk_music.rb"

class Example < MiniTest::Test
  def test_bad_data
    assert_raises(VkMusic::LoginError) {
      client = VkMusic::Client.new(username: "login", password: "password")
    }
  end
  
  # TODO: any way to test correct login?
end
