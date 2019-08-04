desc "Create documentation"
task :doc do
  puts `yardoc`
end

desc "Build gem file"
task :build do
  puts `gem build vk_music.gemspec`
end

desc "Uninstall gem"
task :uninstall do
  puts `gem uninstall vk_music`
end

desc "Build and install gem"
task :install_local => :build do
  puts `gem install ./vk_music-*.gem`
end

desc "Run tests"
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
  
  Dir[ "test/test*.rb" ].each do |file|
    puts "\n\nRunning #{file}:"
    ruby "-w #{file} '#{username}' '#{password}'"
  end
end
