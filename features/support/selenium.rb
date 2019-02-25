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
    capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
      chromeOptions: { args: %w(headless disable-gpu) }
    )
    driver = Capybara::Selenium::Driver.new(app, browser: :chrome, desired_capabilities: capabilities)
  else
    puts '[ERROR] :: Unsupported web browser, use Firefox 60.3.0 instead.'
  end
end

Capybara.register_driver :chrome do |app|
end

Capybara.register_driver :headless_chrome do |app|

end

Capybara.javascript_driver = :headless_chrome

Before('@ignore-hidden-elements') do
  Capybara.ignore_hidden_elements = true
end

Capybara.default_max_wait_time = 60
Capybara.server_host = "localhost"

World(Capybara)
