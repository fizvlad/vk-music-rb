require "minitest/autorun"
require_relative "../lib/vk_music.rb"

begin
  CLIENT = VkMusic::Client.new(username: ARGV[0], password: ARGV[1])
rescue VkMusic::LoginError => error
  puts "Unable to login! Please check provided credetionals"
  exit
end

class TestVkMusic < MiniTest::Test

  def test_playlist_small
    pl = CLIENT.get_playlist("https://vk.com/audio?z=audio_playlist-37661843_1/0e420c32c8b69e6637")
    refute_empty(pl, "This playlist must not be empty")
    assert_instance_of(VkMusic::Audio, pl[0], "Playlist members must be of class Audio")
    refute_empty(pl[0].url, "Audio must have download url")
    refute_empty(pl[-1].url, "Audio must have download url")
  end
  
  def test_playlist_large
    pl = CLIENT.get_playlist("https://vk.com/audio?z=audio_playlist121570739_7")
    refute_empty(pl, "This playlist must not be empty")
    refute_empty(pl[0].url, "Audio must have download url")
    refute_empty(pl[-1].url, "Audio must have download url")
  end
  
  def test_playlist_empty
    pl = CLIENT.get_playlist("https://vk.com/audios437727675?section=playlists&z=audio_playlist437727675_2")
    assert_empty(pl, "This playlist must be empty")
  end
  
  def test_playlist_dont_exist    
    assert_raises(VkMusic::PlaylistParseError) do
      pl = CLIENT.get_playlist("https://m.vk.com/audio?act=audio_playlist437727675_300")
    end
  end
  
  def test_playlist_no_access    
    assert_raises(VkMusic::PlaylistParseError) do
      pl = CLIENT.get_playlist("https://m.vk.com/audio?act=audio_playlist1_1")
    end
  end
  
  def test_playlist_with_upper_limit
    pl = CLIENT.get_playlist("https://vk.com/audio?z=audio_playlist121570739_7", 113)
    assert_equal(113, pl.length, "Size of result must match given limit") # This playlist got more audios
    refute_empty(pl[0].url, "Audio must have download url")
    refute_empty(pl[-1].url, "Audio must have download url")
  end
  
end
