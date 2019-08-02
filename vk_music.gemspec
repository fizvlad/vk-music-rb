Gem::Specification.new do |s|
  s.name           = "vk_music"
  s.summary        = "Provides interface to work with VK music via HTTP requests"
  s.description    = "Library to work with audios on popular Russian social network vk.com. VK disabled their public API for audios, so it is now necessary to use parsers instead."
  s.version        = "1.1.1"
  s.author         = "Kuznetsov Vladislav"
  s.email          = "fizvlad@mail.ru"
  s.homepage       = "https://github.com/fizvlad/vk-music-rb"
  s.platform       = Gem::Platform::RUBY
  s.required_ruby_version = ">=2.3.1"
  s.files          = Dir[ "lib/**/**", "test/**/**", "LICENSE", "Rakefile", "README.md", "vk_music.gemspec" ]
  s.test_files     = Dir[ "test/test*.rb" ]
  s.license        = "MIT"
  
  s.add_runtime_dependency "mechanize", "~>2.7"
  s.add_runtime_dependency "net-http-persistent", "2.9.4" # Required for mechanize. Future versions cause error.
  s.add_runtime_dependency "execjs",    "~>2.7"
  s.add_runtime_dependency "json",      "~>2.0"
  s.add_runtime_dependency "rake",      "~>12.3"
end
