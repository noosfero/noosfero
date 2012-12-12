Then /^"([^"]*)" should not be visible within "([^"]*)"$/ do |text, selector|
  if page.has_content?(text)
    page.should have_no_css(selector, :text => text, :visible => false)
  end
end

Then /^I should see "([^"]*)" link$/ do |text|
  page.should have_css('a', :text => text)
end

Then /^I should not see "([^"]*)" link$/ do |text|
  page.should have_no_css('a', :text => text)
end

When /^I reload and wait for the page$/ do
  raise "Why why need this? Remove!"
  visit page.driver.browser.current_url
end
