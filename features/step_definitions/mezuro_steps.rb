When /^I create a Mezuro (project|configuration|reading group) with the following data$/ do |type, fields|
  click_link ("Mezuro " + type)

  fields.rows_hash.each do |name, value|
    When %{I fill in "#{name}" with "#{value}"}
  end

  click_button "Save" # Does not work without selenium?
  Article.find_by_name(fields.rows_hash[:Title])
end

Then /^I directly delete content with name "([^\"]*)" for testing purposes$/ do |content_name|
  Article.find_by_name(content_name).destroy
end

Then /^I should be at the url "([^\"]*)"$/ do |url|
  if response.class.to_s == 'Webrat::SeleniumResponse'
    URI.parse(response.selenium.get_location).path.should == url
  else
    URI.parse(current_url).path.should == url
  end
end

Then /^the field "([^"]*)" is empty$/ do |field_name|
  find_field(field_name).value.should be_nil
end

Then /^I should see "([^\"]*)" inside an alert$/ do |message|
	alert = page.driver.browser.switch_to.alert
  assert_equal message, alert.text
  alert.accept
end

Then /^I should see "([^"]*)" in the "([^"]*)" input$/ do |content, labeltext|
    find_field(labeltext).value.should == content
end

Then /^I should see "([^"]*)" button$/ do |button_name|
  find_button(button_name).should_not be_nil
end

Then /^I should not see "([^"]*)" button$/ do |button_name|
  find_button(button_name).should be_nil
end

When /^I have a Mezuro (project|reading group|configuration) with the following data$/ do |type,fields|
  item = {}
  fields.rows_hash.each do |name, value|
    if(name=="user" or name=="community")
      item.merge!(:profile=>Profile[value])
    else
      item.merge!(name => value)
    end
  end
  if (type == "project")
    result = MezuroPlugin::ProjectContent.new(item)
  elsif (type == "reading group")
    result = MezuroPlugin::ReadingGroupContent.new(item)
  elsif (type == "configuration")
    result = MezuroPlugin::ConfigurationContent.new(item)
  end
  result.save!
end

When /^I erase the "([^"]*)" field$/ do |field_name|
  find_field(field_name).set ""
end

When /^I fill the fields with the new following data$/ do |fields|
  fields.rows_hash.each do |key, value|
    name = key.to_s
    element = find_field(name)
    if element.tag_name.to_s == "select"
      select(value, :from => name)
    else
      element.set value
    end
  end
end
