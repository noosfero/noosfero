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
