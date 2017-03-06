require 'fileutils'

sources_file = File.join(File.expand_path(File.dirname(__FILE__)), 'noosfero-jessie-test.list')
repo_url = 'http://download.noosfero.org/debian/jessie-test'
needs_update = false

unless system "sudo grep -q '#{repo_url}' /etc/apt/sources.list /etc/apt/sources.list.d/*"
  print 'To install this plugin, you must add noosfero-jessie-test to you sources list, Do you want to proceed? (yes/no): '
  answer = gets.strip.downcase
  exit(1) unless answer == 'yes' || answer == 'y'

  puts '>>> Adding Noosfero jessie-test to your sources...'
  FileUtils.cp(sources_file, '/etc/apt/sources.list.d/')
  needs_update = true
end

unless system 'dpkg -s ruby-axlsx'
  puts '>>> Installing ruby-axlsx...'
  system 'sudo apt-get update' if needs_update
  unless system 'sudo apt-get install -y ruby-axlsx'
    exit $?.exitstatus
  end
end

system 'script/noosfero-plugins -q enable products delivery'
exit $?.exitstatus
