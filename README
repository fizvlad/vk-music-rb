# vk_music

*vk_music* gem is a library to work with audios on popular Russian social network [vk.com](https://www.vk.com "vk.com"). VK disabled their public API for audios, so it is now necessary to use parsers instead.


## Dependencies

* [mechanize](https://github.com/sparklemotion/mechanize "mechanize") (interaction with website)
* [duktape](https://github.com/judofyr/duktape.rb "duktape") (JS interpreter)


## Installation

You can build gem with following command:
``
gem build vk_music.gemspec
``

Install gem with
``
gem install vk_music-0.0.1.gem
``


## Usage

### Logging in
Firstly, it is required to create new *VkMusic::Client* and provide login credentials:
```
client = VkMusic::Client.new(username: "+71234567890", password: "password")
```

### Searching for audios
You can search audios by name with following method:
```
audios = client.find_audio("Acid Spit - Mega Drive")
puts audios[0]     # Basic information about audio
puts audios[0].url # Download this audio using its URL
```

### Parsing playlists
You can load all the audios from playlist using following method:
```
playlist = client.get_playlist("https://vk.com/audio?z=audio_playlist-37661843_1/0e420c32c8b69e6637")
```
It is only possible to load up to 100 audios from playlist per request, so you can reduce amount of requests by setting up how many audios from playlist you actually need.
For example, following method will perform only one HTML request:
```
playlist = client.get_playlist("https://vk.com/audio?z=audio_playlist121570739_7", 100)
urls = playlist.map(&:url) # URLs for every audio
```
