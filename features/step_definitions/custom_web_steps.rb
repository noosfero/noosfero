Then /^"([^"]*)" should not be visible within "([^"]*)"$/ do |text, selector|
  if page.has_content?(text)
    page.should have_no_css(selector, :text => text, :visible => false)
  end
end

When /^I reload and wait for the page$/ do
  raise "Why why need this? Remove!"
  visit page.driver.browser.current_url
end
