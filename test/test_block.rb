require_relative "helper"

begin
  CLIENT = VkMusic::Client.new(username: ARGV[0], password: ARGV[1])
rescue VkMusic::LoginError
  puts "Unable to login! Please check provided credetionals"
  exit
end

class TestVkMusic < MiniTest::Test

  def test_chart
    results = CLIENT.block(block_id: "PUlQVA8GR0R3W0tMF2tTRGpJUVQPGVpVcVhfRgIAWkpkXktMF2tYUWRHS0IXDlpKZFpcVA8FFg")
    refute_empty(results, "There must be some music in charts")
    assert_instance_of(VkMusic::Audio, results[0], "Results must be of class Audio")
    assert(results[0].url_accessable?, "Audio must be accessable")
  end

  def test_novelty
    results = CLIENT.block(block_id: "PUlQVA8GR0R3W0tMF2teRGpJUVQPGVpfdF1YRwMGXUpkXktMF2tYUWRHS0IXDlpKZFpcVA8FFg")
    refute_empty(results, "There must be some music in charts")
    assert_instance_of(VkMusic::Audio, results[0], "Results must be of class Audio")
    assert(results[0].url_accessable?, "Audio must be accessable")
  end

  def test_recommedations
    results = CLIENT.block(block_id: "PUldVA8FR0RzSVNUR1EICSsYNgRQVwQLNTQNE0FVAgpkR0tPFw5aSmRTS0wBB1xRdFxfQQBJ")
    refute_empty(results, "There must be some music in charts")
    assert_instance_of(VkMusic::Audio, results[0], "Results must be of class Audio")
    assert(results[0].url_accessable?, "Audio must be accessable")
  end

  def test_url_1
    results = CLIENT.block(url: "https://vk.com/audio?section=recoms_block&type=PUlQVA8GR0R3W0tMF2tTRGpJUVQPGVpVcVhfRgIAWkpkXktMF2tYUWRHS0IXDlpKZFpcVA8FFg")
    refute_empty(results, "There must be some music in charts")
    assert_instance_of(VkMusic::Audio, results[0], "Results must be of class Audio")
    assert(results[0].url_accessable?, "Audio must be accessable")
  end

  def test_url_2
    results = CLIENT.block(url: "https://m.vk.com/audio?act=block&block=PUlQVA8GR0R3W0tMF2teRGpJUVQPGVpfdF1YRwMGXUpkXktMF2tYUWRHS0IXDlpKZFpcVA8FFg")
    refute_empty(results, "There must be some music in charts")
    assert_instance_of(VkMusic::Audio, results[0], "Results must be of class Audio")
    assert(results[0].url_accessable?, "Audio must be accessable")
  end

end
