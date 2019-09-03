require "minitest/autorun"
require_relative "../lib/vk_music.rb"

begin
  CLIENT = VkMusic::Client.new(username: ARGV[0], password: ARGV[1])
rescue VkMusic::LoginError
  puts "Unable to login! Please check provided credetionals"
  exit
end

class TestVkMusic < MiniTest::Test

  def test_one_id
    results = CLIENT.from_id([
      "2000202604_456242434_32f6f3df29dc8e9c71_82fbafed15ef65709b"
    ])
    refute_empty(results, "There must be some music")
    assert_instance_of(Array, results, "Result must be an Array")
    assert_instance_of(VkMusic::Audio, results[0], "Results of search must be of class Audio")
    refute_nil(results[0].url, "Audio must have download url")
  end

  def test_two_id
    results = CLIENT.from_id([
      "2000202604_456242434_32f6f3df29dc8e9c71_82fbafed15ef65709b",
      ["2000023175", "456242595", "addd832f78d7c61b6d", "b6b14f49280d4d55f0"]
    ])
    assert_equal(2, results.size, "There must be 2 audios")
    refute_nil(results[1].url, "Audio must have download url")
  end

  # TODO: test with many audios

  def test_bad_last
    assert_raises(VkMusic::ParseError) do
      CLIENT.from_id([
        "2000202604_456242434_32f6f3df29dc8e9c71_82fbafed15ef65709b",
        ["42", "1337", "aaaa", "aaaaaa"]
      ])
    end
  end

  def test_bad_first
    assert_raises(VkMusic::ParseError) do
      CLIENT.from_id([
        ["42", "1337", "aaaa", "aaaaaa"],
        "2000202604_456242434_32f6f3df29dc8e9c71_82fbafed15ef65709b"
      ])
    end
  end

  def test_bad_all
    assert_raises(VkMusic::ParseError) do
      CLIENT.from_id([
        ["42", "1337", "aaaa", "aaaaaa"],
        "123_123_123_123"
      ])
    end
  end

  def test_initial_array_not_changed
    init = [
      ["2000023175", "456242595", "addd832f78d7c61b6d", "b6b14f49280d4d55f0"]
    ]
    CLIENT.from_id(init)
    assert_instance_of(Array, init[0], "Function must not change initial array")
  end
  
end
