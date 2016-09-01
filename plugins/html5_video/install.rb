require 'fileutils'

backports_file = File.join(File.expand_path(File.dirname(__FILE__)), 'jessie-backports.list')
unless File.exist?(backports_file)
  FileUtils.cp(backports_file, '/etc/apt/sources.list.d/')
end

update = false

unless system 'dpkg -s wget'
  system 'sudo apt-get update'
  update = true
  unless system 'sudo apt-get install -y wget'
    exit $?.exitstatus
  end
end


unless system 'dpkg -s ffmpeg'
  system 'sudo apt-get update' unless update
  unless system 'sudo apt-get install -y -t jessie-backports ffmpeg'
    exit $?.exitstatus
  end
end

