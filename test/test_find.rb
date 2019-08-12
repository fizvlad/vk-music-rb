require "minitest/autorun"
require_relative "../lib/vk_music.rb"

begin
  CLIENT = VkMusic::Client.new(username: ARGV[0], password: ARGV[1])
rescue VkMusic::LoginError
  puts "Unable to login! Please check provided credetionals"
  exit
end

class TestVkMusic < MiniTest::Test

  def test_find
    results = CLIENT.find("Rick Astley")
    refute_empty(results, "There must be some music of Rick Astley")
    assert_instance_of(VkMusic::Audio, results[0], "Results of search must be of class Audio")
    refute_nil(results[0].url, "Audio must have download url")
  end
  
  def test_find_no_query
    results = CLIENT.find("")
    assert_empty(results, "There must be no results for empty query")
  end
  
  def test_find_no_results
    results = CLIENT.find("I'm pretty sure no one ever would name a song like this 282E8EE")
    assert_empty(results, "There must be no results for such query")
  end

  def test_search_with_hash
    results = CLIENT.search(query: "Sexualizer")
    refute_empty(results, "There must be some good music")
    assert_instance_of(VkMusic::Audio, results[0], "Results of search must be of class Audio")
    refute_nil(results[0].url, "Audio must have download url")
  end

  def test_find_bad_arg
    assert_raises(ArgumentError) do
      CLIENT.search("Good music", query: "or not")
    end
  end

  def test_find_playlist
    results = CLIENT.find("Jazz", type: :playlist)
    puts results # DEBUG
    refute_empty(results, "There must be some playlists with jazz")
    assert_empty(results[0], "Album must be empty")
    refute_equal(0, results[0].real_size, "Album must actually have some audios")
  end

  def test_find_unexisting_playlist
    results = CLIENT.find("I'm pretty sure no one ever would name a playlist like this 282E8EE", type: :playlist)
    assert_empty(results, "There must be no results for such query")
  end
  
end
