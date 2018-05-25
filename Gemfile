source "https://rubygems.org"

platform :ruby do
  gem 'pg',                     '~> 0.17'
  gem 'rmagick',                '~> 2.13', require: false
  gem 'RedCloth',               '~> 4.2'
  gem 'unicorn',                '~> 4.8'
end

platform :jruby do
  gem 'activerecord-jdbcpostgresql-adapter'
  gem 'rmagick4j'
end

gem 'rails',                    '~> 4.2.4'
gem 'fast_gettext'
gem 'acts-as-taggable-on'
gem 'rails_autolink'
gem 'ruby-feedparser'
gem 'daemons'
gem 'nokogiri',                 (if RUBY_VERSION >= '2.4.0' then '~> 1.7.0' else '~> 1.6.0' end)
gem 'mini_portile2'
gem 'will_paginate'
gem 'pothoven-attachment_fu'
gem 'delayed_job'
gem 'delayed_job_active_record'
gem 'rake', :require => false
gem 'netrc'
gem 'rest-client'
gem 'exception_notification'
gem 'gettext', :require => false
gem 'locale'
gem 'whenever', :require => false
gem 'eita-jrails', require: 'jrails'
gem 'diffy'
gem 'slim'
gem 'activerecord-session_store', ('1.0.0.pre' if RUBY_VERSION >= '2.3.0')
gem 'recaptcha', require: 'recaptcha/rails'
gem 'honeypot-captcha'
gem 'font-awesome-sass'
gem 'rpush'
gem 'http-cookie'

# API dependencies
gem 'grape'
gem 'grape-entity'
gem 'grape_logging'
gem 'rack-cors'
gem 'rack-contrib'
gem 'api-pagination'
gem 'liquid'

# asset pipeline
gem 'uglifier'
gem 'sass-rails'
gem 'sass'
gem 'sprockets-rails'

gem 'serviceworker-rails'
gem 'webpush'

# gems to enable rails3 behaviour
gem 'protected_attributes'
gem 'rails-observers'
gem 'actionpack-page_caching'
gem 'actionpack-action_caching'


gem 'sass-listen'

group :production do
  gem 'dalli', '~> 2.7.0'
end

group :development, :test do
  gem 'spring'
end

group :test do
  gem 'mocha',                  '~> 1.1.0', :require => false
  gem 'test-unit' if RUBY_VERSION >= '2.2.0'
  gem 'minitest'
  gem 'minitest-reporters'
  gem 'simplecov', :require => false
  gem 'rspec'
  gem 'rspec-rails'
end

group :cucumber, :test do
  gem 'capybara'
  gem 'launchy'
  gem 'cucumber'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  # Selenium WebDriver 3+ depends on geckodriver
  gem 'selenium-webdriver'
  gem 'chromedriver-helper' if ENV['SELENIUM_DRIVER'] == 'chrome'
end

# Requires custom dependencies
eval(File.read('config/Gemfile'), binding) rescue nil

##
# Gems inside repository, to move outside
#
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

