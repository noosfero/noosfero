Then /^"([^"]*)" should not be visible within "([^"]*)"$/ do |text, selector|
  page.should have_no_css selector, text: text, visible: false
end

Then /^"([^"]*)" should be visible within "([^"]*)"$/ do |text, selector|
  page.should have_css selector, text: text, visible: false
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

Then /^the field "([^"]*)" should be (enabled|disabled)$/ do |selector, status|
  field = page.find(:css, selector)

  if status == 'enabled'
    field.disabled?.should_not be_truthy
  else
    field.disabled?.should be_truthy
  end
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
  sleep 1 # FIXME Don't know why, but this is necessary...  :/
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
