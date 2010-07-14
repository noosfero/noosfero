When /^I should see "([^\"]+)" link$/ do |text|
  response.should have_selector("a:contains('#{text}')")
end

When /^I should not see "([^\"]+)" link$/ do |text|
  response.should_not have_selector("a:contains('#{text}')")
end

Then /^I should be exactly on (.+)$/ do |page_name|
  URI.parse(current_url).request_uri.should == path_to(page_name)
end

When /^I select "([^\"]*)"$/ do |value|
  select(value)
  # FIXME ugly hack to make selenium tests waiting to render page
  # "select(value, :wait_for => :ajax)" did not effect
  if selenium
    selenium.wait_for_ajax
  end
end
