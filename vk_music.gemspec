Gem::Specification.new do |s|
  s.name           = "vk_music"
  s.summary        = "Provides interface to work with VK music via HTTP requests"
  s.description    = "Library to work with audios on popular Russian social network vk.com. VK disabled their public API for audios, so it is now necessary to use parsers instead."
  s.version        = "0.0.2"
  s.author         = "Kuznetsov Vladislav"
  s.email          = "fizvlad@mail.ru"
  s.homepage       = "https://github.com/fizvlad/vk-music-rb"
  s.platform       = Gem::Platform::RUBY
  s.required_ruby_version = ">=2.5.1"
  s.files          = Dir[ "lib/**/**", "test/**/**", "LICENSE", "Rakefile", "README.md", "vk_music.gemspec" ]
  s.test_files     = Dir[ "test/test*.rb" ]
  s.has_rdoc       = false
  s.license        = "MIT"
  
  s.add_runtime_dependency "mechanize", "~>2.7"
  s.add_runtime_dependency "duktape",   "~>2.3"
end