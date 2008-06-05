# Install hook code here
require 'fileutils'
%w(stylesheets images javascripts).each do |type|
  dir = File.join(File.dirname(__FILE__), 'assets', type)
  FileUtils.cp_r(dir, File.join(RAILS_ROOT, 'public')) if File.exist?(dir)
end