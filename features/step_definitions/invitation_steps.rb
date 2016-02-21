Given /^I invite email "(.+)" to join community "(.+)"$/ do |email, community|
  identifier = Community.find_by(name: community).identifier
  visit("/myprofile/#{identifier}/profile_members")
  first(:link, "Invite people to join").click
  choose("Email")
  click_button('Next')
  fill_in('manual_import_addresses', :with => "#{email}")
  click_link('Personalize invitation mail')
  fill_in('mail_template', :with => 'Follow this link <url>')
  click_button("Invite!")
end

Given /^I invite email "(.+)" to be my friend$/ do |email|
  click_link('Manage friends')
  click_link('Invite people')
  choose("Email")
  click_button('Next')
  fill_in('manual_import_addresses', :with => "#{email}")
  click_link('Personalize invitation mail')
  fill_in('mail_template', :with => 'Follow this link <url>')
  click_button("Invite!")
end
