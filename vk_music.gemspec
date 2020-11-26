# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vk_music/version'

Gem::Specification.new do |spec|
  spec.name          = 'vk_music'
  spec.version       = VkMusic::VERSION
  spec.authors       = ['Fizvlad']
  spec.email         = ['fizvlad@mail.ru']

  spec.summary       = 'A library to work with audios on popular Russian social network'
  spec.description   = 'A library to work with audios on popular Russian social network'
  spec.homepage      = 'https://github.com/fizvlad/vk-music-rb'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>=2.7.1'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/fizvlad/vk-music-rb'
  spec.metadata['changelog_uri'] = 'https://github.com/fizvlad/vk-music-rb/releases'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']

  spec.add_runtime_dependency('execjs', '~> 2.7')
  spec.add_runtime_dependency('json', '~> 2.3')
  spec.add_runtime_dependency('logger', '~> 1.4')
  spec.add_runtime_dependency('mechanize', '~> 2.7')
  spec.add_runtime_dependency('net-http-persistent', '2.9.4')
end
