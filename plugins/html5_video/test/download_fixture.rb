require File.dirname(__FILE__) + '/../../../test/test_helper'

fixture_path = File.dirname(__FILE__) + '/../../../test/fixtures/videos'
Dir.mkdir(fixture_path) unless File.exist?(fixture_path)

base_url = 'http://noosfero.org/pub/Development/HTML5VideoPlugin'

videos = ['old-movie.mpg', 'atropelamento.ogv', 'firebus.3gp']

def shutdown(fixture_path, videos)
  videos.map do |v|
    File.unlink(fixture_path+'/'+v) if File.exists?(fixture_path+'/'+v)
  end
  exit 1
end

signals = %w{EXIT HUP INT QUIT TERM}
signals.map{|s| Signal.trap(s) { shutdown fixture_path, videos } }

unless videos.select{|v| !File.exists? fixture_path+'/'+v }.empty?
  # Open3.capture2e is the right way, but needs ruby 1.9
  puts "\nDownloading video fixture..."
  puts videos.map{|v| base_url+'/'+v}.join(' ')
  output = `cd '#{fixture_path}';
            LANG=C wget -c #{videos.map{|v| base_url+'/'+v}.join(' ')} || echo '\nERROR'`

  if output[-7..-1] == "\nERROR\n" then
    puts "wget fail. Try again."
    exit 0
  end
end

signals.map{|s| Signal.trap(s) { } }

