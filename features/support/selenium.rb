require 'selenium-webdriver'

Capybara.default_driver = :headless_chrome
Capybara.register_driver :selenium do |app|
puts 'capibaraaaaaaaaaaaaaaaaaaa'
puts  ENV['SELENIUM_DRIVER'].inspect
  case ENV['SELENIUM_DRIVER']
  when 'firefox'
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile.native_events = true
    profile["intl.accept_languages"] = "en"
    options = Selenium::WebDriver::Firefox::Options.new
    options.profile = profile
    options.headless!
    driver = Capybara::Selenium::Driver.new app, browser: :firefox, options: options
  when 'headless_chrome'
    profile = Selenium::WebDriver::Chrome::Profile.new
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_preference('profile', profile)
    options.headless!
    driver = Capybara::Selenium::Driver.new app, browser: :chrome, options: options
  else
    puts '[ERROR] :: Unsupported web browser, use Firefox 60.3.0 instead.'
  end
end


# This env var comes from the heroku-buildpack-google-chrome
chrome_bin = ENV.fetch('GOOGLE_CHROME_SHIM', nil)
# This env var comes from chromedriver_linux, e.g. TravisCI
chrome_bin ||= ENV.fetch('CHROME_BIN', nil)
chrome_options = {}
chrome_options[:binary] = chrome_bin if chrome_bin

 # Give us access to browser console logs, see spec/support/browser_logging.rb
logging_preferences = { browser: 'ALL' }

Capybara.register_driver :chrome do |app|
	raise 'bla'
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: chrome_options,
    loggingPrefs: logging_preferences
  )

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    desired_capabilities: capabilities
  )
end

Capybara.register_driver :headless_chrome do |app|
	raise 'bli'
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: chrome_options.merge(args: %w(headless disable-gpu)),
    loggingPrefs: logging_preferences
  )

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    desired_capabilities: capabilities
  )
end

Capybara.javascript_driver = :chrome


Before('@ignore-hidden-elements') do
  Capybara.ignore_hidden_elements = true
end

Capybara.default_max_wait_time = 60
Capybara.server_host = "localhost"

World(Capybara)
