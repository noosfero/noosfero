source "https://rubygems.org"
gem 'rails',                    '~> 4.2.3'
gem 'fast_gettext',             '~> 0.6.8'
gem 'acts-as-taggable-on',      '~> 3.4.2'
gem 'rails_autolink',           '~> 1.1.5'
gem 'pg',                       '~> 0.18.1'
gem 'rmagick',                  '~> 2.13.1'
gem 'RedCloth',                 '~> 4.2.9'
gem 'ruby-feedparser',          '~> 0.7'
gem 'daemons',                  '~> 1.1.5'
gem 'thin',                     '~> 1.3.1'
gem 'nokogiri',                 '~> 1.6.0'
gem 'will_paginate'
gem 'pothoven-attachment_fu'
gem 'delayed_job'
gem 'delayed_job_active_record'
gem 'rake', :require => false
gem 'rest-client',              '~> 1.6.7'
gem 'exception_notification',   '~> 4.0.1'
gem 'gettext',                  '~> 2.2.1', :require => false
gem 'locale',                   '~> 2.0.5'
gem 'whenever', :require => false
gem 'eita-jrails', '>= 0.9.9', require: 'jrails'

# asset pipeline
gem 'uglifier', '>= 1.0.3'
gem 'sass-rails'

# gems to enable rails3 behaviour
gem 'protected_attributes'
gem 'rails-observers'
gem 'actionpack-page_caching'
gem 'actionpack-action_caching'
gem 'activerecord-session_store'
gem 'activerecord-deprecated_finders', require: 'active_record/deprecated_finders'


# FIXME list here all actual dependencies (i.e. the ones in debian/control),
# with their GEM names (not the Debian package names)

group :production do
  gem 'dalli', '~> 2.7.0'
end

group :test do
  gem 'rspec',                  '~> 2.14.0'
  gem 'rspec-rails',            '~> 2.14.1'
  gem 'mocha',                  '~> 1.1.0', :require => false
  gem 'spring'
  gem 'test-unit' if RUBY_VERSION >= '2.2.0'
  gem 'minitest'
  gem 'minitest-reporters'
end

group :cucumber do
  gem 'cucumber-rails',         '~> 1.0.6', :require => false
  gem 'capybara',               '~> 2.1.0'
  gem 'cucumber',               '~> 1.0.6'
  gem 'database_cleaner',       '~> 1.2.0'
  gem 'selenium-webdriver',     '~> 2.39.0'
end

# Requires custom dependencies
eval(File.read('config/Gemfile'), binding) rescue nil

vendor = Dir.glob('vendor/{,plugins/}*') - ['vendor/plugins']
vendor.each do |dir|
  plugin = File.basename dir
  version = if Dir.glob("#{dir}/*.gemspec").length > 0 then '> 0.0.0' else '0.0.0' end

  gem plugin, version, path: dir
end

# include gemfiles from enabled plugins
# plugins in baseplugins/ are not included on purpose. They should not have any
# dependencies.
Dir.glob('config/plugins/*/Gemfile').each do |gemfile|
  eval File.read(gemfile)
end
