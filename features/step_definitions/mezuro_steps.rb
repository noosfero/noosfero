When /^I create a Mezuro (project|configuration) with the following data$/ do |type, fields|
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
	selenium.get_alert.should eql(message)
	selenium.chooseOkOnNextConfirmation();
end

Then /^I should see "([^"]*)" in the "([^"]*)" input$/ do |content, labeltext|
    find_field(labeltext).value.should == content
end

Then /^I should see "([^"]*)" button$/ do |button_name|
  find_button(button_name).should_not be_nil
end

When /^I have a Mezuro project with the following data$/ do |fields|
  item = {}
  fields.rows_hash.each do |name, value|
    if(name=="community")
      item.merge!(:profile=>Profile[value])
    else
      item.merge!(name => value)
    end
  end
  result = MezuroPlugin::ProjectContent.new(item)
  result.save!
end

When /^I update this Mezuro project with the following data$/ do |fields|
  find_field("article_name").set fields.rows_hash[:Title] 
  find_field("article_description").set fields.rows_hash[:Description] 
end

When /^I erase the "([^"]*)" field$/ do |field_name|
  find_field(field_name).set ""
end
