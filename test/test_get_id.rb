require "minitest/autorun"
require_relative "../lib/vk_music.rb"

begin
  CLIENT = VkMusic::Client.new(username: ARGV[0], password: ARGV[1])
rescue VkMusic::LoginError
  puts "Unable to login! Please check provided credetionals"
  exit
end

class TestVkMusic < MiniTest::Test

  def test_user_link_with_id
    id = CLIENT.get_id("https://vk.com/id51842614")
    assert_equal("51842614", id, "Ids don't match")
  end
  
  def test_user_custom_link
    id = CLIENT.get_id("https://vk.com/kopatych56")
    assert_equal("51842614", id, "Ids don't match")
  end
  
  def test_user_custom
    id = CLIENT.get_id("kopatych56")
    assert_equal("51842614", id, "Ids don't match")
  end
  
  def test_user_id
    id = CLIENT.get_id("51842614")
    assert_equal("51842614", id, "Ids don't match")
  end  
  
  def test_user_id_with_prefix
    id = CLIENT.get_id("id51842614")
    assert_equal("51842614", id, "Ids don't match")
  end
  
  
  def test_group_link_with_id
    id = CLIENT.get_id("https://vk.com/public39786657")
    assert_equal("-39786657", id, "Ids don't match")
  end
  
  def test_group_custom_link
    id = CLIENT.get_id("https://vk.com/mashup")
    assert_equal("-39786657", id, "Ids don't match")
  end
  
  def test_group_custom
    id = CLIENT.get_id("mashup")
    assert_equal("-39786657", id, "Ids don't match")
  end
  
  def test_group_id
    id = CLIENT.get_id("-39786657")
    assert_equal("-39786657", id, "Ids don't match")
  end
  
  def test_group_id_with_prefix
    id = CLIENT.get_id("public39786657")
    assert_equal("-39786657", id, "Ids don't match")
  end
  
  
  def test_user_deleted
    id = CLIENT.get_id("https://vk.com/id245722576")
    assert_equal("245722576", id, "Ids don't match")
  end
  
  def test_user_no_photos
    id = CLIENT.get_id("drop_the_treble")
    assert_equal("437727675", id, "Ids don't match")
  end
  
  def test_user_private
    id = CLIENT.get_id("poppingeyesocketcherry") # I hope this guy won't change his custom
    assert_equal("300415", id, "Ids don't match")
  end
  
  def test_group_no_photos
    id = CLIENT.get_id("vk.com/opentestroom")
    assert_equal("-184089233", id, "Ids don't match")
  end
  
  def test_bad_url
    assert_raises(VkMusic::IdParseError) do
      CLIENT.get_id("https://vk.com/feed")
    end
  end
  
  def test_bad_custom
    assert_raises(VkMusic::IdParseError) do
      CLIENT.get_id("a")
    end
  end
  
  def test_empty
    assert_raises(VkMusic::IdParseError) do
      CLIENT.get_id("")
    end
  end
  
end
