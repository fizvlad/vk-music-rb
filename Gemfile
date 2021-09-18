# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in vk_music.gemspec
gemspec

group :test, :development do
  # Another debugging console
  gem 'byebug', '~> 11.1'

  # The thing, forcing you to write good code
  gem 'rubocop', '~> 1.21', require: false
  # Guidelines for writing RSpec tests
  gem 'rubocop-rspec', '~> 2.4', require: false
  # Guidelines for Rake tasks
  gem 'rubocop-rake', '~> 0.6', require: false

  # Rake tasks
  gem 'rake', '~> 13.0', require: false

  # Testing
  gem 'rspec', '~> 3.10', require: false

  # Docs
  gem 'yard', '~> 0.9', require: false

  # .env support
  gem 'dotenv', '~> 2.7'

  # Save web requests for fast and reliable testing
  gem 'vcr', '~> 6.0'

  # Stub web requests
  gem 'webmock', '~> 3.14'

  # Test coverage
  gem 'simplecov', '~> 0.21', require: false, group: :test
end
