source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

platform :ruby do
  gem 'pg',                     '~> 1.0.0'
  gem 'rmagick',                '~> 2.13', require: false
  gem 'RedCloth',               '~> 4.2'
  gem 'unicorn',                '~> 5.4'
end

platform :jruby do
  gem 'activerecord-jdbcpostgresql-adapter'
  gem 'rmagick4j'
end

gem 'rails',                      '~> 5.1.6'
gem 'rails-html-sanitizer',       '~> 1.0.3'
gem 'fast_gettext'
gem 'acts-as-taggable-on'
gem 'rails_autolink'
gem 'ruby-feedparser'
gem 'daemons'
gem 'nokogiri'
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
gem 'eita-jrails',                  '~> 0.10.0'
gem 'diffy'
gem 'slim'
gem 'activerecord-session_store',   ('1.1.1' if RUBY_VERSION >= '2.3.0')
gem 'recaptcha', require: 'recaptcha/rails'
gem 'font-awesome-sass'
gem 'rpush'
gem 'acts_as_list',               '~> 0.9.11'
gem 'acts_as_tree',               '~> 2.7.1'
gem 'contacts',                   '~> 1.2.4'
gem 'responders',                 '~> 2.4.0'
gem 'activemodel-serializers-xml','~> 1.0.2'
gem 'hpricot',                    '~> 0.8.6' #This gem is deprecated, must use nokogiri instead
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
gem 'sass-rails',		                '~> 5.0.7'
gem 'sass',			                    '~> 3.5.6'
gem 'sprockets-rails',		          '~> 2.3.1'

gem 'serviceworker-rails'
gem 'webpush'

# gems to enable rails3 behaviour
gem 'protected_attributes_continued'
gem 'rails-observers',		          '~> 0.1.5'
gem 'actionpack-page_caching'
gem 'actionpack-action_caching'


gem 'sass-listen'

group :production do
  gem 'dalli',                      '~> 2.7.0'
end

group :development, :test do
  gem 'spring'
end

group :test do
  gem 'mocha',                  '~> 1.1.0', :require => false
  gem 'test-unit'
  gem 'minitest'
  gem 'minitest-reporters'
  gem 'simplecov', :require => false
  gem 'rspec'
  gem 'rspec-rails'
  gem 'rails-controller-testing',   '~> 1.0.2'
end

group :cucumber, :test do
  gem 'capybara',                   '~> 3.0.2'
  gem 'launchy'
  gem 'cucumber'
  gem 'cucumber-rails',		          '~> 1.6.0', :require => false
  gem 'database_cleaner'
  # Selenium WebDriver 3+ depends on geckodriver
  gem 'selenium-webdriver', 		  '~> 3.11'
  gem 'chromedriver-helper' if ENV['SELENIUM_DRIVER'] == 'chrome'
  gem 'geckodriver-helper', '~> 0.0.5' if ENV['SELENIUM_DRIVER'] == 'firefox'
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
