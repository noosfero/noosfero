require 'selenium/webdriver'

Capybara.default_driver = :selenium
Capybara.register_driver :selenium do |app|
  profile = Selenium::WebDriver::Firefox::Profile.new
  profile.native_events = true
  Capybara::Selenium::Driver.new app, browser: :firefox, profile: profile
end

Before('@ignore-hidden-elements') do
  Capybara.ignore_hidden_elements = true
end

Capybara.default_wait_time = 30
Capybara.server_host = "localhost"

World(Capybara)
