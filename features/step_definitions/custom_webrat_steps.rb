When /^I should see "([^\"]+)" link$/ do |link|
  response.should have_selector("a", :content => link)
end

When /^I should not see "([^\"]+)" link$/ do |link|
  response.should_not have_selector("a", :content => link)
end

