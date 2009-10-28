Given /^I create community "(.+)"$/ do |community|
  click_link('My groups')
  click_link('Create a new community')
  fill_in("Name", :with => community)
  click_button("Create")
end

Given /^I approve community "(.+)"$/ do |community|
   task = CreateCommunity.all.select {|c| c.name == community}.first
   click_link('Control Panel')
   click_link('Process requests')
   choose("decision-finish-#{task.id}")
   click_button('OK!')
end

Given /^I reject community "(.+)"$/ do |community|
   task = CreateCommunity.all.select {|c| c.name == community}.first
   click_link('Control Panel')
   click_link('Process requests')
   choose("decision-cancel-#{task.id}")
   click_button('OK!')
end
