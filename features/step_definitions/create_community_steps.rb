include DatesHelper

Given /^I create community "(.+)"$/ do |community|
  step %{I go to admin_user's control panel}
  click_link('Manage my groups')
  click_link('Create a new community')
  fill_in("Name", :with => community)
  click_button("Create")
end

Given /^"(.+)" creates the community "(.+)"$/ do |username, community|
  step %{I go to #{username}'s control panel}
  click_link('Manage my groups')
  click_link('Create a new community')
  fill_in("Name", :with => community)
  click_link("Create")
end

Given /^I approve community "(.+)"$/ do |community|
  task = CreateCommunity.all.select {|c| c.name == community}.first
  step %{I go to admin_user's control panel}
  click_link('Tasks')
  click_link("Accept")
  first(:link, 'Apply!').click
end

Given /^I reject community "(.+)"$/ do |community|
  task = CreateCommunity.all.select {|c| c.name == community}.first
  step %{I go to admin_user's control panel}
  click_link('Tasks')
  click_link("Reject")
  first(:link, 'Apply!').click
end

Then /^I should see "([^\"]*)"'s creation date$/ do |community|
  com = Community.find_by name: community
  text = "Created at: #{show_date(com.created_at)}"
  has_content?(text)
end
