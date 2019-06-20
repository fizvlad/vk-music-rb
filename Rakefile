require "io/console"

desc "Build gem file"
task :build do
  puts `gem build vk_music.gemspec`
end

desc "Run tests"
task :test do
  puts "Running tests require login credetionals"
  
  print "Login:    "
  username = STDIN.gets.chomp
  
  print "Password: "
  password = STDIN.noecho(&:gets).chomp
  puts
  
  Dir[ "test/test*.rb" ].each do |file|
    puts "\n\nRunning #{file}:"
    puts `ruby -w #{file} #{username} #{password}`
  end
end