source "https://rubygems.org"

platform :ruby do
  gem 'pg',                     '~> 0.17'
  gem 'rmagick',                '~> 2.13'
end
platform :jruby do
  gem 'activerecord-jdbcpostgresql-adapter'
  gem 'rmagick4j'
end

gem 'rails',                    '~> 4.2.4'
gem 'fast_gettext',             '~> 0.9'
gem 'acts-as-taggable-on',      '~> 3.5'
gem 'rails_autolink',           '~> 1.1.5'
gem 'RedCloth',                 '~> 4.2'
gem 'ruby-feedparser',          '~> 0.7'
gem 'daemons',                  '~> 1.1'
gem 'unicorn',                  '~> 4.8'
gem 'nokogiri',                 '~> 1.6.0'
gem 'will_paginate'
gem 'pothoven-attachment_fu',   '~> 3.2.16'
gem 'delayed_job'
gem 'delayed_job_active_record'
gem 'rake', :require => false
gem 'rest-client',              '~> 1.6'
gem 'exception_notification',   '~> 4.0.1'
gem 'gettext',                  '~> 3.1', :require => false
gem 'locale',                   '~> 2.1'
gem 'whenever', :require => false
gem 'eita-jrails', '~> 0.10.0', require: 'jrails'
gem 'diffy',                    '~> 3.0'
gem 'slim'

# API dependencies
gem 'grape',                    '~> 0.12'
gem 'grape-entity'
gem 'grape_logging'
gem 'rack-cors'
gem 'rack-contrib'

# asset pipeline
gem 'uglifier', '>= 1.0.3'
gem 'sass-rails'
gem 'sprockets-rails', '~> 2.1'

# gems to enable rails3 behaviour
gem 'protected_attributes'
gem 'rails-observers'
gem 'actionpack-page_caching'
gem 'actionpack-action_caching'
gem 'activerecord-session_store'
gem 'activerecord-deprecated_finders', require: 'active_record/deprecated_finders'

group :production do
  gem 'dalli', '~> 2.7.0'
end

group :development, :test do
  gem 'spring'
end

group :test do
  gem 'rspec',                  '~> 3.3', require: false
  gem 'rspec-rails',            '~> 3.2', require: false
  gem 'mocha',                  '~> 1.1.0', :require => false
  gem 'test-unit' if RUBY_VERSION >= '2.2.0'
  gem 'minitest'
  gem 'minitest-reporters'
end

group :cucumber do
  gem 'capybara',               '~> 2.2'
  gem 'launchy'
  gem 'cucumber'
  gem 'cucumber-rails',         '~> 1.4.2', :require => false
  gem 'database_cleaner',       '~> 1.3'
  gem 'selenium-webdriver'
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
