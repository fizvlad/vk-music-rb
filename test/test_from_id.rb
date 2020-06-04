require_relative "helper"

begin
  CLIENT = VkMusic::Client.new(username: ARGV[0], password: ARGV[1])

  audio = CLIENT.audios(owner_id: 8024985).first
  ID = audio.id
  OWNER_ID = audio.owner_id
  AH1 = audio.secret_1
  AH2 = audio.secret_2

  ID_STRING = "#{OWNER_ID}_#{ID}_#{AH1}_#{AH2}"
  ID_ARRAY_1 = [OWNER_ID.to_i, ID.to_i, AH1, AH2]
  ID_ARRAY_2 = [OWNER_ID.to_s, ID.to_s, AH1, AH2]
rescue VkMusic::LoginError
  puts "Unable to login! Please check provided credetionals"
  exit
end

class TestVkMusic < MiniTest::Test

  def test_one_id
    results = CLIENT.from_id([
      ID_STRING
    ])
    refute_empty(results, "There must be some music")
    assert_instance_of(Array, results, "Result must be an Array")
    assert_instance_of(VkMusic::Audio, results[0], "Results of search must be of class Audio")
    refute_nil(results[0].url, "Audio must have download url")
  end

  def test_doubled_id
    results = CLIENT.from_id([
      ID_STRING,
      ID_ARRAY_1
    ])
    assert_equal(2, results.size, "There must be equal size result")
    refute_nil(results[0].url, "Audio must have download url")
    refute_nil(results[1].url, "Audio must have download url")
  end

  def test_two_id
    results = CLIENT.from_id([
      ID_STRING,
      ID_ARRAY_2
    ])
    assert_equal(2, results.size, "There must be 2 audios")
    refute_nil(results[0].url, "Audio must have download url")
    refute_nil(results[1].url, "Audio must have download url")
  end

  # TODO: test with many audios

  def test_bad_last
    assert_raises(VkMusic::ParseError) do
      CLIENT.from_id([
        ID_ARRAY_2,
        ["42", "1337", "aaaa", "aaaaaa"]
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
      ID_ARRAY_2
    ]
    CLIENT.from_id(init)
    assert_instance_of(Array, init[0], "Function must not change initial array")
  end

end
