![Gem](https://img.shields.io/gem/v/vk_music) ![GitHub Workflow Status](https://img.shields.io/github/workflow/status/fizvlad/vk-music-rb/Ruby) ![Lines of code](https://img.shields.io/tokei/lines/github/fizvlad/vk-music-rb) ![Gem](https://img.shields.io/gem/dtv/vk_music)

# VkMusic

*vk_music* gem is a library to work with audios on popular Russian social network

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'vk_music'
```

And then execute:
```
$ bundle
```

Or install it using `gem`:

```
$ gem install vk_music
```

## Usage

You can take a look on documentation at [rubydoc](https://www.rubydoc.info/gems/vk_music/).

### Logging in

Firstly, it is required to create new `VkMusic::Client` instance and provide login credentials:

```ruby
client = VkMusic::Client.new(username: "+79991234567", password: "password")
```

### Search

You can search audios using `Client#find`:

```ruby
audios = client.find("Acid Spit - Mega Drive")
```

You can also search for playlists using same method:

```ruby
playlists = client.find("Jazz", type: :playlist)
```

### Playlists

You can load playlist audios with `Client#playlist`

```ruby
playlist = client.playlist(url: "link")
```

### User or group audios

You can load profile audios with `Client#audios`

```ruby
playlist = client.audios(owner_id: 8024985)
```

### Wall audios

You can load audios from profile wall with `Client#wall`

```ruby
playlist = client.wall(owner_id: 8024985)
```

### Audios from post

You can load up to 10 audios attached to some post. Those audios will be returned as array:

```ruby
audios = client.post(url: "link")
```

### Artist audios

You can get up to 50 top audios of particular artist:

```ruby
audios = client.artist(url: "link")
```

### Getting audio URL

To get audio URL you should go through following chain:
1. Get audio ID
2. Get audio encrypted URL
3. Get audio decrypted URL

Usually most of audios already go with ID. Getting encrypted URL requires additional request to web, so it is performed with `Client#update_urls`, which will mutate provided array of audios:

```ruby
client.update_urls(audios_array)
```

After this you can get decrypted URL using `Audio#url`

## Development

Feel free to add features. However, please make sure all your code is covered with tests.

### Testing

This gem uses `rspec` and `vcr` for easy testing. *Be careful*, though, running `rspec` in clean repo may result in lot of requests to web and rate limiting or ban

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fizvlad/vk-music-rb/issues.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
