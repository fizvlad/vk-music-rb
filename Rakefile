# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'yard'

RSpec::Core::RakeTask.new(:spec)

RuboCop::RakeTask.new

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
  t.options = ['--any', '--extra', '--opts']
  t.stats_options = ['--list-undoc']
end

task default: %i[rubocop spec yard]

namespace :clear do
  task :cassetes do
    require 'fileutils'

    FileUtils.rm_r Dir.glob('spec/cassetes/*/')
  end

  task :cookies do
    require 'fileutils'

    FileUtils.rm('spec/.cookies')
  end
end
