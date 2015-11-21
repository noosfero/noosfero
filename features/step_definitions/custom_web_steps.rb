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
  page.should have_xpath("//a[@href='#{href}']")
end

Then /^the "([^"]*)" button should be disabled$/ do |selector|
  field = find(selector)
  field['disabled'].should be_truthy
end

Then /^the "([^"]*)" button should be enabled$/ do |selector|
  field = find(selector)
  field['disabled'].should_not be_truthy
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

When /^I type in "([^\"]*)" into autocomplete list "([^\"]*)" and I choose "([^\"]*)"$/ do |term, input, result|
    # We seem to have to wait for the page to load js
    sleep 1
    page.execute_script("jQuery('#token-input-#{input}').trigger('focus').val('#{term}').trigger('keydown')")

    # We use this to wait for the search
    page.should have_selector('.token-input-dropdown li')

    page.execute_script ("jQuery('.token-input-dropdown li:contains(\"#{result}\")').trigger('mousedown');")
    page.should have_selector('li.token-input-token')
end
