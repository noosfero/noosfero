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

