require "minitest/autorun"
require_relative "../lib/vk_music.rb"

begin
  CLIENT = VkMusic::Client.new(username: ARGV[0], password: ARGV[1])
rescue VkMusic::LoginError
  puts "Unable to login! Please check provided credetionals"
  exit
end

class TestVkMusic < MiniTest::Test

  def test_single_audio
    audios = CLIENT.post("https://vk.com/wall-184089233_6")
    assert_instance_of(Array, audios, "Result must be of class Array")
    assert_equal(1, audios.length, "This post got 1 attached audio")
    assert_instance_of(VkMusic::Audio, audios[0], "Array must consist of class Audio")
    refute_empty(audios[0].url, "Audio must have download url")
  end

  def test_single_audio_with_options
    audios = CLIENT.post(owner_id: -184089233, post_id: 6)
    assert_instance_of(Array, audios, "Result must be of class Array")
    assert_equal(1, audios.length, "This post got 1 attached audio")
    assert_instance_of(VkMusic::Audio, audios[0], "Array must consist of class Audio")
    refute_empty(audios[0].url, "Audio must have download url")
  end
  
  def test_no_audio
    audios = CLIENT.post("https://vk.com/wall-184089233_2")
    assert_empty(audios, "This post got no attached audio")
  end
  
  def test_url_to_reply
    audios = CLIENT.post("https://m.vk.com/wall-4790861_10108")
    assert_equal(1, audios.length, "Although this link redirects to comment, audios from post must be parsed")
  end
  
  def test_playlist
    audios = CLIENT.post("vk.com/wall-184089233_4")
    assert_empty(audios, "This post got attached playlist but those audios must not be parsed")
  end
  
  def test_comments_with_audios
    audios = CLIENT.post("https://m.vk.com/wall-39786657_189247")
    assert_equal(1, audios.length, "This post got comments with audios but those audios must not be parsed")
  end

  def test_repost_with_no_audios
    audios = CLIENT.post("https://vk.com/wall-184936953_1")
    assert_empty(audios, "This post got no attached audios")
  end

  def test_repost_with_audios
    audios = CLIENT.post("https://vk.com/wall-184936953_2")
    assert_equal(1, audios.length, "This repost got 1 attached audio")
    refute_empty(audios[0].url, "Audio must have download url")
  end
  
  def test_repost_with_playlist
    audios = CLIENT.post("https://vk.com/wall-184936953_3")
    assert_empty(audios, "This post got no attached audios")
  end
  
  def test_bad_url
    assert_raises(ArgumentError) do
      CLIENT.post("ae")
    end
  end
  
  def test_nonexistent_post
    assert_raises(VkMusic::ParseError) do
      CLIENT.post("https://m.vk.com/wall-4790861_1052600000")
    end
  end
  
end
