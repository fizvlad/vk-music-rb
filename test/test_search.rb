require "minitest/autorun"
require_relative "../lib/vk_music.rb"

begin
  CLIENT = VkMusic::Client.new(username: ARGV[0], password: ARGV[1])
rescue VkMusic::LoginError => error
  puts "Unable to login! Please check provided credetionals"
  exit
end

class TestVkMusic < MiniTest::Test

  def test_search
    results = CLIENT.find_audio("Rick Astley")
    refute_empty(results, "There must be some music of Rick Astley")
    assert_instance_of(VkMusic::Audio, results[0], "Results of search must be of class Audio")
    refute_empty(results[0].url, "Audio must have download url")
  end
  
  def test_search_no_query
    results = CLIENT.find_audio("")
    assert_empty(results, "There must be no results for empty query")
  end
  
  def test_search_no_results
    results = CLIENT.find_audio("I'm pretty sure no one ever would name a song like this 282E8EE")
    assert_empty(results, "There must be no results for such query")
  end
  
end
