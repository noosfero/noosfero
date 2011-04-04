When /^I should see "([^\"]+)" link$/ do |text|
  if response.class.to_s == 'Webrat::SeleniumResponse'
    response.selenium.is_element_present("css=a:contains('#{text}')")
  else
    response.should have_selector("a:contains('#{text}')")
  end
end

When /^I should not see "([^\"]+)" link$/ do |text|
  response.should_not have_selector("a:contains('#{text}')")
end

When /^I should see "([^\"]+)" linking to "([^\"]+)"$/ do |text, href|
  response.should have_selector("a:contains('#{text}')")
  response.should have_selector("a[href='#{href}']")
end

Then /^I should be exactly on (.+)$/ do |page_name|
  URI.parse(current_url).request_uri.should == path_to(page_name)
end

Then /^I should be moved to anchor "([^\"]+)"$/ do |anchor|
  URI.parse(current_url).fragment.should == anchor
end

When /^I select "([^\"]*)"$/ do |value|
  select(value)
end

When /^I fill in the following within "([^\"]*)":$/ do |parent, fields|
  fields.rows_hash.each do |name, value|
    When %{I fill in "#{name}" with "#{value}" within "#{parent}"}
  end
end

When /^I fill in "([^\"]*)" with "([^\"]*)" within "([^\"]*)"$/ do |field, value, parent|
  within(parent) do |content|
    content.fill_in(field, :with => value)
  end
end
