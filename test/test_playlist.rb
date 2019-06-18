require "minitest/autorun"
require_relative "../lib/vk_music.rb"

begin
  CLIENT = VkMusic::Client.new(username: ARGV[0], password: ARGV[1])
rescue VkMusic::LoginError => error
  puts "Unable to login! Please check provided credetionals"
  exit
end

class TestVkMusic < MiniTest::Test

  def test_playlist_1
    pl = CLIENT.get_playlist("https://vk.com/audio?z=audio_playlist-37661843_1/0e420c32c8b69e6637")
    refute_equal(0, pl.length, "This playlist must not be empty")
    assert_instance_of(VkMusic::Audio, pl[0], "Playlist members must be of class Audio")
  end
  
  def test_playlist_2
    pl = CLIENT.get_playlist("https://vk.com/audios437727675?section=playlists&z=audio_playlist437727675_2")
    assert_equal(0, pl.length, "This playlist must be empty")
  end
  
end
