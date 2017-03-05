require 'pp'

# third-party libraries
require 'will_paginate'
require 'will_paginate/array'
require 'nokogiri'

# dependencies at vendor, firstly loaded on Gemfile
vendor = Dir.glob('vendor/{,plugins/}*') - ['vendor/plugins']
vendor.each do |dir|
  init_rb = "#{Rails.root}/#{dir}/init.rb"
  require init_rb if File.file? init_rb
end

# extensions
require 'extensions'

