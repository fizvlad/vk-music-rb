require "minitest/autorun"
require_relative "../lib/vk_music.rb"

begin
  CLIENT = VkMusic::Client.new(username: ARGV[0], password: ARGV[1])
rescue VkMusic::LoginError
  puts "Unable to login! Please check provided credetionals"
  exit
end

class TestVkMusic < MiniTest::Test

  def test_playlist_small_1
    pl = CLIENT.playlist("https://vk.com/audio?z=audio_playlist-37661843_1/0e420c32c8b69e6637")
    refute_empty(pl, "This playlist must not be empty")
    assert_instance_of(VkMusic::Audio, pl[0], "Playlist members must be of class Audio")
    refute_empty(pl[0].url, "Audio must have download url")
    refute_empty(pl[-1].url, "Audio must have download url")
  end

  def test_playlist_small_2
    pl = CLIENT.playlist("https://vk.com/music/album/-121725065_1")
    refute_empty(pl, "This playlist must not be empty")
    assert_instance_of(VkMusic::Audio, pl[0], "Playlist members must be of class Audio")
    refute_empty(pl[0].url, "Audio must have download url")
    refute_empty(pl[-1].url, "Audio must have download url")
  end

  def test_big_url
    pl = CLIENT.playlist("https://m.vk.com/audio?act=audio_playlist256492540_83617715&from=search_owned_playlist&access_hash=b8d408241bcfb60583&back_url=%2Faudios-39786657%3Fq%3Dmashup%26tab%3Downed&back_hash=76ef9186ac6f248a27")
    refute_empty(pl, "This playlist must not be empty")
    assert_instance_of(VkMusic::Audio, pl[0], "Playlist members must be of class Audio")
  end

  def test_playlist_small_with_options
    pl = CLIENT.playlist(owner_id: -37661843, playlist_id: 1, access_hash: "0e420c32c8b69e6637", with_url: false)
    refute_empty(pl, "This playlist must not be empty")
    assert_instance_of(VkMusic::Audio, pl[0], "Playlist members must be of class Audio")
    assert(pl[0].url_accessable?, "Audio must have all the data needed for getting download URL")
    assert(pl[-1].url_accessable?, "Audio must have all the data needed for getting download URL")
  end
  
  def test_playlist_large
    pl = CLIENT.playlist("https://vk.com/audio?z=audio_playlist121570739_7")
    refute_empty(pl, "This playlist must not be empty")
    refute_empty(pl[0].url, "Audio must have download url")
    refute_empty(pl[-1].url, "Audio must have download url")
  end
  
  def test_playlist_empty
    pl = CLIENT.playlist("https://vk.com/audios437727675?section=playlists&z=audio_playlist437727675_2")
    assert_empty(pl, "This playlist must be empty")
  end
  
  def test_playlist_dont_exist    
    assert_raises(VkMusic::ParseError) do
      CLIENT.playlist("https://m.vk.com/audio?act=audio_playlist437727675_300")
    end
    assert_raises(VkMusic::ParseError) do
      CLIENT.playlist("https://m.vk.com/audio?act=audio_playlist437727675_300", with_url: false)
    end
  end
  
  def test_playlist_no_access    
    assert_raises(VkMusic::ParseError) do
      CLIENT.playlist("https://m.vk.com/audio?act=audio_playlist1_1")
    end
    assert_raises(VkMusic::ParseError) do
      CLIENT.playlist("https://m.vk.com/audio?act=audio_playlist1_1", with_url: false)
    end
  end
  
  def test_playlist_with_upper_limit
    pl = CLIENT.playlist("https://vk.com/audio?z=audio_playlist-66223223_77503494", up_to: 105, with_url: true)
    assert_equal(105, pl.length, "Size of result must match given limit") # This playlist got more audios
    refute_empty(pl[0].url, "Audio must have download url")
    refute_empty(pl[-1].url, "Audio must have download url")
  end

  def test_playlist_without_url
    pl = CLIENT.playlist("https://vk.com/audio?z=audio_playlist121570739_7", with_url: false)
    assert(pl[0].url_accessable?, "Audio must have all the data needed for getting download URL")
    assert(pl[-1].url_accessable?, "Audio must have all the data needed for getting download URL")
  end
  
  def test_bad_url
    assert_raises(ArgumentError) do
      CLIENT.playlist("ae")
    end
    assert_raises(ArgumentError) do
      CLIENT.playlist("ae", with_url: false)
    end
  end

  def test_bad_arg
    assert_raises(ArgumentError) do
      CLIENT.playlist("ae", "bc")
    end
  end
  
end
