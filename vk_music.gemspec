lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "vk_music/version"

Gem::Specification.new do |spec|
  spec.name          = "vk_music"
  spec.version       = VkMusic::VERSION
  spec.authors       = ["Fizvlad"]
  spec.email         = ["fizvlad@mail.ru"]

  spec.summary       = "Provides interface to work with VK music via HTTP requests"
  spec.description   = "Library to work with audios on popular Russian social network vk.com. VK disabled their public API for audios, so it is now necessary to use parsers instead."
  spec.homepage      = "https://github.com/fizvlad/vk-music-rb"
  spec.license       = "MIT"

  spec.required_ruby_version = ">=2.3.1"


  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/fizvlad/vk-music-rb"
  spec.metadata["changelog_uri"] = "https://github.com/fizvlad/vk-music-rb/releases"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "yard", "~>0.9"
  spec.add_development_dependency "minitest", "~> 5.0"

  spec.add_runtime_dependency "logger", "~>1.4"
  spec.add_runtime_dependency "mechanize", "~>2.7"
  spec.add_runtime_dependency "net-http-persistent", "2.9.4" # Required for mechanize. Future versions cause error.
  spec.add_runtime_dependency "execjs", "~>2.7"
  spec.add_runtime_dependency "json", "~>2.0"
end
