Given /^I create community "(.+)"$/ do |community|
  Given 'I go to the Control panel'
  click_link('Manage my groups')
  click_link('Create a new community')
  fill_in("Name", :with => community)
  click_button("Create")
end

Given /^I approve community "(.+)"$/ do |community|
   task = CreateCommunity.all.select {|c| c.name == community}.first
   Given 'I go to the Control panel'
   click_link('Process requests')
   choose("decision-finish-#{task.id}")
   click_button('Apply!')
end

Given /^I reject community "(.+)"$/ do |community|
   task = CreateCommunity.all.select {|c| c.name == community}.first
   Given 'I go to the Control panel'
   click_link('Process requests')
   choose("decision-cancel-#{task.id}")
   click_button('Apply!')
end
