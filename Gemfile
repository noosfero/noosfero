source "https://rubygems.org"

platform :ruby do
  gem 'pg',                     '~> 1.1.3'
  gem 'rmagick',                '~> 2.13', require: false
  gem 'RedCloth',               '~> 4.2'
  gem 'unicorn',                '~> 5.4'
end

platform :jruby do
  gem 'activerecord-jdbcpostgresql-adapter'
  gem 'rmagick4j'
end

gem 'rails',                      '~> 5.1.6'
gem 'rails-html-sanitizer'
gem 'fast_gettext'
gem 'acts-as-taggable-on'
gem 'rails_autolink'
gem 'ruby-feedparser'
gem 'daemons'
gem 'nokogiri'
gem 'mini_portile2'
gem 'will_paginate'
gem 'delayed_job'
gem 'delayed_job_active_record'
gem 'rake',                       require: false
gem 'netrc'
gem 'rest-client'
gem 'exception_notification'
gem 'gettext',                    require: false
gem 'locale'
gem 'whenever',                   require: false
gem 'eita-jrails'
gem 'diffy'
gem 'slim'
gem 'activerecord-session_store'
gem 'recaptcha',                  require: 'recaptcha/rails'
gem 'font-awesome-sass'
gem 'rpush'
gem 'acts_as_list'
gem 'acts_as_tree'
gem 'contacts'
gem 'responders'
gem 'activemodel-serializers-xml'
gem 'hpricot'
gem 'http-cookie'
gem 'activerecord-import'
gem 'childprocess'
gem 'rubyzip'
gem 'tinymce-rails', '~> 4.8', '>= 4.8.2'
gem 'tinymce-rails-langs', '~> 4.2'

# API dependencies
gem 'grape'
gem 'grape-entity'
gem 'grape_logging'
gem 'rack-cors'
gem 'rack-contrib'
gem 'liquid'
gem 'api-pagination'

# asset pipeline
gem 'uglifier'
gem 'sass-rails'
gem 'sass'
gem 'sprockets-rails'

gem 'serviceworker-rails'
gem 'webpush'
gem 'rspec'
gem 'rspec-rails'
gem 'rails-controller-testing'

# gems to enable rails3 behaviour
gem 'protected_attributes_continued'
gem 'rails-observers'
gem 'actionpack-page_caching'
gem 'actionpack-action_caching'
gem 'scenic'
gem 'sass-listen'

group :production do
  gem 'dalli',                     '~> 2.7.0'
end

group :development, :test do
  gem 'spring'
  gem 'rubocop', require: false
end

group :test do
  gem 'mocha',                     require: false
  gem 'test-unit'
  gem 'minitest'
  gem 'minitest-reporters'
  gem 'rails-deprecated_sanitizer'
  gem 'simplecov',                 require: false
end

group :cucumber, :test do
  gem 'capybara'
  gem 'launchy'
  gem 'cucumber'
  gem 'cucumber-rails',		          require: false
  gem 'database_cleaner'
  # Selenium WebDriver 3+ depends on geckodriver
  gem 'selenium-webdriver'
  gem 'geckodriver-helper'
  gem 'chromedriver-helper'
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
