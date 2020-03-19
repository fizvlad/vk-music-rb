# VkMusic

*vk_music* gem is a library to work with audios on popular Russian social network [vk.com](https://www.vk.com "vk.com"). VK disabled their public API for audios, so it is now necessary to use parsers instead.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'vk_music'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vk_music

## Usage

You can take a look on documentation [here](https://www.rubydoc.info/gems/vk_music/).

### Logging in
Firstly, it is required to create new *VkMusic::Client* and provide login credentials:

```ruby
client = VkMusic::Client.new(username: "+71234567890", password: "password")
```

### Searching for audios
You can search audios by name with following method:

```ruby
audios = client.find("Acid Spit - Mega Drive")
puts audios[0]     # Basic information about audio
puts audios[0].url # URL to access audio. Notice that it is only accessible from your IP
```

### Parsing playlists
You can load all the audios from playlist using following method:

```ruby
playlist = client.playlist(url: "https://vk.com/audio?z=audio_playlist-37661843_1/0e420c32c8b69e6637")
last_audios = playlist.first(10) # => Array<Audio>
client.update_urls(last_audios) # We have to manually retrieve URLs for playlists
urls = last_audios.map(&:url) # URLs for every audio
```

### User or group audios
You can load audios from user or group page. Those audios will be returned as playlist. To do it simply pass user or group id:

```ruby
playlist = client.audios(owner_id: 8024985)
last_audios = playlist.first(10) # => Array<Audio>
client.update_urls(last_audios) # We have to manually retrieve URLs for playlists
urls = last_audios.map(&:url) # URLs for every audio
```
You can set how many audios you actually need as well:

```ruby
user_playlist = client.audios(url: "vk.com/id8024985", up_to: 10)
```

### Audios from post
You can load up to 10 audios attached to some post. Those audios will be returned as array:

```ruby
audios = client.post(url: "https://vk.com/wall-4790861_5453")
urls = audios.map(&:url) # URLs for every audio
```

### Recommended audios and etc
You can load audios from recommended sections, novices and VK charts:

```ruby
audios = client.block(url: "https://m.vk.com/audio?act=block&block=PUlQVA8GR0R3W0tMF2teRGpJUVQPGVpfdF1YRwMGXUpkXktMF2tYUWRHS0IXDlpKZFpcVA8FFg")
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fizvlad/vk-music-rb/issues.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
