source "https://rubygems.org"
gem 'rails'
gem 'fast_gettext'
gem 'acts-as-taggable-on'
gem 'prototype-rails'
gem 'prototype_legacy_helper', '0.0.0', :path => 'vendor/prototype_legacy_helper'
gem 'rails_autolink'
gem 'pg'
gem 'rmagick'
gem 'RedCloth'
gem 'will_paginate'
gem 'ruby-feedparser'
gem 'daemons'
gem 'thin'
gem 'hpricot'
gem 'nokogiri'
gem 'rake', :require => false

# FIXME list here all actual dependencies (i.e. the ones in debian/control),
# with their GEM names (not the Debian package names)

group :production do
  gem 'dalli'
end

group :test do
  gem 'rspec'
  gem 'rspec-rails'
end

group :cucumber do
  gem 'rake'
  gem 'cucumber-rails', :require => false
  gem 'capybara'
  gem 'cucumber'
  gem 'database_cleaner'
  gem 'selenium-webdriver'
end

# include plugin gemfiles
Dir.glob(File.join('config', 'plugins', '*')).each do |plugin|
  plugin_gemfile = File.join(plugin, 'Gemfile')
  eval File.read(plugin_gemfile) if File.exists?(plugin_gemfile)
end
