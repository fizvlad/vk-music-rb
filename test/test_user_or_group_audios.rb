require "minitest/autorun"
require_relative "../lib/vk_music.rb"

begin
  CLIENT = VkMusic::Client.new(username: ARGV[0], password: ARGV[1])
rescue VkMusic::LoginError
  puts "Unable to login! Please check provided credetionals"
  exit
end

class TestVkMusic < MiniTest::Test

  def test_user
    pl = CLIENT.get_audios("8024985")
    assert_instance_of(VkMusic::Playlist, pl, "User audios must be returned as a playlist (cause it is actually is playlist)")
    refute_empty(pl, "There must be some music")
    assert_instance_of(VkMusic::Audio, pl[0], "Results must be of class Audio")
    refute_empty(pl[0].url, "Audio must have download url")
  end

  def test_incorrect_id
    assert_raises(VkMusic::AudiosParseError) do
      CLIENT.get_audios("42424242424242424242424242")
    end
  end
  
  def test_user_with_locked_audios
    assert_raises(VkMusic::AudiosParseError) do
      CLIENT.get_audios("152719703")
    end
  end
  
  def test_user_with_empty_audios
    pl = CLIENT.get_audios("437727675")
    assert_empty(pl, "This user got no audios")
  end
  
  def test_group
    pl = CLIENT.get_audios("-4790861")
    refute_empty(pl, "There must be some music")
    refute_empty(pl[0].url, "Audio must have download url")
  end
  
  def test_group_with_upper_limit_1
    pl = CLIENT.get_audios("-72589944", 10)
    assert_equal(10, pl.length, "Size of result must match given limit") # This group got more audios
    refute_empty(pl[0].url, "Audio must have download url")
  end
  
  def test_group_with_upper_limit_2
    pl = CLIENT.get_audios("-72589944", 200)
    assert(pl.size <= 200, "Size of result must match given limit")
    refute_empty(pl[0].url, "Audio must have download url")
    refute_empty(pl[-1].url, "Audio must have download url")
  end
  
  def test_group_with_no_audios
    pl = CLIENT.get_audios("-52298374")
    assert_empty(pl, "This group got no audios")
  end
  
end
