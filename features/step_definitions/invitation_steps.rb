Given /^I invite email "(.+)" to join community "(.+)"$/ do |email, community|
  identifier = Community.find_by_name(community).identifier
  visit("/myprofile/#{identifier}/profile_members")
  click_link('Invite your friends to join 26 Bsslines')
  click_button('Next')
  fill_in('manual_import_addresses', :with => "#{email}")
  fill_in('mail_template', :with => 'Follow this link <url>')
  click_button("Invite my friends!")
end

Given /^I invite email "(.+)" to be my friend$/ do |email|
  Given "I go to the Control panel"
  click_link('Manage friends')
  click_link('Invite people from my e-mail contacts')
  click_button('Next')
  fill_in('manual_import_addresses', :with => "#{email}")
  fill_in('mail_template', :with => 'Follow this link <url>')
  click_button("Invite my friends!")
end

Given /^there are no pending jobs$/ do
  Delayed::Worker.new.work_off
end
