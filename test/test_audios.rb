require_relative "helper"

begin
  CLIENT = VkMusic::Client.new(username: ARGV[0], password: ARGV[1])
rescue VkMusic::LoginError
  puts "Unable to login! Please check provided credetionals"
  exit
end

class TestVkMusic < MiniTest::Test

  def test_user
    pl = CLIENT.audios(owner_id: 8024985)
    assert_instance_of(VkMusic::Playlist, pl, "User audios must be returned as a playlist (cause it is actually is playlist)")
    refute_empty(pl, "There must be some music")
    assert_instance_of(VkMusic::Audio, pl[0], "Results must be of class Audio")
  end

  def test_user_without_url
    pl = CLIENT.audios(url: "vk.com/id8024985")
    assert_instance_of(VkMusic::Playlist, pl, "User audios must be returned as a playlist (cause it is actually is playlist)")
    refute_empty(pl, "There must be some music")
    assert_instance_of(VkMusic::Audio, pl[0], "Results must be of class Audio")
    assert(pl[0].url_accessable?, "Audio must have all the data needed for getting download URL")
  end

  def test_user_by_audios_url
    pl = CLIENT.audios(url: "https://m.vk.com/audios8024985")
    refute_empty(pl, "This user got audios")
  end

  def test_incorrect_id
    assert_raises(VkMusic::ParseError) do
      CLIENT.audios(owner_id: 42424242424242424242424242)
    end
  end

  def test_user_with_locked_audios
    assert_raises(VkMusic::ParseError) do
      CLIENT.audios(owner_id: 152719703)
    end
  end

  def test_user_with_empty_audios
    pl = CLIENT.audios(owner_id: 437727675)
    assert_empty(pl, "This user got no audios")
  end

  def test_group
    pl = CLIENT.audios(owner_id: -4790861)
    refute_empty(pl, "There must be some music")
  end

  def test_group_with_upper_limit_1
    pl = CLIENT.audios(owner_id: -72589944, up_to: 10)
    assert_equal(10, pl.length, "Size of result must match given limit") # This group got more audios
  end

  def test_group_with_upper_limit_2
    pl = CLIENT.audios(owner_id: -72589944, up_to: 111)
    assert_equal(111, pl.size, "Size of result must match given limit")
  end

  def test_group_with_upper_limit_3
    pl = CLIENT.audios(owner_id: -39786657, up_to: 1000)
    assert_equal(1000, pl.size, "Size of result must match given limit") # NOTICE: VK restrictions
    assert(pl[0].url_accessable?, "Audio must have all the data needed for getting download URL")
    assert(pl[-1].url_accessable?, "Audio must have all the data needed for getting download URL")
  end

  def test_group_with_no_audios
    pl = CLIENT.audios(url: "vk.com/club52298374")
    assert_empty(pl, "This group got no audios")
  end

  def test_group_by_custom_id
    pl = CLIENT.audios(url: "vk.com/mashup")
    refute_empty(pl, "This group got audios")
  end

  def test_group_by_audios_url
    pl = CLIENT.audios(url: "https://m.vk.com/audios-39786657")
    refute_empty(pl, "This group got audios")
  end

end
