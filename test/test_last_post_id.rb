require_relative "helper"

begin
  CLIENT = VkMusic::Client.new(username: ARGV[0], password: ARGV[1])
rescue VkMusic::LoginError
  puts "Unable to login! Please check provided credetionals"
  exit
end

class TestVkMusic < MiniTest::Test

  def test_empty_group
    re = CLIENT.last_post_id("https://vk.com/club185224844")
    assert_nil(re, "This group is empty")
  end

  def test_not_empty_group
    re = CLIENT.last_post_id("https://vk.com/mashup")
    refute_nil(re, "This group is not empty")
  end

  def test_not_empty_user
    re = CLIENT.last_post_id("https://vk.com/id1")
    refute_nil(re, "This user got posts")
  end

  def test_bad_url_1
    assert_raises(VkMusic::ParseError) do
      CLIENT.last_post_id("https://vk.com/id10000000000000")
    end
  end

  def test_bad_url_2
    assert_raises(VkMusic::ParseError) do
      CLIENT.last_post_id("https://vk.com/feed")
    end
  end

  def test_bad_url_3
    assert_raises(ArgumentError) do
      CLIENT.last_post_id("https://vk.com/id0")
    end
  end
  
end
