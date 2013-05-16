Then /^"([^"]*)" should not be visible within "([^"]*)"$/ do |text, selector|
  if page.has_content?(text)
    page.should have_no_css(selector, :text => text, :visible => false)
  end
end

Then /^"([^"]*)" should be visible within "([^"]*)"$/ do |text, selector|
  if page.has_content?(text)
    page.should have_css(selector, :text => text, :visible => false)
  end
end

Then /^I should see "([^"]*)" link$/ do |text|
  page.should have_css('a', :text => text)
end

Then /^I should not see "([^"]*)" link$/ do |text|
  page.should have_no_css('a', :text => text)
end

When /^I should see "([^\"]+)" linking to "([^\"]+)"$/ do |text, href|
  page.should have_xpath("//a", :href => /#{href}/)
end

Then /^the "([^"]*)" button should be disabled$/ do |selector|
  field = find(selector)
  field['disabled'].should be_true
end

Then /^the "([^"]*)" button should be enabled$/ do |selector|
  field = find(selector)
  field['disabled'].should_not be_true
end

When /^I reload and wait for the page$/ do
  raise "Why why need this? Remove!"
  visit page.driver.browser.current_url
end

When /^I leave the "([^\"]+)" field$/ do |selector|
  page.execute_script "jQuery('#{selector}').trigger('blur')"
end

When /^I confirm the browser dialog$/ do
  page.driver.browser.switch_to.alert.accept
end
