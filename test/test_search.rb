require "minitest/autorun"
require_relative "../lib/vk_music.rb"

begin
  CLIENT = VkMusic::Client.new(username: ARGV[0], password: ARGV[1])
rescue VkMusic::LoginError => error
  puts "Unable to login! Please check provided credetionals"
  exit
end

class TestVkMusic < MiniTest::Test

  def test_search_1
    results = CLIENT.find_audio("Rick Astley")
    refute_empty(results, "There must be some music of Rick Astley")
    assert_instance_of(VkMusic::Audio, results[0], "Results of search must be of class Audio")
  end
  
end
