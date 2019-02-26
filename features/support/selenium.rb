require 'selenium-webdriver'

Capybara.default_driver = :selenium
Capybara.register_driver :selenium do |app|
  case ENV['SELENIUM_DRIVER']
  when 'firefox'
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile.native_events = true
    profile["intl.accept_languages"] = "en"
    options = Selenium::WebDriver::Firefox::Options.new
    options.profile = profile
    options.headless!
    driver = Capybara::Selenium::Driver.new app, browser: :firefox, options: options
  when 'chrome'
    options = ::Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-gpu')
    options.add_argument('--disable-dev-shm-usage')
    driver = Capybara::Selenium::Driver.new app, browser: :chrome, options: options
  else
    puts '[ERROR] :: Unsupported web browser, use Google Chrome 71.0.3578.80 instead.'
  end
end

Capybara.javascript_driver = :selenium

Before('@ignore-hidden-elements') do
  Capybara.ignore_hidden_elements = true
end

Capybara.default_max_wait_time = 60
Capybara.server_host = "localhost"

World(Capybara)
