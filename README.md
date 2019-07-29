# vk_music

*vk_music* gem is a library to work with audios on popular Russian social network [vk.com](https://www.vk.com "vk.com"). VK disabled their public API for audios, so it is now necessary to use parsers instead.


## Dependencies

* [mechanize](https://github.com/sparklemotion/mechanize "mechanize") (interaction with website)
* [execjs](https://github.com/rails/execjs "execjs") (JS interpreter)


## Installation

Simpliest way to install gem:
```
gem install vk_music
```

Alternatively, you can build gem from sources with following command:
```
gem build vk_music.gemspec
```

... and install it:
```
gem install vk_music-*.gem
```


## Usage

### Logging in
Firstly, it is required to create new *VkMusic::Client* and provide login credentials:
```ruby
client = VkMusic::Client.new(username: "+71234567890", password: "password")
```

### Searching for audios
You can search audios by name with following method:
```ruby
audios = client.find_audio("Acid Spit - Mega Drive")
puts audios[0]     # Basic information about audio
puts audios[0].url # URL to access audio. Notice that it is only accessible from your IP
```

### Parsing playlists
You can load all the audios from playlist using following method:
```ruby
playlist = client.get_playlist("https://vk.com/audio?z=audio_playlist-37661843_1/0e420c32c8b69e6637")
```
It is only possible to load up to 100 audios from playlist per request, so you can reduce amount of requests by setting up how many audios from playlist you actually need.
For example, following method will perform only one HTML request:
```ruby
playlist = client.get_playlist("https://vk.com/audio?z=audio_playlist121570739_7", 100)
urls = playlist.map(&:url) # URLs for every audio
```

### User or group audios
You can load first 100 audios from user or group page. Those audios will be returned as playlist. To do it simply pass user or group id:
```ruby
user_playlist = client.get_audios("8024985")
group_playlist = client.get_audios("-4790861") # Group and public id starts with '-'
```
You can set how many audios you actually need as well:
```ruby
user_playlist = client.get_audios("8024985", 10)
```

### Audios from post
You can load up to 10 audios attached to some post. Those audios will be returned as array:
```ruby
audios = client.get_audios_from_post("https://vk.com/wall-4790861_5453")
```
