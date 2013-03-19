When /^I select window "([^\"]*)"$/ do |selector|
  page.driver.browser.switch_to.window(selector)
end
