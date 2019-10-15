require_relative "helper"

begin
  CLIENT = VkMusic::Client.new(username: ARGV[0], password: ARGV[1])
rescue VkMusic::LoginError
  puts "Unable to login! Please check provided credetionals"
  exit
end

class TestVkMusic < MiniTest::Test

  # NOTICE: This method is indirectly tested in test_post.rb

  def test_simple
    re = CLIENT.attached_audios("https://vk.com/wall-184089233_6").size
    assert_equal(1, re, "This post got only 1 attached audio")
  end

  def test_empty
    re = CLIENT.attached_audios("https://vk.com/wall-184089233_2").size
    assert_equal(0, re, "This post got no attached audios")
  end

  def test_single_audio
    re = CLIENT.attached_audios("https://vk.com/wall-184089233_6").size
    assert_equal(1, re, "This post got only 1 attached audio")
  end

  def test_single_audio_with_options
    re = CLIENT.attached_audios(owner_id: -184089233, post_id: 6).size
    assert_equal(1, re, "This post got only 1 attached audio")
  end
  
  def test_no_audio
    re = CLIENT.attached_audios("https://vk.com/wall-184089233_2").size
    assert_equal(0, re, "This post got no attached audios")
  end
  
  def test_url_to_reply
    re = CLIENT.attached_audios("https://m.vk.com/wall-4790861_10108").size
    assert_equal(1, re, "Although this link redirects to comment, audios from post must be parsed")
  end
  
  def test_playlist
    re = CLIENT.attached_audios("vk.com/wall-184089233_4").size
    assert_equal(0, re, "This post got no attached audios")
  end
  
  def test_comments_with_audios
    re = CLIENT.attached_audios("https://m.vk.com/wall-39786657_189247").size
    assert_equal(1, re, "This post got 1 attached audio")
  end

  def test_repost_with_no_audios
    re = CLIENT.attached_audios("https://vk.com/wall-184936953_1").size
    assert_equal(0, re, "This post got no attached audios")
  end

  def test_repost_with_audios
    re = CLIENT.attached_audios("https://vk.com/wall-184936953_2").size
    assert_equal(1, re, "This post got 1 attached audio")
  end
  
  def test_repost_with_playlist
    re = CLIENT.attached_audios("https://vk.com/wall-184936953_3").size
    assert_equal(0, re, "This post got no attached audios")
  end
  
  def test_bad_url
    assert_raises(ArgumentError) do
      CLIENT.attached_audios("ae")
    end
  end
  
  def test_nonexistent_post
    assert_raises(VkMusic::ParseError) do
      CLIENT.attached_audios("https://m.vk.com/wall-4790861_1052600000")
    end
  end

end
