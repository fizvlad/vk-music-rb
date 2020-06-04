require_relative "helper"

begin
  CLIENT = VkMusic::Client.new(username: ARGV[0], password: ARGV[1])
rescue VkMusic::LoginError
  puts "Unable to login! Please check provided credetionals"
  exit
end

class TestVkMusic < MiniTest::Test

  def test_playlist_small_1
    pl = CLIENT.playlist(url: "https://vk.com/audio?z=audio_playlist-37661843_1/0e420c32c8b69e6637", use_web: true)
    refute_empty(pl, "This playlist must not be empty")
    assert_instance_of(VkMusic::Audio, pl[0], "Playlist members must be of class Audio")
    refute_empty(pl[0].url, "Audio must have download url")
    refute_empty(pl[-1].url, "Audio must have download url")
  end

  def test_playlist_small_2
    pl = CLIENT.playlist(url: "https://vk.com/music/album/19198851_39318804_6c2b34085c37213dfb", use_web: true)
    refute_empty(pl, "This playlist must not be empty")
    assert_instance_of(VkMusic::Audio, pl[0], "Playlist members must be of class Audio")
    refute_empty(pl[0].url, "Audio must have download url")
    refute_empty(pl[-1].url, "Audio must have download url")
  end

  def test_playlist_small_3
    pl = CLIENT.playlist(url: "https://vk.com/music/album/-2000637322_637322_e677ea2eab62dc17a8", use_web: true)
    refute_empty(pl, "This playlist must not be empty")
    assert_instance_of(VkMusic::Audio, pl[0], "Playlist members must be of class Audio")
    refute_empty(pl[0].url, "Audio must have download url")
    refute_empty(pl[-1].url, "Audio must have download url")
  end

  def test_big_url
    pl = CLIENT.playlist(url: "https://m.vk.com/audio?act=audio_playlist256492540_83617715&from=search_owned_playlist&access_hash=b8d408241bcfb60583&back_url=%2Faudios-39786657%3Fq%3Dmashup%26tab%3Downed&back_hash=76ef9186ac6f248a27")
    refute_empty(pl, "This playlist must not be empty")
    assert_instance_of(VkMusic::Audio, pl[0], "Playlist members must be of class Audio")
  end

  def test_playlist_small_with_options
    pl = CLIENT.playlist(owner_id: -37661843, playlist_id: 1, access_hash: "0e420c32c8b69e6637", use_web: false)
    refute_empty(pl, "This playlist must not be empty")
    assert_instance_of(VkMusic::Audio, pl[0], "Playlist members must be of class Audio")
    assert(pl[0].url_accessable?, "Audio must have all the data needed for getting download URL")
    assert(pl[-1].url_accessable?, "Audio must have all the data needed for getting download URL")
  end

  def test_playlist_large
    pl = CLIENT.playlist(url: "https://vk.com/music/playlist/-137903314_248", use_web: false)
    refute_empty(pl, "This playlist must not be empty")
    assert(pl.size > 200, "This playlist got more than 200 audios")
    assert(pl[101].url_accessable?, "Audio must have all the data needed for getting download URL")
    assert(pl[-1].url_accessable?, "Audio must have all the data needed for getting download URL")
  end

  def test_playlist_empty
    pl = CLIENT.playlist(url: "https://vk.com/audios437727675?section=playlists&z=audio_playlist437727675_2")
    assert_empty(pl, "This playlist must be empty")
  end

  def test_playlist_dont_exist
    assert_raises(VkMusic::ParseError) do
      CLIENT.playlist(url: "https://m.vk.com/audio?act=audio_playlist437727675_300", use_web: true)
    end
    assert_raises(VkMusic::ParseError) do
      CLIENT.playlist(url: "https://m.vk.com/audio?act=audio_playlist437727675_300", use_web: false)
    end
  end

  def test_playlist_no_access
    assert_raises(VkMusic::ParseError) do
      CLIENT.playlist(url: "https://m.vk.com/audio?act=audio_playlist1_1", use_web: true)
    end
    assert_raises(VkMusic::ParseError) do
      CLIENT.playlist(url: "https://m.vk.com/audio?act=audio_playlist1_1", use_web: false)
    end
  end

  def test_playlist_with_upper_limit
    pl = CLIENT.playlist(url:"https://vk.com/audio?z=audio_playlist-66223223_77503494", up_to: 105, use_web: true)
    assert_equal(105, pl.length, "Size of result must match given limit") # This playlist got more audios
    refute_empty(pl[0].url, "Audio must have download url")
    refute_empty(pl[-1].url, "Audio must have download url")
  end

  def test_playlist_not_web
    pl = CLIENT.playlist(url: "https://vk.com/audio?z=audio_playlist121570739_7", use_web: false)
    assert(pl[0].url_accessable?, "Audio must have all the data needed for getting download URL")
    assert(pl[-1].url_accessable?, "Audio must have all the data needed for getting download URL")
  end

  def test_bad_url
    assert_raises(ArgumentError) do
      CLIENT.playlist("ae", use_web: true)
    end
    assert_raises(ArgumentError) do
      CLIENT.playlist("ae", use_web: false)
    end
  end

  def test_bad_arg
    assert_raises(ArgumentError) do
      CLIENT.playlist("ae", "bc")
    end
  end

end
