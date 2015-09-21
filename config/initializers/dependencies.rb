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

# locally-developed modules
require 'acts_as_filesystem'
require 'acts_as_having_settings'
require 'acts_as_having_boxes'
require 'acts_as_having_image'
require 'acts_as_having_posts'
require 'acts_as_customizable'
require 'route_if'
require 'maybe_add_http'
require 'set_profile_region_from_city_state'
require 'authenticated_system'
require 'needs_profile'
require 'white_list_filter'

