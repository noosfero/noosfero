require 'fileutils'

backports_file = File.join(File.expand_path(File.dirname(__FILE__)), 'jessie-backports.list')
unless File.exist?(backports_file)
  FileUtils.cp(backports_file, '/etc/apt/sources.list.d/')
end

unless system 'dpkg -s ffmpeg'
  system 'sudo apt-get update'
  unless system 'sudo apt-get install -y -t jessie-backports ffmpeg'
    exit $?.exitstatus
  end
end

