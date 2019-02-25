require 'selenium-webdriver'

#Capybara.default_driver = :selenium
#Capybara.register_driver :selenium do |app|
#  case ENV['SELENIUM_DRIVER']
#  when 'firefox'
#    profile = Selenium::WebDriver::Firefox::Profile.new
#    profile.native_events = true
#    profile["intl.accept_languages"] = "en"
#    options = Selenium::WebDriver::Firefox::Options.new
#    options.profile = profile
#    options.headless!
#    driver = Capybara::Selenium::Driver.new app, browser: :firefox, options: options
#  when 'chrome'
##    capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
##      chromeOptions: { args: %w(headless disable-gpu --no-sandbox --disable-dev-shm-usage) }
##    )
##    driver = Capybara::Selenium::Driver.new(app, browser: :chrome, desired_capabilities: capabilities)
##    profile = Selenium::WebDriver::Chome::Profile.new
##    options = Selenium::WebDriver::Chome::Options.new
#    options = ::Selenium::WebDriver::Chrome::Options.new
#    options.add_argument('--headless')
#    options.add_argument('--no-sandbox')
#    options.add_argument('--disable-gpu')
#    options.add_argument('--disable-dev-shm-usage')
##    options.add_argument('--window-size=1400,1400')
##    options.headless!
#    driver = Capybara::Selenium::Driver.new app, browser: :chrome, options: options
#  else
#    puts '[ERROR] :: Unsupported web browser, use Firefox 60.3.0 instead.'
#  end
#end
#
#Capybara.javascript_driver = :selenium
#
#Before('@ignore-hidden-elements') do
#  Capybara.ignore_hidden_elements = true
#end
#
#Capybara.default_max_wait_time = 60
#Capybara.server_host = "localhost"
#
#World(Capybara)
#
Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.load_selenium
  browser_options = ::Selenium::WebDriver::Chrome::Options.new
  browser_options.args << '--headless'
  browser_options.args << '--disable-gpu'
  # Sandbox cannot be used inside unprivileged Docker container
  browser_options.args << '--remote-debugging-port=9222'
  browser_options.args << '--proxy-bypass-list=*'
  browser_options.args << " --proxy-server='direct://'"
  browser_options.args << '--no-sandbox'
  browser_options.args << '--mute-audio'
  browser_options.args << '--hide-scrollbars'
  browser_options.args << '--disable-software-rasterizer'
  browser_options.args << '--disable-extensions'
  browser_options.args << '--disable-dev-shm-usage'
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
end

Capybara.javascript_driver = :selenium
World(Capybara)
