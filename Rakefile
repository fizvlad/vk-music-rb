require "bundler/gem_tasks"
require "rake/testtask"

task :test do
  puts "Running tests require login credetionals (NOTICE: they won't be hidden in anyway)"
  
  print "Login:    "
  username = STDIN.gets.chomp
  
  print "Password: "
  password = STDIN.gets.chomp
  puts
  
  print "Path to SSL certificate (leave empty if there is no troubles with SSL): "
  ssl_cert_path = STDIN.gets.chomp
  puts
  ENV["SSL_CERT_FILE"] = ssl_cert_path unless ssl_cert_path.empty?
  
  Dir[ "test/test_*.rb" ].each do |file|
    puts "\n\nRunning #{file}:"
    ruby "-w #{file} '#{username}' '#{password}'"
  end
end

task :default => :test
