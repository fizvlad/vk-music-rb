require_relative "helper"

begin
  CLIENT = VkMusic::Client.new(username: ARGV[0], password: ARGV[1])
rescue VkMusic::LoginError
  puts "Unable to login! Please check provided credetionals"
  exit
end

class TestVkMusic < MiniTest::Test

  def test_url_1
    arr = CLIENT.wall("https://vk.com/mashup", up_to: 10)
    assert_instance_of(Array, arr, "Result must be an array")
    refute_empty(arr, "There must be something on the wall")
    assert_equal(10, arr.size, "Size must be exactly the given")
    assert_instance_of(VkMusic::Audio, arr[0], "Playlist members must be of class Audio")
    refute_empty(arr[0].url, "Audio must have download url")
    refute_empty(arr[-1].url, "Audio must have download url")
  end

  def test_url_2
    arr = CLIENT.wall("https://vk.com/mashup", with_url: false)
    refute_empty(arr, "There must be something on the wall")
    assert_instance_of(VkMusic::Audio, arr[0], "Playlist members must be of class Audio")
    assert(arr[0].url_accessable?, "Audio must have accessable URL")
    assert(arr[-1].url_accessable?, "Audio must have accessable URL")
  end

  def test_ids
    arr = CLIENT.wall(owner_id: -39786657, post_id: 204102, with_url: false)
    refute_empty(arr, "There must be something on the wall")
    assert_instance_of(VkMusic::Audio, arr[0], "Playlist members must be of class Audio")
    assert(arr[0].url_accessable?, "Audio must have accessable URL")
    assert(arr[-1].url_accessable?, "Audio must have accessable URL")
  end

  def test_empty_wall
    arr = CLIENT.wall("https://vk.com/club185224844")
    assert_empty(arr, "This wall is empty")
  end

  def test_bad_url
    assert_raises(VkMusic::ParseError) do
      CLIENT.wall("abc")
    end
  end

  def test_not_accessable_page
    assert_raises(VkMusic::ParseError) do
      CLIENT.wall("https://vk.com/club2")
    end
  end
  
end
